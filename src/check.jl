function checkCheck(board::Bitboard, color::String="white")
	if color == "white"
		king = board.K
		attacked = board.black_attacks
	elseif color == "black"
		king = board.k
		attacked = board.white_attacks
	end

	return any(king .& attacked)
end

function checkMate(board::Bitboard, lu_tabs::LookUpTables, color::String="white")
	if color == "white"
		king = board.K
	elseif color == "black"
		king = board.k
	end

	if !all(getKingValid(board, lu_tabs, color))
		return true
	else
		return false
	end
end