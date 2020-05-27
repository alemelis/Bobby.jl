@testset "knight.jl" begin
    @printf("> knight\n")

    #corners
    @test Bb.KNIGHT[p2u["a1"]] == reduce(|, p2u[s] for s = ["b3", "c2"])
    @test Bb.KNIGHT[p2u["h1"]] == reduce(|, p2u[s] for s = ["f2", "g3"])
    @test Bb.KNIGHT[p2u["h8"]] == reduce(|, p2u[s] for s = ["f7", "g6"])
    @test Bb.KNIGHT[p2u["a8"]] == reduce(|, p2u[s] for s = ["b6", "c7"])

    #sides
    @test Bb.KNIGHT[p2u["e1"]] == reduce(|, p2u[s] for s = ["d3", "c2", "g2", "f3"])
    @test Bb.KNIGHT[p2u["d8"]] == reduce(|, p2u[s] for s = ["b7", "c6", "f7", "e6"])
    @test Bb.KNIGHT[p2u["b4"]] == reduce(|, p2u[s] for s = ["a6", "c6", "a2",
                                                            "c2", "d5", "d3"])

    #center
    @test Bb.KNIGHT[p2u["d4"]] == reduce(|, p2u[s] for s =  ["c2", "b3", "b5", "c6",
                                                             "e6", "f5", "f3", "e2"])
end
