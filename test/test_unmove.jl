function test_unmove(b, bm)
	@test b.white.P == bm.white.P
	@test b.white.R == bm.white.R
	@test b.white.N == bm.white.N
	@test b.white.B == bm.white.B
	@test b.white.Q == bm.white.Q
	@test b.white.K == bm.white.K
	@test Set(b.white.A) == Set(bm.white.A)
	@test b.black.P == bm.black.P
	@test b.black.R == bm.black.R
	@test b.black.N == bm.black.N
	@test b.black.B == bm.black.B
	@test b.black.Q == bm.black.Q
	@test b.black.K == bm.black.K
	@test Set(b.black.A) == Set(bm.black.A)
	@test b.free == bm.free
	@test b.taken == bm.taken
	@test b.white_attacks == bm.white_attacks
	@test b.black_attacks == bm.black_attacks
	@test b.player_color == bm.player_color
	@test b.white.can_castle_queenside == bm.white.can_castle_queenside
    @test b.white.can_castle_kingside  == bm.white.can_castle_kingside 
    @test b.black.can_castle_queenside == bm.black.can_castle_queenside
    @test b.black.can_castle_kingside  == bm.black.can_castle_kingside 
    @test b.white.king_moved == bm.white.king_moved
    @test b.black.king_moved == bm.black.king_moved
    @test b.enpassant_square == bm.enpassant_square
    @test b.halfmove_clock == bm.halfmove_clock
    @test b.fullmove_clock == bm.fullmove_clock
    @test b.fen == bm.fen
    @test b.game == bm.game
end

@testset "unmove" begin
	b = Bobby.set_board()
	m = Bobby.Move(Bobby.PGN2UINT["e2"], 
		Bobby.PGN2UINT["e4"], "pawn", 
		"none", "none", Bobby.EMPTY, "none", Bobby.EMPTY)
	bm = deepcopy(b)
	bm = Bobby.move_piece(bm, m, "white", b.white, b.black)
	bm = Bobby.unmove_piece(bm, m, "white", b.white, b.black)
	test_unmove(b, bm)

	b = Bobby.fen_to_chessboard(
		"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 1 1")
	m = Bobby.Move(Bobby.PGN2UINT["e1"], 
		Bobby.PGN2UINT["f1"], "king", 
		"none", "none", Bobby.EMPTY, "none", Bobby.EMPTY)
	bm = deepcopy(b)
	bm = Bobby.move_piece(bm, m, "white", b.white, b.black)
	bm = Bobby.unmove_piece(bm, m, "white", b.white, b.black)
	test_unmove(b, bm)
end