@testset "king" begin
    b = Bobby.set_board()
    
    kv = Bobby.gen_king_valid(Bobby.INT2UINT[61])
    @test length(kv) == 5
    kvw = [0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,1,1,1,0,0,
           0,0,0,1,0,1,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(kv)) .== kvw)
    
    akv = Bobby.gen_all_king_valid_moves()
    @test all(Int.(Bobby.cvt_to_bitarray(akv[Bobby.INT2UINT[61]])) .== kvw)

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/8/8/4K3 w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [5]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/8/8/4K2R w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [14]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/8/8/4K2R w K - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [15]

    b = Bobby.fen_to_bitboard("1k6/8/8/8/8/8/8/R3K3 w K - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [15]

    b = Bobby.fen_to_bitboard("1k6/8/8/8/8/8/8/R3K3 w Q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [16]

    b = Bobby.fen_to_bitboard("1k6/8/8/8/8/3r4/8/R3K3 w Q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [13]

    b = Bobby.fen_to_bitboard("1k6/8/8/8/8/2r5/8/R3K3 w Q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [15]

    b = Bobby.fen_to_bitboard("1k6/8/8/8/8/5r2/8/4K2R w Q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [12]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/6K1 b - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [15]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/6K1 b q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [16]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/1R4K1 b q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [16]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/2R3K1 b q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [15]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/3R2K1 b q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [13]

    b = Bobby.fen_to_bitboard("r3k3/8/8/8/8/8/8/4R1K1 b q - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [4]

    b = Bobby.fen_to_bitboard("k3r3/8/8/8/8/8/8/4K2R w K - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [4]
end
