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


"""
	getNightsValid(board::Bitboard, lu_tabs::LookUpTables, color="white")

Find valid squares for knights.
"""
function getNightsValid(board::Bitboard, lu_tabs::LookUpTables,
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

Find valid squares for rooks.
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

	rooks_valid = falses(64)

	#files
	for j = 1:8
		rooks_arr = rooks[j:8:64]
		if any(rooks_arr)
			same_arr = same[j:8:64]
			other_arr = other[j:8:64]
			for i = 1:8
				if rooks_arr[i]
					rooks_valid[j:8:64] .|= Bobby.slidePiece(same_arr,
						other_arr, i)
				end
			end
		end
	end

	#ranks
	for i = 1:8:64
		rooks_arr = rooks[i:i+7]
		if any(rooks_arr)
			same_arr = same[i:i+7]
			other_arr = other[i:i+7]
			for j = 1:8
				if rooks_arr[j]
					rooks_valid[i:i+7] .|= Bobby.slidePiece(same_arr,
						other_arr, j)
				end
			end
		end
	end

	return rooks_valid
end


"""
	getBishopsValid(board::Bitboard, color::String="white")

My implementation of 45-degrees rotated bitboards for bishops.
"""
function getBishopsValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")

	if color == "white"
		bishops = board.B
		same = board.white
		other = board.black
	elseif color == "black"
		bishops = board.b
		same = board.black
		other = board.white
	end

	bishops_no = sum.(Int.(bishops))
	bishops_seen = 0

	bishops_valid = falses(64)

	if bishops_no == 0
		return bishops_valid
	end

	for s in zip(lu_tabs.starts, lu_tabs.steps, lu_tabs.ends)
		bishops_on_diagonal = sum.(Int.(bishops[s[1]:s[2]:s[3]]))

		if bishops_on_diagonal != 0
			bishops_arr = bishops[s[1]:s[2]:s[3]]

			for j = 1:length(bishops_arr)
				if bishops_arr[j]
					bishops_seen += 1
					bishops_valid[s[1]:s[2]:s[3]] .|= Bobby.slidePiece(
						same[s[1]:s[2]:s[3]], other[s[1]:s[2]:s[3]], j)
				end
				if bishops_seen == bishops_no
					return bishops_valid
				end
			end
		end
	end
	return bishops_valid
end


function getQueenValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")
	
	if color == "white"
		queen = board.Q
		same = board.white
		other = board.black
	elseif color == "black"
		queen = board.q
		same = board.black
		other = board.white
	end

	queen_no = sum.(Int.(queen))

	queen_valid = falses(64)

	if queen_no == 0
		return queen_valid
	end

	for s in zip(lu_tabs.starts, lu_tabs.steps, lu_tabs.ends)
		queen_on_diagonal = sum.(Int.(queen[s[1]:s[2]:s[3]]))
		if queen_on_diagonal != 0
			queen_arr = queen[s[1]:s[2]:s[3]]
			for j = 1:length(queen_arr)
				if queen_arr[j]
					queen_valid[s[1]:s[2]:s[3]] .|= Bobby.slidePiece(
						same[s[1]:s[2]:s[3]], other[s[1]:s[2]:s[3]], j)
				end
			end
		end
	end
	
	#files
	for j = 1:8
		queen_arr = queen[j:8:64]
		if any(queen_arr)
			same_arr = same[j:8:64]
			other_arr = other[j:8:64]
			for i = 1:8
				if queen_arr[i]
					queen_valid[j:8:64] .|= Bobby.slidePiece(same_arr,
						other_arr, i)
				end
			end
		end
	end

	#ranks
	for i = 1:8:64
		queen_arr = queen[i:i+7]
		if any(queen_arr)
			same_arr = same[i:i+7]
			other_arr = other[i:i+7]
			for j = 1:8
				if queen_arr[j]
					queen_valid[i:i+7] .|= Bobby.slidePiece(same_arr,
						other_arr, j)
				end
			end
		end
	end

	return queen_valid
end


function getPawnsValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")

	if color == "white"
		pawns = board.P
		other = board.black
		increment = -8 #upward
	elseif color == "black"
		pawns = board.p
		other = board.white
		increment = +8 #downward
	end

	taken = board.taken

	pawns_valid = falses(64)

	for i = 1:64
		if pawns[i]
			# check the single space infront of the pawn
			front_square = i + increment
			if taken[front_square]
				continue
			else
				pawns_valid[front_square] = true
				# check double space if on home rank
				if (increment < 0 && pawns[i] & lu_tabs.mask_rank[i,2]) || 
					(increment > 0 && pawns[i] .& lu_tabs.mask_rank[i,7])
					double_square = front_square + increment
					if taken[double_square]
						continue
					else
						pawns_valid[double_square] = true
					end
				end
			end
		end
	end

	# check attacking squares
	if increment == -8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
	elseif increment == 8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 7
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 9
	end
	pawns_attack = pawns_lx_atk .& other
	pawns_attack .|= pawns_rx_atk .& other
	pawns_valid .|= pawns_attack
	
	return pawns_valid
end