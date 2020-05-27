@testset "bitboard.jl" begin
    @printf("> bitboard\n")

    b = Bb.setBoard()
    @test b.black.P == Bb.MASK_RANKS[7]
    @test b.white.P == Bb.MASK_RANKS[2]
    @test b.white.K == p2u["e1"]
    @test b.black.K == p2u["e8"]
    @test b.white.Q == p2u["d1"]
    @test b.black.Q == p2u["d8"]
    @test b.white.R == p2u["a1"] | p2u["h1"]
    @test b.black.R == p2u["a8"] | p2u["h8"]
    @test b.white.B == p2u["c1"] | p2u["f1"]
    @test b.black.B == p2u["c8"] | p2u["f8"]
    @test b.white.N == p2u["b1"] | p2u["g1"]
    @test b.black.N == p2u["b8"] | p2u["g8"]

    [@test Bb.INT2UINT[i] & b.taken == Bb.EMPTY for i = 17:48]
    [@test Bb.INT2UINT[i] & ~b.taken == Bb.EMPTY for i = 1:16]
    [@test Bb.INT2UINT[i] & ~b.taken == Bb.EMPTY for i = 49:64]

    @test b.active
    @test b.castling == UInt8(15)
    @test b.enpassant == Bb.EMPTY
    @test b.halfmove == 0
    @test b.fullmove == 1
end
