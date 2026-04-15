const _ZOBRIST_RNG    = MersenneTwister(20240101)
const ZOBRIST_PIECES  = rand(_ZOBRIST_RNG, UInt64, 7, 2, 64)  # [piece_type 1-6, color 1=w 2=b, sq_idx 1-64]
const ZOBRIST_CASTLING= rand(_ZOBRIST_RNG, UInt64, 16)         # index = castling UInt8 + 1 (0..15 → 1..16)
const ZOBRIST_EP      = rand(_ZOBRIST_RNG, UInt64, 9)          # 1..8 = file, 9 = no en passant
const ZOBRIST_SIDE    = rand(_ZOBRIST_RNG, UInt64)             # XOR when black to move
