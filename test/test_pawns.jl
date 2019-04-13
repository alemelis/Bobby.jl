@testset "pawns" begin
    bb = Bobby.set_board()
    pl = Array{Bobby.Move,1}()
    pvl = Bobby.get_pawns_list(pl, bb)
    @test length(pvl) == 16

    pl = Array{Bobby.Move,1}()
    pvl = Bobby.get_pawns_list(pl, bb, "black")
    @test length(pvl) == 16
end
