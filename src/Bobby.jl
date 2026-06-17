module Bobby
using Printf
using Crayons
using Random

include("structs.jl")
include("constants.jl")
include("cvt.jl")
include("zobrist.jl")
include("bitboard.jl")
include("king.jl")
include("knight.jl")
include("rook.jl")
include("bishop.jl")
include("magic.jl")
include("pext.jl")
include("pawn.jl")
include("move.jl")
include("perft.jl")
include("game.jl")
include("tensor.jl")
include("pgn.jl")

export read_pgn, san_to_uci, move_to_uci

# Attack tables (for move generation and evaluation)
export KNIGHT, KING, PAWN_X_WHITE, PAWN_X_BLACK

# Slider attacks
export getSliderAttack

# File masks
export FILE_A, FILE_H
end
