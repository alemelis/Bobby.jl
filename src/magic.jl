"""
	slidePiece(piece_valid::BitArray{1}, same_color::BitArray{1},
			other_color::BitArray{1}, piece_idx::Int64, increment::Int64)

Find valid squares in file/rank/diagonal for a sliding piece given its
position. This function looks only to the left/right of the piece as 
indicated by the sign of `increment` variable.
"""
function slidePiece(piece_valid::BitArray{1}, same_color::BitArray{1},
			other_color::BitArray{1}, piece_idx::Int64, increment::Int64)
	current_idx = piece_idx + increment
	if current_idx == 0 || current_idx == length(same_color) + 1
		return piece_valid
	end
	while true
		if same_color[current_idx] == false
			piece_valid[current_idx] = true
			if other_color[current_idx] == false
				current_idx += increment
				if current_idx == 0 || current_idx == 9
					break
				end
			else
				break
			end
		else
			break
		end
	end
	return piece_valid
end


"""
	slidePiece(same_color::BitArray{1}, other_color::BitArray{1},
		piece_idx::Int64)

Find valid squares in a rank/file/diagonal for a sliding piece given
its position. The piece position is slided rightward and leftward 
and same/other color pieces position is checked.

This function can be used to brute force generate sliding piece
positions to be magic-hashed.
"""
function slidePiece(same_color::BitArray{1}, other_color::BitArray{1},
			piece_idx::Int64)
	piece_valid = falses(8)
	for increment in [1, -1]
		piece_valid = slidePiece(piece_valid, same_color,
							other_color, piece_idx, increment)
	end
	return piece_valid
end