using BenchmarkTools
using Bobby

b = Bobby.setBoard()
SUITE = BenchmarkGroup()
SUITE["perft"] = BenchmarkGroup()
SUITE["perft"]["starting position"] = @benchmarkable Bobby.perft(b,4)

fens = ["r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0",
        "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 0",
        "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1",
        "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1",
        "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8",
        "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10",
        "n1n5/PPPk4/8/8/8/8/4Kppp/5N1N b - - 0 1",
        "8/7p/p5pb/4k3/P1pPn3/8/P5PP/1rB2RK1 b - d3 0 28",
        "rnbqkb1r/ppppp1pp/7n/4Pp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f6 0 3",
        "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1"]

for (i, f) in enumerate(fens)
    b = Bobby.loadFen(f)
    SUITE["perft"]["perft"*string(i)] = @benchmarkable Bobby.perft(b, 4)
end
