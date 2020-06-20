using Bobby
using Test
using Printf

Bb = Bobby
@testset "Bobby.jl" begin
    include("test_cvt.jl")
    include("test_bitboard.jl")
    include("test_king.jl")
    include("test_knight.jl")
    include("test_rook.jl")
    include("test_bishop.jl")
    include("test_magic.jl")
    include("test_move.jl")

    @printf("\n")
end
