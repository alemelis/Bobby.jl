const EMPTY = UInt64(0)

const PIECE_NONE   = UInt8(0)
const PIECE_PAWN   = UInt8(1)
const PIECE_KNIGHT = UInt8(2)
const PIECE_BISHOP = UInt8(3)
const PIECE_ROOK   = UInt8(4)
const PIECE_QUEEN  = UInt8(5)
const PIECE_KING   = UInt8(6)

struct ChessSet
    P::UInt64
    N::UInt64
    B::UInt64
    R::UInt64
    Q::UInt64
    K::UInt64
    friends::UInt64
end

mutable struct Board
    white::ChessSet
    black::ChessSet

    taken::UInt64

    active::Bool
    castling::UInt8
    enpassant::UInt64
    halfmove::Int64
    fullmove::Int64
    hash::UInt64
end

# Snapshot of the fields modified by makeMove!, stack-allocated (isbits).
# Returned by makeMove! and consumed by unmakeMove! to restore Board in place.
struct Undo
    white::ChessSet
    black::ChessSet
    taken::UInt64
    active::Bool
    castling::UInt8
    enpassant::UInt64
    hash::UInt64
end

struct Piece
    type::UInt8
    square::UInt64
end
const NONE = Piece(PIECE_NONE, EMPTY)

const CK = UInt8(8)
const CQ = UInt8(4)
const Ck = UInt8(2)
const Cq = UInt8(1)
const NOCASTLING = UInt8(0)

# Bit-packed move (4 bytes total):
#   bits  0– 5  from_tz       trailing_zeros(from sq), 0–63
#   bits  6–11  to_tz
#   bits 12–14  piece type    1–6 (PIECE_PAWN…PIECE_KING); 0 = NOTAMOVE sentinel
#   bits 15–17  capture type  0 = quiet, 1–6
#   bits 18–20  promotion     0 = none, 2–5
#   bit  21     is_ep_capture 1 = en-passant capture
#   bits 22–24  castling_enc  0=none 1=CQ 2=CK 3=Cq 4=Ck
#   bits 25–31  new_ep_enc    0=EMPTY, else trailing_zeros(new_ep_sq)+1

struct Move
    bits::UInt32
end

# Encoding/decoding tables for the 3-bit castling field.
# NOCASTLING=0,Cq=1,Ck=2,CQ=4,CK=8  →  encoded as 0,3,4,0,1,0,0,0,2  (indexed by value)
const _CAST_ENC = UInt8[0, 3, 4, 0, 1, 0, 0, 0, 2]
# Encoded 0–4 → original constant; extra slots keep the table safely over-sized.
const _CAST_DEC = UInt8[0, 4, 8, 1, 2, 0, 0, 0]   # index 1-based (enc+1)

@inline mfrom_tz(m::Move)   = Int(m.bits & 0x3f)
@inline mto_tz(m::Move)     = Int((m.bits >> 6) & 0x3f)
@inline mfrom_sq(m::Move)   = UInt64(1) << mfrom_tz(m)
@inline mto_sq(m::Move)     = UInt64(1) << mto_tz(m)
@inline mfrom_idx(m::Move)  = mfrom_tz(m) + 1          # sq2idx-equivalent
@inline mto_idx(m::Move)    = mto_tz(m)   + 1
@inline mpiece(m::Move)     = UInt8((m.bits >> 12) & 0x7)
@inline mcapture(m::Move)   = UInt8((m.bits >> 15) & 0x7)
@inline mpromo(m::Move)     = UInt8((m.bits >> 18) & 0x7)
@inline mis_ep(m::Move)     = (m.bits >> 21) & UInt32(1) != 0
@inline mcastling_enc(m::Move) = Int((m.bits >> 22) & 0x7)
@inline mcastling(m::Move)  = @inbounds _CAST_DEC[mcastling_enc(m) + 1]
@inline mep_new_sq(m::Move) = let enc = (m.bits >> 25)
    enc == 0 ? EMPTY : UInt64(1) << (Int(enc) - 1)
end

# Preserve the original constructor signature so all movegen sites compile unchanged.
function Move(type::UInt8, from::UInt64, to::UInt64, take::Piece,
              enpassant::UInt64, promotion::UInt8, castling::UInt8)::Move
    from_tz  = from == EMPTY ? 0 : Int(trailing_zeros(from))
    to_tz    = to   == EMPTY ? 0 : Int(trailing_zeros(to))
    # EP capture: captured pawn's square differs from the destination square.
    is_ep    = UInt32(take.type != PIECE_NONE && to != EMPTY && take.square != to)
    cast_enc = UInt32(@inbounds _CAST_ENC[Int(castling) + 1])
    ep_enc   = enpassant == EMPTY ? UInt32(0) : UInt32(trailing_zeros(enpassant)) + UInt32(1)
    Move(UInt32(from_tz)           |
         UInt32(to_tz)    << 6     |
         UInt32(type)     << 12    |
         UInt32(take.type) << 15   |
         UInt32(promotion) << 18   |
         is_ep             << 21   |
         cast_enc          << 22   |
         ep_enc            << 25)
end

const NOTAMOVE = Move(PIECE_NONE, EMPTY, EMPTY, NONE, EMPTY, PIECE_NONE, NOCASTLING)

# Fixed-capacity move list: preallocated array + explicit count.
# Never reallocates during search/perft. Max legal moves in any chess position ≈ 218.
mutable struct MoveList
    data::Vector{Move}
    count::Int
end

function MoveList(capacity::Int = 256)
    MoveList(Vector{Move}(undef, capacity), 0)
end

import Base.push!
@inline function push!(list::MoveList, m::Move)
    @inbounds list.data[list.count += 1] = m
end

import Base.empty!
@inline empty!(list::MoveList) = (list.count = 0; list)

# Backward-compatible alias: all existing ::Moves annotations and Moves()/Moves(n) calls
# resolve to MoveList without touching pawn.jl, king.jl, etc.
const Moves = MoveList
