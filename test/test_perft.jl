@testset "perft" begin

	b = Bobby.set_board()
	pt = Bobby.perft(b, 3)
	@test pt.nodes == [20, 400, 8902]

	# pt = Bobby.perft(b, 3, "black")
	# @test pt.nodes == [20, 400, 8902]
end
