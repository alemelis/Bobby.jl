@testset "parser" begin
    b = Bobby.fen_to_bitboard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    @test b.free == ~b.taken

    @test_throws ArgumentError Bobby.fen_to_bitboard(
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN")
end