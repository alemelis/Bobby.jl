const _ZOBRIST_RNG    = MersenneTwister(20240101)

# Flat layout: index = type + 7*(color-1) + 14*(sq-1), 1-based.
# type ∈ 1..6 (slot 7 unused, kept for stride alignment with old [type,color,sq] API).
# color ∈ 1..2, sq ∈ 1..64.  Total 7*2*64 = 896 UInt64 = 7 KiB.
const ZOBRIST_PIECES  = rand(_ZOBRIST_RNG, UInt64, 7 * 2 * 64)
const ZOBRIST_CASTLING= rand(_ZOBRIST_RNG, UInt64, 16)         # index = castling UInt8 + 1 (0..15 → 1..16)
const ZOBRIST_EP      = rand(_ZOBRIST_RNG, UInt64, 9)          # 1..8 = file, 9 = no en passant
const ZOBRIST_SIDE    = rand(_ZOBRIST_RNG, UInt64)             # XOR when black to move

@inline zobristPiece(type::Integer, color::Integer, sq::Integer) =
    @inbounds ZOBRIST_PIECES[type + 7 * (color - 1) + 14 * (sq - 1)]
