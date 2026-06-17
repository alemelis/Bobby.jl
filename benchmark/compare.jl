using BenchmarkTools
using Bobby
using Chess
using Printf

# ---------------------------------------------------------------------------
# Side-by-side perft NPS comparison: Bobby.jl vs Chess.jl
#
# Run with:
#   julia --check-bounds=no -O3 --project=benchmark benchmark/compare.jl
# ---------------------------------------------------------------------------

const POSITIONS = [
    ("Starting position", "", 6, 119_060_324),
    ("Kiwipete", "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0", 5, 193_690_690),
    ("Position 3", "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1", 6, 11_030_083),
    ("Position 4", "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1", 5, 15_833_292),
    ("Position 5", "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8", 5, 89_941_194),
    ("Position 6", "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10", 5, 164_075_551),
]

function format_int(n::Integer)
    s = string(n)
    result = IOBuffer()
    for (i, c) in enumerate(reverse(s))
        i > 1 && (i - 1) % 3 == 0 && write(result, ',')
        write(result, c)
    end
    return String(reverse(take!(result)))
end

bobby_board(fen) = isempty(fen) ? Bobby.setBoard() : Bobby.loadFen(fen)
chess_board(fen) = isempty(fen) ? Chess.startboard() : Chess.fromfen(fen)

# ---------------------------------------------------------------------------
# Correctness check
# ---------------------------------------------------------------------------
println("Verifying node counts...")
for (name, fen, depth, expected) in POSITIONS
    bb = bobby_board(fen)
    cb = chess_board(fen)
    bobby_nodes = Bobby.perft(bb, depth).nodes[depth]
    chess_nodes = Chess.perft(cb, depth)
    bobby_ok = bobby_nodes == expected ? "✓" : "✗ ($bobby_nodes)"
    chess_ok = chess_nodes == expected ? "✓" : "✗ ($chess_nodes)"
    println("  $name d$depth — Bobby: $bobby_ok  Chess: $chess_ok")
end
println()

# ---------------------------------------------------------------------------
# Benchmark
# ---------------------------------------------------------------------------
println("Benchmarking (median of BenchmarkTools trials, 3s window each)...")
println()
@printf("%-22s  %5s  %15s  %15s  %15s  %10s\n",
    "Position", "Depth", "Nodes", "Bobby NPS", "Chess NPS", "Bobby/Chess")
println("-"^96)

ratios = Float64[]
for (name, fen, depth, nodes) in POSITIONS
    bb = bobby_board(fen)
    cb = chess_board(fen)
    Bobby.perft(bb, min(depth, 3))
    Chess.perft(cb, min(depth, 3))

    bobby_trial = @benchmark Bobby.perft($bb, $depth) seconds = 3 evals = 1
    chess_trial = @benchmark Chess.perft($cb, $depth) seconds = 3 evals = 1

    bobby_nps = round(Int, nodes / (median(bobby_trial).time / 1e9))
    chess_nps = round(Int, nodes / (median(chess_trial).time / 1e9))
    ratio = bobby_nps / chess_nps
    push!(ratios, ratio)

    @printf("%-22s  d%-4d  %15s  %11s NPS  %11s NPS  %9.2fx\n",
        name, depth,
        format_int(nodes),
        format_int(bobby_nps),
        format_int(chess_nps),
        ratio)
end

println("-"^96)
geomean = exp(sum(log, ratios) / length(ratios))
@printf("Geometric-mean ratio Bobby/Chess: %.2fx across %d positions\n",
    geomean, length(ratios))
