function test_unmove(b, bm)
	@test b.white == bm.white
	@test Set(b.P) == Set(bm.P)
	@test Set(b.R) == Set(bm.R)
	@test Set(b.N) == Set(bm.N)
	@test Set(b.B) == Set(bm.B)
	@test Set(b.Q) == Set(bm.Q)
	@test b.K == bm.K
	@test Set(b.A) == Set(bm.A)
	@test b.black == bm.black
	@test Set(b.p) == Set(bm.p)
	@test Set(b.r) == Set(bm.r)
	@test Set(b.n) == Set(bm.n)
	@test Set(b.b) == Set(bm.b)
	@test Set(b.q) == Set(bm.q)
	@test b.k == bm.k
	@test Set(b.a) == Set(bm.a)
	@test b.free == bm.free
	@test b.taken == bm.taken
	@test b.white_attacks == bm.white_attacks
	@test b.black_attacks == bm.black_attacks
	@test b.player_color == bm.player_color
	@test b.white_can_castle_queenside == bm.white_can_castle_queenside
    @test b.white_can_castle_kingside  == bm.white_can_castle_kingside 
    @test b.black_can_castle_queenside == bm.black_can_castle_queenside
    @test b.black_can_castle_kingside  == bm.black_can_castle_kingside 
    @test b.white_king_moved == bm.white_king_moved
    @test b.black_king_moved == bm.black_king_moved
    @test b.enpassant_square == bm.enpassant_square
    @test b.enpassant_done == bm.enpassant_done
    @test b.halfmove_clock == bm.halfmove_clock
    @test b.fullmove_clock == bm.fullmove_clock
    @test b.fen == bm.fen
    @test b.game == bm.game
end

@testset "unmove" begin
	b = Bobby.set_board()
	m = Bobby.Move(Bobby.PGN2UINT["e2"], 
		Bobby.PGN2UINT["e4"], "pawn", 
		"none", "none", Bobby.EMPTY, "none")
	bm = deepcopy(b)
	bm = Bobby.move_piece(bm, m)
	bm = Bobby.unmove_piece(bm, m, "white")
	test_unmove(b, bm)

	b = Bobby.fen_to_bitboard(
		"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 1 1")
	m = Bobby.Move(Bobby.PGN2UINT["e1"], 
		Bobby.PGN2UINT["f1"], "king", 
		"none", "none", Bobby.EMPTY, "none")
	bm = deepcopy(b)
	bm = Bobby.move_piece(bm, m)
	bm = Bobby.unmove_piece(bm, m, "white")
	test_unmove(b, bm)
end