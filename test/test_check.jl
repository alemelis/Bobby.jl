@testset "check" begin
    b = Bobby.set_board()

    @test !Bobby.king_in_check(b)
    @test !Bobby.king_in_check(b, "black")
end