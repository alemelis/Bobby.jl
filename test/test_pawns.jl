@testset "pawns" begin
    bb = Bobby.set_board()
    pvl = Bobby.get_pawns_list(bb)
    @test length(pvl) == 16

    pvl = Bobby.get_pawns_list(bb, "black")
    @test length(pvl) == 16
end
