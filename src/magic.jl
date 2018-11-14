function slideRook(rook_valid::BitArray{1}, same_color::BitArray{1},
					other_color::BitArray{1}, rook_idx::Int64, increment::Int64)
	current_idx = rook_idx + increment
	while current_idx >= 1 || current_idx <= 8
		if same_color[current_idx] == false
			rook_valid[current_idx] = true
			if other_color[current_idx] == false
				current_idx += increment
			else
				break
			end
		else
			break
		end
	end
	return rook_valid
end

function slideRook(same_color::BitArray{1}, other_color::BitArray{1}, rook_idx::Int64)
	rook_valid = falses(8)
	for increment in [1, -1]
		rook_valid = slideRook(rook_valid, same_color,
							other_color, rook_idx, increment)
	end
	return rook_valid
end