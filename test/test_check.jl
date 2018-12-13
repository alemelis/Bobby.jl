@testset "slide rook" begin
	b = Bobby.buildBoard()

	@test !Bobby.checkCheck(b)
	@test !Bobby.checkCheck(b, "black")

	b.K[20] = true
	@test Bobby.checkCheck(b)

	b.k[44] = true
	@test Bobby.checkCheck(b, "black")
end