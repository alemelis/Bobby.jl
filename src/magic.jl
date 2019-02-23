function slide_diagonal(board::UInt64, diag_mask::UInt64, ui::UInt64,
    compass_direction::String="NW")

    if compass_direction == "NW"
        increment_mod = 9
    else
        increment_mod = 7
    end
    direction = 1
    increment = direction*increment_mod

    moves = zeros(UInt64, 0)
    edges = zeros(UInt64, 0)

    while true
        if ((ui >> increment) & diag_mask) != EMPTY # we are on the diagonal
            if (board & ((ui>>increment) & diag_mask) == EMPTY &&
                ((ui>>increment) & diag_mask) != EMPTY)

                push!(moves, ui>>increment)
                increment += direction*increment_mod
            else
                push!(edges, ui>>increment)

                if direction == 1
                    direction = -1
                    increment = increment_mod*direction
                else
                    return moves, edges
                end
            end
        else
            if direction == 1
                direction = -1
                increment = increment_mod*direction
            else
                return moves, edges
            end
        end
    end
end


function diagonal_attack(board::UInt64, ui::UInt64)
    for i in 1:15
        if DIAGONALS[i] & ui != EMPTY
            return slide_diagonal(board, DIAGONALS[i], ui, "NW")
        end
    end
end

function antidiagonal_attack(board::UInt64, ui::UInt64)
    for i in 1:15
        if ANTIDIAGONALS[i] & ui != EMPTY
            return slide_diagonal(board, ANTIDIAGONALS[i], ui, "NE")
        end
    end
end


function cross_attack(board::UInt64, ui::UInt64)
    moves, edges = diagonal_attack(board, ui)
    anti_moves, anti_edges = antidiagonal_attack(board, ui)

    for move in anti_moves
        push!(moves, move)
    end

    for edge in anti_edges
        push!(edges, edge)
    end

    return moves, edges
end



function slide_rank(rank_occupancy_mask::UInt64, ui::UInt64, shift::Int64)
    direction = 1
    increment = 1
    moves = zeros(UInt64, 0)
    edges = zeros(UInt64, 0)
    ui = ui >> shift
    rank_occupancy_mask = rank_occupancy_mask >> shift
    while true
        if ((ui >> increment) & MASK_RANK_1) != EMPTY
            if (rank_occupancy_mask & ((ui >> increment) & MASK_RANK_1) == EMPTY 
                && ((ui >> increment) & CLEAR_FILE_A & CLEAR_FILE_H) != EMPTY)

                push!(moves, (ui >> increment) << shift)
                increment += direction
            else
                push!(edges, (ui >> increment) << shift)

                if direction == 1
                    direction = -1
                    increment = -1
                else
                    return (moves, edges)
                end
            end
        else
            if direction == 1
                direction = -1
                increment = -1
            else
                return moves, edges
            end
        end
    end
end


function rank_attack(board::UInt64, ui::UInt64)
    for i in 1:8
        if MASK_RANKS[i] & ui != EMPTY
            occupancy_rank = ROOK_MASKS[ui] & MASK_RANKS[i] & board
            shift = RANK_SHIFTS[i]
            return slide_rank(occupancy_rank, ui, shift)
        end
    end
end


# https://www.hackersdelight.org/hdcodetxt/transpose8.c.txt
function transpose_uint(x::UInt64)
    y = (x & 0x8040201008040201) |
        (x & 0x0080402010080402) << 7  |
        (x & 0x0000804020100804) << 14 |
        (x & 0x0000008040201008) << 21 |
        (x & 0x0000000080402010) << 28 |
        (x & 0x0000000000804020) << 35 |
        (x & 0x0000000000008040) << 42 |
        (x & 0x0000000000000080) << 49 |
        (x >> 7) & 0x0080402010080402  |
        (x >> 14) & 0x0000804020100804 |
        (x >> 21) & 0x0000008040201008 |
        (x >> 28) & 0x0000000080402010 |
        (x >> 35) & 0x0000000000804020 |
        (x >> 42) & 0x0000000000008040 |
        (x >> 49) & 0x0000000000000080
    return y
end


function file_attack(board::UInt64, ui::UInt64)
    for i in 1:8 # A to H
        if MASK_FILES[i] & ui != EMPTY
            occupancy_file = transpose_uint(ROOK_MASKS[ui]&MASK_FILES[i]&board)

            shift = FILE_SHIFTS[i]
            mvs, edgs = slide_rank(occupancy_file, transpose_uint(ui), shift)
            
            for k in 1:length(mvs)
                mvs[k] = transpose_uint(mvs[k])
            end
            
            for k in 1:length(edgs)
                edgs[k] = transpose_uint(edgs[k])
            end
            
            return mvs, edgs
        end
    end
end


function orthogonal_attack(board::UInt64, ui::UInt64)
    rank_moves, rank_edges = rank_attack(board, ui)
    file_moves, file_edges = file_attack(board, ui)

    for m in file_moves
        push!(rank_moves, m)
    end
    for e in file_edges
        push!(rank_edges, e)
    end
    return rank_moves, rank_edges

end


function star_attack(board::UInt64, ui::UInt64)
    ortho_moves, ortho_edges = orthogonal_attack(board, ui)
    cross_moves, cross_edges = cross_attack(board, ui)

    for m in cross_moves
        push!(ortho_moves, m)
    end
    for e in cross_edges
        push!(ortho_edges, e)
    end
    return ortho_moves, ortho_edges

end

#----

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