@testset "bishop.jl" begin
    @printf("> bishop\n")

    @test Bb.BISHOP_MASKS[Bb.sq2idx(p2u["a1"])] == Bb.BISHOP_MASKS[Bb.sq2idx(p2u["h8"])]
    @test Bb.BISHOP_MASKS[Bb.sq2idx(p2u["a8"])] == Bb.BISHOP_MASKS[Bb.sq2idx(p2u["h1"])]
    @test Bb.diagoSlide(p2u["e3"]) == Bb.BISHOP_MASKS[Bb.sq2idx(p2u["e3"])]
    @test Bb.bishopMasksGen()[Bb.sq2idx(p2u["d6"])] == reduce(|, [p2u[s] for s = ["b4", "c5", "c7", "e7", "e5", "f4", "g3"]])
end
