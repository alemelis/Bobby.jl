@testset "rook.jl" begin
    @printf("> rook\n")

	@test Bb.orthoSlide(p2u["a1"]) == Bb.MASK_RANKS[1] | Bb.MASK_FILES[1] ⊻ p2u["a1"] ⊻ p2u["a8"] ⊻ p2u["h1"]
    @test Bb.orthoSlide(p2u["h8"]) == Bb.MASK_RANKS[8] | Bb.MASK_FILES[8] ⊻ p2u["h8"] ⊻ p2u["a8"] ⊻ p2u["h1"]
    @test Bb.orthoSlide(p2u["e4"]) == (Bb.MASK_RANKS[4] | Bb.MASK_FILES[5] ⊻ p2u["e4"] ⊻
                                       p2u["e8"] ⊻ p2u["e1"] ⊻ p2u["a4"] ⊻ p2u["h4"])
    @test Bb.ROOK_MASKS[p2u["a1"]] == Bb.MASK_RANKS[1] | Bb.MASK_FILES[1] ⊻ p2u["a1"] ⊻ p2u["a8"] ⊻ p2u["h1"]
    @test Bb.ROOK_MASKS[p2u["h8"]] == Bb.MASK_RANKS[8] | Bb.MASK_FILES[8] ⊻ p2u["h8"] ⊻ p2u["a8"] ⊻ p2u["h1"]
    @test Bb.rookMasksGen()[p2u["e4"]] == (Bb.MASK_RANKS[4] | Bb.MASK_FILES[5] ⊻ p2u["e4"] ⊻
                                           p2u["e8"] ⊻ p2u["e1"] ⊻ p2u["a4"] ⊻ p2u["h4"])

    @test Bb.orthoAttack(p2u["a1"], p2u["a2"]) == Bb.MASK_RANKS[1] ⊻ p2u["a1"] | p2u["a2"]
    @test Bb.orthoAttack(p2u["a1"], Bb.EMPTY) == Bb.MASK_RANKS[1] | Bb.MASK_FILES[1] ⊻ p2u["a1"]
    @test Bb.orthoAttack(p2u["e3"], Bb.EMPTY) == Bb.MASK_RANKS[3] | Bb.MASK_FILES[5] ⊻ p2u["e3"]
end
