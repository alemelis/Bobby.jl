function perftTest(fen, depth, nodes)
    b = Bb.loadFen(fen)
    pt = Bb.perft(b, depth)
    return pt.nodes == nodes
end

@testset "move.jl" begin
    @printf("> move\n")

    # https://www.chessprogramming.org/Perft_Results

    # --- Position 1: Initial position ---
    b = Bb.setBoard()
    pt = Bb.perft(b, 6)
    @test pt.nodes == [20, 400, 8902, 197281, 4865609, 119060324]

    # --- Position 2: Kiwipete ---
    @test perftTest("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0",
                    5, [48, 2039, 97862, 4085603, 193690690])

    # --- Position 3 ---
    @test perftTest("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1",
                    7, [14, 191, 2812, 43238, 674624, 11030083, 178633661])

    # --- Position 4 ---
    @test perftTest("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1",
                    5, [6, 264, 9467, 422333, 15833292])

    # --- Position 4 (mirror) ---
    @test perftTest("r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1",
                    5, [6, 264, 9467, 422333, 15833292])

    # --- Position 5 ---
    @test perftTest("rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8",
                    5, [44, 1486, 62379, 2103487, 89941194])

    # --- Position 6 ---
    @test perftTest("r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10",
                    5, [46, 2079, 89890, 3894594, 164075551])

    # --- Promotion-heavy position (rocechess.ch) ---
    @test perftTest("n1n5/PPPk4/8/8/8/8/4Kppp/5N1N b - - 0 1",
                    6, [24, 496, 9483, 182838, 3605103, 71179139])

    # --- Endgame: heavy pieces ---
    @test perftTest("8/3K4/2p5/p2b2r1/5k2/8/8/1q6 b - - 1 67",
                    3, [50, 279, 13310])

    # --- En passant: d3 ---
    @test perftTest("8/7p/p5pb/4k3/P1pPn3/8/P5PP/1rB2RK1 b - d3 0 28",
                    6, [5, 117, 3293, 67197, 1881089, 38633283])

    # --- En passant: f6 ---
    @test perftTest("rnbqkb1r/ppppp1pp/7n/4Pp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f6 0 3",
                    6, [31, 570, 17546, 351806, 11139762, 244063299])
end
