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


function moveBishops(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.B[source] = false
		board.B[target] = true
		board = moveSourceTargetWhite(board, source, target)
	else
		board.b[source] = false
		board.b[target] = true
		board = moveSourceTargetBlack(board, source, target)
	end
	return board
end