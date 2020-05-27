@testset "king.jl" begin
    @printf("> king\n")

    #corners
    @test Bb.KING[p2u["a1"]] == p2u["a2"] | p2u["b2"] | p2u["b1"]
    @test Bb.KING[p2u["a8"]] == p2u["a7"] | p2u["b7"] | p2u["b8"]
    @test Bb.KING[p2u["h1"]] == p2u["g1"] | p2u["g2"] | p2u["h2"]
    @test Bb.KING[p2u["h8"]] == p2u["g8"] | p2u["g7"] | p2u["h7"]

    #sides
    @test Bb.KING[p2u["a4"]] == reduce(|, [p2u[s] for s=["a3","a5","b3","b4","b5"]])
    @test Bb.KING[p2u["h5"]] == reduce(|, [p2u[s] for s=["h4","h6","g4","g5","g6"]])
    @test Bb.KING[p2u["e1"]] == reduce(|, [p2u[s] for s=["e2","d1","d2","f1","f2"]])
    @test Bb.KING[p2u["c8"]] == reduce(|, [p2u[s] for s=["c7","b8","b7","d8","d7"]])

    #center
    @test Bb.KING[p2u["e4"]] == reduce(|, [p2u[s] for s=["e3","e5","d3","d4","d5", "f3","f4","f5"]])
end
