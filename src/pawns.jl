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

	pawns_valid .|= getPawnsAttackTaken(board, lu_tabs, color)
	
	return pawns_valid
end


function getPawnsAttackTaken(board::Bitboard, lu_tabs::LookUpTables,
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

	# check attacking squares
	if increment == -8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
	elseif increment == 8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 9
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 7
	end
	pawns_attack = pawns_lx_atk .& other
	pawns_attack .|= pawns_rx_atk .& other

	return pawns_attack
end


function getPawnsAttackGeneric(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")
	if color == "white"
		pawns = board.P
		same = board.white
		increment = -8 #upward
	elseif color == "black"
		pawns = board.p
		same = board.black
		increment = +8 #downward
	end

	# check attacking squares
	if increment == -8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
	elseif increment == 8
		pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 9
		pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 7
	end
	pawns_attack = pawns_lx_atk  .& .~same
	pawns_attack .|= pawns_rx_atk  .& .~same

	return pawns_attack
end


function movePawns(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.P[source] = false
		board.P[target] = true
		board = moveSourceTargetWhite(board, source, target)
	else
		board.p[source] = false
		board.p[target] = true
		board = moveSourceTargetBlack(board, source, target)
	end
	return board
end