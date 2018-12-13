using Test
using Bobby

@testset "bitboard.jl" begin
	include("test_bitboard.jl")
end

@testset "moves.jl" begin
	include("test_moves.jl")
end

@testset "magic.jl" begin
	include("test_magic.jl")
end

@testset "check.jl" begin
	include("test_check.jl")
end