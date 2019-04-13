@testset "pawns" begin
    bb = Bobby.set_board()
    pl = Array{Bobby.Move,1}()
    pvl = Bobby.get_pawns_list(pl, bb)
    @test length(pvl) == 16

    pl = Array{Bobby.Move,1}()
    pvl = Bobby.get_pawns_list(pl, bb, "black")
    @test length(pvl) == 16

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/1p6/P7/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [6]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/8/P7/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [5]

    b = Bobby.fen_to_bitboard("k7/8/8/8/1p6/8/P7/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [5]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/1p6/P7/7K b - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [5]

    b = Bobby.fen_to_bitboard("k7/8/8/8/Pp6/8/8/7K b - a3 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [5]

    b = Bobby.fen_to_bitboard("k7/8/8/8/P7/1p6/8/7K b - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [4]

    b = Bobby.fen_to_bitboard("k7/8/8/8/P7/8/1p6/7K b - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [7]

    b = Bobby.fen_to_bitboard("k7/8/8/8/P7/8/7p/6NK b - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [7]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/p7/P7/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [3]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/2p5/3P4/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [6]

    b = Bobby.fen_to_bitboard("k7/8/8/8/8/2p1p3/3P4/7K w - - 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [7]

    b = Bobby.fen_to_bitboard("k7/8/8/8/2p1p3/3P1P2/8/7K b - d3 0 1")
    pt = Bobby.perft(b, 1, b.player_color)
    @test pt == [8]
end
