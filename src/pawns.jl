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

function movePawn(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.P[source] = false
		board.P[target] = true
		board.free[source] = true
		board.free[target] = false
		board.taken[source] = false
		board.taken[target] = true
		board.white[source] = false
		board.white[target] = true

		if board.black[target]
			board.black[target] = false
			if board.p[target]
				board.p[target] = false
			elseif board.r[target]
				board.r[target] = false
			elseif board.n[target]
				board.n[target] = false
			elseif board.b[target]
				board.b[target] = false
			elseif board.q[target]
				board.q[target] = false
			elseif board.k[target]
				throw(DomainError("black king in target square"))

		end
	else

	end
end