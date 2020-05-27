@testset "magic.jl" begin
    @printf("> magic\n")

    [@test length(Bb.getOccupancyString(i)) == 2^i for i = 1:6]
    @test Bb.getOccupancyString(1) == ("0", "1")

    [@test Bb.getNumberOfSquares(p2u["a1"], true, d) == 6 for d in [1, 3]]
    [@test Bb.getNumberOfSquares(p2u["a1"], true, d) == 0 for d in [2, 4]]
    @test Bb.getNumberOfSquares(p2u["a1"], false, 2) == 6
    [@test Bb.getNumberOfSquares(p2u["a1"], false, d) == 0 for d in [1, 3, 4]]

    [@test Bb.getNumberOfBits(p2u[s], true) == 12 for s in ["a1", "a8", "h1", "h8"]]
    [@test Bb.getNumberOfBits(p2u[s], true) == 11 for s in ["a4", "f8", "e1", "h2"]]
    [@test Bb.getNumberOfBits(p2u[s], true) == 10 for s in ["b4", "d3", "f7", "g2"]]
    [@test Bb.getNumberOfBits(p2u[s], false) == 6 for s in ["a1", "a8", "h1", "h8"]]
    [@test Bb.getNumberOfBits(p2u[s], false) == 5 for s in ["a3", "g5", "e2", "f8"]]
    [@test Bb.getNumberOfBits(p2u[s], false) == 7 for s in ["c3", "f5", "e3"]]
    [@test Bb.getNumberOfBits(p2u[s], false) == 9 for s in ["d4", "e5"]]
    [@test Bb.ROOK_BITS[p2u[s]] == 12 for s in ["a1", "a8", "h1", "h8"]]
    [@test Bb.ROOK_BITS[p2u[s]] == 11 for s in ["a4", "f8", "e1", "h2"]]
    [@test Bb.ROOK_BITS[p2u[s]] == 10 for s in ["b4", "d3", "f7", "g2"]]
    [@test Bb.BISHOP_BITS[p2u[s]] == 6 for s in ["a1", "a8", "h1", "h8"]]
    [@test Bb.BISHOP_BITS[p2u[s]] == 5 for s in ["a3", "g5", "e2", "f8"]]
    [@test Bb.BISHOP_BITS[p2u[s]] == 7 for s in ["c3", "f5", "e3"]]
    [@test Bb.BISHOP_BITS[p2u[s]] == 9 for s in ["d4", "e5"]]

    @test Base.summarysize(Bb.DIAGO_OCCS) == 49080
    @test Base.summarysize(Bb.ORTHO_OCCS) == 826296
    @test (Bb.MASK_RANKS[1] & ~p2u["h1"] ⊻ Bb.MASK_FILES[1] & ~p2u["a8"]) in Bb.ORTHO_OCCS[p2u["a1"]]

    @test Bb.randomMagic() != Bb.randomMagic()

    blockers = reduce(|, p2u[s] for s in ["e2", "e5", "b3", "d4", "h3", "h6"])
    rook_attack = reduce(|, p2u[s] for s in ["e2", "e4", "e5", "b3", "c3", "d3", "f3", "g3", "h3"])
    bishop_attack = reduce(|, p2u[s] for s in ["d4", "f2", "g1", "f4", "g5", "h6", "d2", "c1"])
    @test Bb.getMagicAttack(p2u["e3"], blockers, true) == rook_attack
    @test Bb.getMagicAttack(p2u["e3"], blockers, false) == bishop_attack
end
