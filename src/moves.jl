function testKing(board::Bitboard, lu_tabs::LookUpTables, color="white")

	if color == "white"
		king = board.K
		pieces = board.white
	elseif colot == "black"
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

	king_valid = .~pieces

	shifts = [9, 8, 7, -1, -9, -8, -7, 1]
	for i = 1:8
		if i in [1, 8, 7] & clear_file == "A"
			cleared_king = king .& lu_tabs.clear_file[:,1]
		elseif i in [3, 4, 5] & clear_file == "H"
			cleared_king = king .& lu_tabs.clear_file[:,8]
		else
			cleared_king = king
		end
		shifted_king = cleared_king << shifts[i]
		king_valid .= king_valid .| shifted_king
	end

	return king_valid
end