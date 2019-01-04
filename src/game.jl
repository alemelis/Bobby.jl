function play()
	b = buildBoard()
	l = buildLookUpTables()
	color = "white"
	opponent_color = "black"

	while true
		Bobby.prettyPrint(b)
		println("$color to move, enter source square and press enter")
		source = readline()
		if source == "q"
			break
		end
		println("enter target square and press enter")
		target = readline()
		try
			b, e = move(b, l, source, target, color)
			if e != ""
				@printf(Crayon(bold=true, foreground=:red), "%s ", e)
				@printf(Crayon(reset=true), "\n")
				continue
			end
		catch er
			@printf(Crayon(bold=true, foreground=:red), "%s ", er)
			@printf(Crayon(reset=true), "\n")
			continue
		end
		
		if checkCheck(b, opponent_color)
			if checkMate(b, l, opponent_color)
				@printf(Crayon(bold=true, foreground=:red), "%s ", "check mate!")
				@printf(Crayon(reset=true), "\n")
				Bobby.prettyPrint(b)
				break
			else
				@printf(Crayon(bold=true, foreground=:red), "%s ", "$opponent_color is in check!")
				@printf(Crayon(reset=true), "\n")
			end
		end

		color, opponent_color = changeColor(color, opponent_color)

	end
end

function changeColor(color, opponent_color)
	tmp_color = opponent_color
	opponent_color = color
	color = tmp_color
	return color, opponent_color
end

function move(board::Bitboard, lu_tabs::LookUpTables, source::String,
	target::String,	color::String="white")
	
	try
		# convert pgn to integer
		s = pgn2int(source)
		t = pgn2int(target)

		# find piece type to move
		s_piece_type = int2piece(board, s)

		checkSource(s, board)

		# check piece color
		checkColor(s_piece_type, color)

		# find valid moves
		validators = Dict()
		validators['k'] = getKingValid
		validators['p'] = getPawnsValid
		validators['q'] = getQueenValid
		validators['b'] = getBishopsValid
		validators['r'] = getRooksValid
		validators['n'] = getNightsValid
		valid_moves = validators[lowercase(s_piece_type)](board, lu_tabs, color)

		# check valid destination
		checkTarget(t, valid_moves)

		# check if the move leads to auto-check
		movers = Dict()
		movers['k'] = moveKing
		movers['p'] = movePawns
		movers['q'] = moveQueen
		movers['b'] = moveBishops
		movers['r'] = moveRooks
		movers['n'] = moveNights
		tmp_b = deepcopy(board)
		tmp_b = movers[lowercase(s_piece_type)](tmp_b, s, t, color)

	
		board = updateAttacked(tmp_b, lu_tabs, color)

		return board, ""
	catch e
		return board, e
	end
end

function checkSource(source_idx::Int64, board::Bitboard)
	if board.free[source_idx]
		throw(DomainError("empty source square"))
	end
end

function checkTarget(target_idx::Int64, valid_moves::BitArray{1})
	if !valid_moves[target_idx]
		throw(DomainError("target square not available"))
	end
end

function checkColor(s_piece_type::Char, color::String="white")
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