using Test
using Bobby

@testset "parser.jl" begin
    include("test_parser.jl")
end

@testset "bitboard.jl" begin
    include("test_bitboard.jl")
end

# @testset "moves.jl" begin
#     include("test_moves.jl")
# end

# @testset "magic.jl" begin
#     include("test_magic.jl")
# end

# @testset "check.jl" begin
#     include("test_check.jl")
# end

# @testset "game.jl" begin
#     include("test_game.jl")
# end