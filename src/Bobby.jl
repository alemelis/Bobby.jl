module Bobby
    
    export Bitboard
    using Printf
    using Crayons
    using HDF5

    include("bitboard.jl")
    include("print.jl")
    include("moves.jl")
    include("pawns.jl")
    include("king.jl")
    include("queen.jl")
    include("nights.jl")
    include("rooks.jl")
    include("bishops.jl")
    include("perft.jl")
    include("magic.jl")
    include("check.jl")
    include("game.jl")
    include("parser.jl")
    
end