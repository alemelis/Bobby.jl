module Bobby
	
	export Bitboard
	using Printf
	using Crayons

	include("bitboard.jl")
	include("print.jl")

	include("moves.jl")
	include("pawns.jl")
	include("king.jl")
	include("queen.jl")
	include("nights.jl")
	include("rooks.jl")
	include("bishops.jl")

	include("magic.jl")
	include("check.jl")
	include("game.jl")

end