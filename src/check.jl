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