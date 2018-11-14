same_color = falses(8)
same_color[6] = true
other_color = falses(8)
other_color[2] = true
rook_pos = 4
rook_valid_gt = [0, 1, 1, 0, 1, 0, 0, 0]
rook_valid_array = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array) .== rook_valid_gt)