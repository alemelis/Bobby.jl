same_color = falses(8)
same_color[6] = true
other_color = falses(8)
other_color[2] = true
rook_pos = 4
rook_valid_gt1 = [0, 1, 1, 0, 1, 0, 0, 0]
rook_valid_array1 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array1) .== rook_valid_gt1)

same_color = falses(8)
same_color[6] = true
other_color = falses(8)
rook_pos = 1
rook_valid_gt2 = [0, 1, 1, 1, 1, 0, 0, 0]
rook_valid_array2 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array2) .== rook_valid_gt2)

same_color = falses(8)
other_color = falses(8)
other_color[6] = true
rook_pos = 1
rook_valid_gt3 = [0, 1, 1, 1, 1, 1, 0, 0]
rook_valid_array3 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array3) .== rook_valid_gt3)

same_color = falses(8)
same_color[1] = true
other_color = falses(8)
other_color[8] = true
rook_pos = 2
rook_valid_gt4 = [0, 0, 1, 1, 1, 1, 1, 1]
rook_valid_array4 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array4) .== rook_valid_gt4)

same_color = falses(8)
other_color = falses(8)
other_color[2] = true
other_color[4] = true
rook_pos = 7
rook_valid_gt5 = [0, 0, 0, 1, 1, 1, 0, 1]
rook_valid_array5 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array5) .== rook_valid_gt5)

same_color = falses(8)
other_color = falses(8)
rook_pos = 5
rook_valid_gt6 = [1, 1, 1, 1, 0, 1, 1, 1]
rook_valid_array6 = Bobby.slideRook(same_color, other_color, rook_pos)
@test all(Int.(rook_valid_array5) .== rook_valid_gt5)