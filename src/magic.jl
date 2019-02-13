function gen_rank_attacks()
    rank_attacks = Dict{UInt64, Array{UInt64,1}}()

    # all ranks but only the first file so far
    for i in 1:8
        ui = PGN2UINT[INT2PGN[1+8*(i-1)]]
        for n in 0:2^6-1

            rank_occupancy_mask_string = ("0"^8)^(i-1)*"0"
            rank_occupancy_mask_string *= reverse(bitstring(UInt64(n))[58:end])
            rank_occupancy_mask_string *= ("0"^8)^(8-i)

            rank_occupancy_mask = cvt_to_uint(rank_occupancy_mask_string)
            push!(rank_attacks, rank_occupancy_mask => slide_rank(
                rank_occupancy_mask, ui, MASK_RANKS[i]))
        end
    end
    return rank_attacks
end
RANK_ATTACKS = gen_rank_attacks()


function slide_rank(rank_occupancy_mask::UInt64, ui::UInt64, rank_mask::UInt64)
    direction = 1
    increment = 1
    moves = zeros(UInt64, 0)
    while true
        if (((ui >> increment) & rank_mask) != EMPTY &&
            rank_occupancy_mask & ((ui >> increment) & rank_mask) == EMPTY)

            push!(moves, ui >> increment)
            increment += direction
        else
            if direction == 1
                direction = -1
                increment = -1
            else
                return moves
            end
        end
    end
end
# TODO: check for borders

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
                if current_idx == 0 || current_idx == length(same_color) + 1
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

    piece_valid = falses(length(same_color))
    for increment in [1, -1]
        piece_valid = slidePiece(piece_valid, same_color,
            other_color, piece_idx, increment)
    end
    return piece_valid
end