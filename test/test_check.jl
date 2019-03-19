@testset "check" begin
    b = Bobby.set_board()

    @test !Bobby.check_check(b)
    @test !Bobby.check_check(b, "black")

    @test Bobby.check_mate(b) == false
end