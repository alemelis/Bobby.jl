@testset "pgn parser" begin

	@test_throws DomainError Bobby.pgn2int("e")
	@test_throws DomainError Bobby.pgn2int("e11")
	@test_throws ArgumentError Bobby.pgn2int("ee")
	@test_throws DomainError Bobby.pgn2int("11")
	@test_throws DomainError Bobby.pgn2int("k1")

	# square_pgn = "a8"
	# square_idx = 1
	# @test square_idx == Bobby.pgn2int(square_pgn)
end