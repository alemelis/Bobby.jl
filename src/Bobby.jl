module Bobby
    
    export Bitboard
    using Printf
    using Crayons

    include("constants.jl")
    include("cvt.jl")
    include("bitboard.jl")
    include("king.jl")
    include("knight.jl")
    include("rook.jl")
    include("bishop.jl")
    include("magic.jl")
    include("pawn.jl")
    include("move.jl")
    include("perft.jl")
end
