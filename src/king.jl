"""
	getKingValid(board::Bitboard, lu_tabs::LookUpTables, color="white")

Find valid squares for king.
"""
function getKingValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")

	if color == "white"
		king = board.K
		pieces = board.white
		opponent_attacks = board.black_attacks
		short_castling = board.white_OO
		long_castling = board.white_OOO
	elseif color == "black"
		king = board.k
		pieces = board.black
		opponent_attacks = board.white_attacks
		short_castling = board.black_OO
		long_castling = board.black_OOO
	end

	#check if king is on file A or H
	if any(lu_tabs.mask_file[:,1] .& king)
		clear_file = "A"
	elseif any(lu_tabs.mask_file[:,8] .& king)
		clear_file = "H"
	else
		clear_file = "none"
	end

	# no valid squares have been found yet
	king_valid = falses(64)

	# generate possible moves without considering opposite color pieces
	shifts = [9, 8, 7, -1, -9, -8, -7, 1]
	for i = 1:8
		# clear A and H files if king on those
		if (i in [1, 8, 7]) & (clear_file == "A")
			cleared_king = king .& lu_tabs.clear_file[:,1]
		elseif (i in [3, 4, 5]) & (clear_file == "H")
			cleared_king = king .& lu_tabs.clear_file[:,8]
		else
			cleared_king = king
		end

		# shift king position
		shifted_king = cleared_king << shifts[i]

		# update valid squares with opposite color pieces
		king_valid .= king_valid .| (.~pieces .& shifted_king)

		# don't go on attacked squares
		king_valid .= king_valid .& .~opponent_attacks
	end

	# add castling
	if color == "white"
		if short_castling
			king_valid[63] = true
		end
		if long_castling
			king_valid[59] = true
		end
	else
		if short_castling
			king_valid[7] = true
		end
		if long_castling
			king_valid[3] = true
		end
	end

	return king_valid
end


function moveKing(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.K[source] = false
		board.K[target] = true
		board = moveSourceTargetWhite(board, source, target)

		board.white_king_moved = true

		# castling
		if source == 61 && target == 63 #short
			board = moveRook(board, 64, 62)
			board.white_castled = true
		elseif source == 61 && target == 59 #long
			board = moveRook(board, 57, 60)
			board.white_castled = true
		end
	else
		board.k[source] = false
		board.k[target] = true
		board = moveSourceTargetBlack(board, source, target)

		board.black_king_moved = true

		if source == 5 && target == 7
			board = moveRook(board, 8, 6)
		elseif source == 5 && target == 3
			board = moveRook(board, 1, 4)
		end
	end
	return board
end


function updateCastling(board::Bitboard)

	if board.white_king_moved
		board.white_OO = false
		board.white_OOO = false
	else
		if (!board.h1_rook_moved && all(board.free[62:63]) && 
			all(board.black_attacks[62:63] .== false))
			board.white_OO = true
		else
			board.white_OO = false
		end

		if (!board.a1_rook_moved && all(board.free[58:60]) && 
			all(board.black_attacks[58:60] .== false))
			board.white_OOO = true
		else
			board.white_OOO = false
		end
	end

	if board.black_king_moved
		board.black_OO = false
		board.black_OOO = false
	else
		if (!board.a8_rook_moved && all(board.free[2:4]) && 
			all(board.white_attacks[2:4] .== false))
			board.black_OOO = true
		else
			board.black_OOO = false
		end

		if (!board.h8_rook_moved && all(board.free[6:7]) && 
			all(board.white_attacks[6:7] .== false))
			board.black_OO = true
		else
			board.black_OO = false
		end
	end

	return board
end