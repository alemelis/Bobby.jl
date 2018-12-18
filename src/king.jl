"""
	getKingValid(board::Bitboard, lu_tabs::LookUpTables, color="white")

Find valid squares for king.
"""
function getKingValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")

	if color == "white"
		king = board.K
		pieces = board.white
	elseif color == "black"
		king = board.k
		pieces = board.black
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
	end

	return king_valid
end


function moveKing(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.K[source] = false
		board.K[target] = true
		board = moveSourceTargetWhite(board, source, target)
	else
		board.k[source] = false
		board.k[target] = true
		board = moveSourceTargetBlack(board, source, target)
	end
	return board
end