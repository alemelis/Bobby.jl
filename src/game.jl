function move(board::Bitboard, lu_tabs::LookUpTables, source::String,
	target::String,	color::String="white")

	# convert pgn to integer
	s = pgn2int(source)
	t = pgn2int(target)

	# find piece type to move
	s_piece_type = int2piece(board, s)

	# check piece color
	checkColor(s_piece_type, color)

	# find valid moves
	movers = Dict()
	movers['k'] = getKingValid
	movers['p'] = getPawnsValid
	movers['q'] = getQueenValid
	movers['b'] = getBishopsValid
	movers['r'] = getRooksValid
	movers['n'] = getNightsValid
	valid_moves = movers[lowercase(s_piece_type)](board, lu_tabs, color)

	# check valid destination
	checkDestination(t, valid_moves)

	# check if the move leads to auto-check
	tmp_b = deepcopy(board)



end


function checkDestination(target_idx::Int64, valid_moves::BitArray{1})
	if !valid_moves[target_idx]
		throw(DomainError("target square not available"))
	end
end

function checkColor(s_piece_type::Char, color::String)
	if color == "white"
		if !isuppercase(s_piece_type)
			throw(ErrorException("it's white to move!"))
		end
	else
		if isuppercase(s_piece_type)
			throw(ErrorException("it's black to move!"))
		end
	end
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
		return ' '
	elseif board.K[idx]
		return 'K'
	elseif board.P[idx]
		return 'P'
	elseif board.Q[idx]
		return 'Q'
	elseif board.B[idx]
		return 'B'
	elseif board.N[idx]
		return 'N'
	elseif board.R[idx]
		return 'R'
	elseif board.k[idx]
		return 'k'
	elseif board.p[idx]
		return 'p'
	elseif board.q[idx]
		return 'q'
	elseif board.b[idx]
		return 'b'
	elseif board.n[idx]
		return 'n'
	elseif board.r[idx]
		return 'r'
	end
end