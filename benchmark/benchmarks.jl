using BenchmarkTools
using Bobby

b = Bobby.setBoard()
SUITE = BenchmarkGroup()
SUITE["perft"] = @benchmarkable Bobby.perft(b,2)
