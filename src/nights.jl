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

function moveNights(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.N[source] = false
		board.N[target] = true
		board = moveSourceTargetWhite(board, source, target)
	else
		board.n[source] = false
		board.n[target] = true
		board = moveSourceTargetBlack(board, source, target)
	end
	return board
end