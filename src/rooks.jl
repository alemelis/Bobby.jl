function getRooksValid(board::Bitboard, lu_tabs::LookUpTables,
	color::String="white")
	return getRooksValid(board, color)
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


function moveRooks(board::Bitboard, source::Int64, target::Int64,
	color::String="white")

	if color == "white"
		board.R[source] = false
		board.R[target] = true
		board = moveSourceTargetWhite(board, source, target)
	else
		board.r[source] = false
		board.r[target] = true
		board = moveSourceTargetBlack(board, source, target)
	end
	return board
end