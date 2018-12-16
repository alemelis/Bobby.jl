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

end