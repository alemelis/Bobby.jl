const EMPTY = UInt64(0)

const PIECE_NONE = UInt8(0)
const PIECE_PAWN = UInt8(1)
const PIECE_KNIGHT = UInt8(2)
const PIECE_BISHOP = UInt8(3)
const PIECE_ROOK = UInt8(4)
const PIECE_QUEEN = UInt8(5)
const PIECE_KING = UInt8(6)

struct ChessSet
    P::UInt64
    N::UInt64
    B::UInt64
    R::UInt64
    Q::UInt64
    K::UInt64
    friends::UInt64
end

struct Board
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

struct Piece
    type::UInt8
    square::UInt64
end
const NONE = Piece(PIECE_NONE, EMPTY)

struct Move
    type::UInt8
    from::UInt64
    to::UInt64
    take::Piece
    enpassant::UInt64
    promotion::UInt8
    castling::UInt8
end
const CK = UInt8(8)
const CQ = UInt8(4)
const Ck = UInt8(2)
const Cq = UInt8(1)
const NOCASTLING = UInt8(0)
const NOTAMOVE = Move(PIECE_NONE, EMPTY, EMPTY, NONE,
    EMPTY, PIECE_NONE, NOCASTLING)

struct Moves
    moves::Array{Move,1}
end

function Moves()
    return Moves(Array{Move,1}())
end

function Moves(capacity::Int)
    m = Array{Move,1}(undef, 0)
    sizehint!(m, capacity)
    return Moves(m)
end

import Base.push!
function push!(list::Moves, move::Move)
    push!(list.moves, move)
end

import Base.empty!
@inline empty!(list::Moves) = empty!(list.moves)
