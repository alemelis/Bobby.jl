using BenchmarkTools
using Bobby
using Printf

# ---------------------------------------------------------------------------
# Standard benchmark positions (from https://www.chessprogramming.org/Perft_Results)
#
# Run with:
#   julia --check-bounds=no -O3 --project benchmark/benchmarks.jl
#
# Tracked metrics: nodes/second (NPS) — not wall time, so depth variations cancel out.
# Primary positions:
#   - Starting position depth 6 : 119,060,324 nodes  (move-gen volume)
#   - Kiwipete         depth 5 : 193,690,690 nodes  (captures + castling stress)
# ---------------------------------------------------------------------------

const POSITIONS = [
    ("Starting position", "", 6, 119_060_324),
    ("Kiwipete", "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0", 5, 193_690_690),
    ("Position 3", "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1", 6, 11_030_083),
    ("Position 4", "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1", 5, 15_833_292),
    ("Position 5", "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8", 5, 89_941_194),
    ("Position 6", "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10", 5, 164_075_551),
]

# ---------------------------------------------------------------------------
# Correctness check before benchmarking
# ---------------------------------------------------------------------------
println("Verifying node counts...")
for (name, fen, depth, expected) in POSITIONS
    b = isempty(fen) ? Bobby.setBoard() : Bobby.loadFen(fen)
    pt = Bobby.perft(b, depth)
    actual = pt.nodes[depth]
    status = actual == expected ? "✓" : "✗ got $actual, want $expected"
    println("  $name d$depth: $status")
end
println()

# ---------------------------------------------------------------------------
# Benchmark: report median NPS per position
# ---------------------------------------------------------------------------
println("Benchmarking (median of BenchmarkTools trials)...")
println()
@printf("%-22s  %5s  %15s  %12s\n", "Position", "Depth", "Nodes", "NPS")
println("-"^60)

function format_int(n::Int)
    s = string(n)
    # insert thousands separators
    result = IOBuffer()
    for (i, c) in enumerate(reverse(s))
        i > 1 && (i - 1) % 3 == 0 && write(result, ',')
        write(result, c)
    end
    return String(reverse(take!(result)))
end

for (name, fen, depth, nodes) in POSITIONS
    b = isempty(fen) ? Bobby.setBoard() : Bobby.loadFen(fen)
    # warmup
    Bobby.perft(b, min(depth, 3))
    # benchmark
    trial = @benchmark Bobby.perft($b, $depth) seconds = 3 evals = 1
    med_ns = median(trial).time          # nanoseconds
    nps = round(Int, nodes / (med_ns / 1e9))
    @printf("%-22s  d%-4d  %15s  %9s NPS\n",
        name, depth,
        format_int(nodes),
        format_int(nps))
end
