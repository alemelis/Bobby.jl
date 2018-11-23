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

		# update valid squares with opposite color pieces
		king_valid .= king_valid .| (.~pieces .& shifted_king)
	end

	return king_valid
end


"""
	getNightsValid(board::Bitboard, lu_tabs::Bobby.LookUpTables, color="white")

Find valid squares for knights.
"""
function getNightsValid(board::Bitboard, lu_tabs::Bobby.LookUpTables,
					  color::String="white")

	if color == "white"
		nights = board.N
		pieces = board.white
	elseif color == "black"
		nights = board.n
		pieces = board.black
	end

	spot_1 = (nights .& lu_tabs.clear_night_files[:,1]) << 10
	spot_2 = (nights .& lu_tabs.clear_night_files[:,2]) << 17
	spot_3 = (nights .& lu_tabs.clear_night_files[:,3]) << 15
	spot_4 = (nights .& lu_tabs.clear_night_files[:,4]) << 6

	spot_5 = (nights .& lu_tabs.clear_night_files[:,5]) >> 10
	spot_6 = (nights .& lu_tabs.clear_night_files[:,6]) >> 17
	spot_7 = (nights .& lu_tabs.clear_night_files[:,7]) >> 15
	spot_8 = (nights .& lu_tabs.clear_night_files[:,8]) >> 6

	nights_valid = spot_1 .| spot_2 .| spot_3 .| spot_4 .|
				   spot_5 .| spot_6 .| spot_7 .| spot_8

	return nights_valid .& .~pieces
end


"""
	getRooksValid(board::Bitboard, color::String="white")

Find valid dquares for rooks.
"""
function getRooksValid(board::Bitboard, color::String="white")
	if color == "white"
		rooks = board.R
		same = board.white
		other = board.black
	elseif color == "black"
		rooks = board.r
		same = board.black
		other = board.white
	end

	rooks_valid_board = falses(64)

	rooks_square = transpose(reshape(rooks, 8, :))

	#ranks
	for i = 1:7
		if any(rooks_square[i,:])
			if i == 1
				src_i = i
			else
				src_i = (i-1)*8+1
			end
			same_color = same[src_i:src_i+7]
			other_color = other[src_i:src_i+7]
			for j = 1:8
				if rooks_square[i,j]
					rook_idx = j
					rooks_valid = Bobby.slidePiece(same_color, other_color, rook_idx)
					rooks_valid_board[src_i:src_i+7] .|= rooks_valid
				end
			end
		end
	end

	#files
	for j = 1:8
		if any(rooks_square[:,j])
			same_color = same[j:8:end]
			other_color = other[j:8:end]

			for i = 1:8
				if rooks_square[i,j]
					rook_idx = i
					rooks_valid = Bobby.slidePiece(same_color, other_color, rook_idx)
					rooks_valid_board[j:8:end] .|= rooks_valid
				end
			end
		end
	end
	return rooks_valid_board
end


"""
	getBishopsValid(board::Bitboard, color::String="white")

My implementation of 45-degrees rotated bitboards for bishops.
"""
function getBishopsValid(board::Bitboard, color::String="white")
	if color == "white"
		bishops = board.B
		same = board.white
		other = board.black
	elseif color == "black"
		bishops = board.b
		same = board.black
		other = board.white
	end

	bishops_no = sum.(Int.(same))
	bishops_seen = 0

	bishops_valid = falses(64)

	if bishops_no == 0
		return bishops_valid
	end

	# TODO: move these into LookUpTables
	# white squares
	starts = [1,  7,  16, 17, 3,  5,  32, 33, 5,  49, 7,  3,  48]
	steps =  [9,  7,  7,  9,  9,  7,  7,  9,  9,  9,  9,  7,  7]
	ends =   [64, 49, 58, 62, 48, 33, 60, 60, 32, 58, 16, 17, 62]

	# black squares
	append!(starts, [8,  2,  9,  6,  24, 4,  25, 4,  40, 6,  2, 56, 41])
	append!(steps,  [7,  9,  9,  7,  7,  9,  9,  7,  7,  9,  7, 7,  9])
	append!(ends,   [57, 56, 63, 41, 59, 40, 61, 25, 61, 24, 9, 63, 59])

	for s in zip(starts, steps, ends)
		bishops_on_diagonal = sum.(Int.(bishops[s[1]:s[2]:s[3]]))

		if bishops_on_diagonal != 0
			bishops_arr = bishops[s[1]:s[2]:s[3]]

			for j = 1:length(bishops_arr)
				if bishops_arr[j]
					bishops_seen += 1
					valid_array = Bobby.slidePiece(same[s[1]:s[2]:s[3]],
												   other[s[1]:s[2]:s[3]], j)
					bishops_valid[s[1]:s[2]:s[3]] .|= valid_array
				end
				if bishops_seen == bishops_no
					return bishops_valid
				end
			end
		end
	end
end