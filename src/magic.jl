function slide_rank(rank_occupancy_mask::UInt64, ui::UInt64, rank_mask::UInt64)
    direction = 1
    increment = 1
    moves = zeros(UInt64, 0)
    edges = zeros(UInt64, 0)
    while true
        if ((ui >> increment) & rank_mask) != EMPTY
            if rank_occupancy_mask & ((ui >> increment) & rank_mask) == EMPTY

                push!(moves, ui >> increment)
                increment += direction
            else
                push!(edges, ui >> increment)

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
                return (moves, edges)
            end
        end
    end
end


function gen_rank_attacks_from_file_x(file::Int64=1)
    rank_attacks = Dict{UInt64, Array{UInt64,1}}()
    rank_edges = Dict{UInt64, Array{UInt64,1}}()

    for i in 1:8
        pgn = INT2PGN[1+8*(i-1)]
        rank = parse(Int64, pgn[2])
        ui = PGN2UINT[pgn]

        for n in 0:2^6-1
            rank_occupancy_mask_string = ("0"^8)^(i-1)*"0"
            pieces = reverse(bitstring(UInt64(n))[58:end])
            if file in [2, 3, 4, 5, 6, 7]
                new_pieces = ""
                for j in 1:6
                    if j == file-1
                        new_pieces *= "0"
                    else
                        new_pieces *= pieces[j]
                    end
                end
                rank_occupancy_mask_string *= new_pieces
            else
                rank_occupancy_mask_string *= pieces
            end
            rank_occupancy_mask_string *= ("0"^8)^(8-i)

            rank_occupancy_mask = cvt_to_uint(rank_occupancy_mask_string)
            sr = slide_rank(rank_occupancy_mask, ui >> (file-1),
                MASK_RANKS[rank])

            if ~isempty(sr[1])
                push!(rank_attacks, rank_occupancy_mask => sr[1])
            end
            
            if ~isempty(sr[2])
                push!(rank_edges, rank_occupancy_mask => sr[2])
            end
        end
    end
    return (rank_attacks, rank_edges)
end
RANK_ATTACKS_FILE_A = gen_rank_attacks_from_file_x()




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