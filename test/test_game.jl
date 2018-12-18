@testset "pgn parser" begin

	@test_throws DomainError Bobby.pgn2int("e")
	@test_throws DomainError Bobby.pgn2int("e11")
	@test_throws ArgumentError Bobby.pgn2int("ee")
	@test_throws DomainError Bobby.pgn2int("11")
	@test_throws DomainError Bobby.pgn2int("k1")

	@test Bobby.pgn2int("a8") == 1
	@test Bobby.pgn2int("h1") == 64
	@test Bobby.pgn2int("h8") == 8
	@test Bobby.pgn2int("a1") == 57

	b = Bobby.buildBoard()
	@test Bobby.int2piece(b, 1) == 'r'
	@test Bobby.int2piece(b, 2) == 'n'
	@test Bobby.int2piece(b, 3) == 'b'
	@test Bobby.int2piece(b, 4) == 'q'
	@test Bobby.int2piece(b, 5) == 'k'
	@test Bobby.int2piece(b, 9) == 'p'
	@test Bobby.int2piece(b, 17) == ' '
	@test Bobby.int2piece(b, 64) == 'R'
	@test Bobby.int2piece(b, 63) == 'N'
	@test Bobby.int2piece(b, 62) == 'B'
	@test Bobby.int2piece(b, 61) == 'K'
	@test Bobby.int2piece(b, 60) == 'Q'
	@test Bobby.int2piece(b, 56) == 'P'

end