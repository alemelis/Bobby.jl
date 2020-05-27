@testset "cvt" begin
    @printf("\n> cvt\n")
    
    # toInt
    @test Bb.toInt("1") == UInt64(1)
    @test Bb.toInt("10") == UInt64(2)
    @test Bb.toInt("11") == UInt64(3)

    # PGN2UINT
    a8uint = Bb.PGN2UINT["a8"]
    @test Bb.UINT2PGN[a8uint] == "a8"

    # PGN2INT
    @test Bb.PGN2INT["a8"] == 1
    @test Bb.INT2PGN[1] == "a8"

    # INT2UINT
    @test Bb.INT2UINT[1] == Bb.PGN2UINT["a8"]
    uint = Bb.PGN2UINT["a8"]
    @test Bb.UINT2INT[uint] == 1
end
p2u = Bb.PGN2UINT
