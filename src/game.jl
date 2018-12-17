function move(source::String, target::String, color::String)
	# convert pgn to integer
	s = pgn2int(source)
	t = pgn2int(target)

	# find piece type to move
end

function pgn2int(square::String)

	if length(square) != 2
		throw(DomainError("square name must be long 2"))
	end

	file = square[1]
	if !( file in "abcdefgh")
		throw(DomainError("the file should be in {a, ..., h}"))
	end
	f = Int(file) - 96

	rank = square[2]
	try
		rank = parse(Int, rank)
	catch err
		throw(ArgumentError("the rank should be an Int"))
	end

	if !( rank >= 1 && rank <= 8)
		throw(DomainError("the rank shoudl be in {1, ..., 8}"))
	end

	return f + (8 - rank)*8
end

function int2piece(board::Bitboard, idx::Int64)
	if board.free[idx]
		return ""
	elseif board.K[idx]
		return "K"
	elseif board.P[idx]
		return "P"
	elseif board.Q[idx]
		return "Q"
	elseif board.B[idx]
		return "B"
	elseif board.N[idx]
		return "N"
	elseif board.R[idx]
		return "R"
	elseif board.k[idx]
		return "k"
	elseif board.p[idx]
		return "p"
	elseif board.q[idx]
		return "q"
	elseif board.b[idx]
		return "b"
	elseif board.n[idx]
		return "n"
	elseif board.r[idx]
		return "r"
	end
end