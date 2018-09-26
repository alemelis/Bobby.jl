"""
	getKingValid(board::Bitboard, lu_tabs::Bobby.LookUpTables, color="white")

Find valid squares for king.
"""
function getKingValid(board::Bitboard, lu_tabs::Bobby.LookUpTables,
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

		# update valid squares
		king_valid .= king_valid .| (.~pieces .& shifted_king)
	end

	return king_valid
end


# doesn't work....yet!
function getAttackedByRooks(board::Bitboard, lu_tabs::Bobby.LookUpTables,
							color::String="white")
	if color == "white"
		rooks = board.R
	elseif color == "black"
		rooks = board.r
	end

	# if no rooks are on the board, return all falses
	if (all(rooks) .== false)
		return rooks
	end

	square_rooks = transpose(reshape(rooks, 8, :))

	attacked = falses(64)
	for i = 1:8
		for j = 1:8
			if square_rooks[i,j]
				attacked = attacked .| lu_tabs.mask_rank[:,i]
				attacked = attacked .| lu_tabs.mask_file[:,j]
			end
		end
	end
	return attacked
end