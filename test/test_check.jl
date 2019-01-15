@testset "check" begin
    b = Bobby.buildBoard()
    l = Bobby.buildLookUpTables()

    @test !Bobby.checkCheck(b)
    @test !Bobby.checkCheck(b, "black")

    b.K[20] = true
    @test Bobby.checkCheck(b)

    b.k[44] = true
    @test Bobby.checkCheck(b, "black")

    b, e = Bobby.move(b, l, "e2", "e3")
    @test Bobby.checkMate(b, l) == false
end