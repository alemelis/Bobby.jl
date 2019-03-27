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
            occupancy_rank = MASK_RANKS[i] & board
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
            occupancy_file = transpose_uint(MASK_FILES[i]&board)

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


function get_rooks_valid(board::Bitboard, color::String="white")
    if color == "white"
        rooks = board.R
        same = board.white
        other = board.black
    elseif color == "black"
        rooks = board.r
        same = board.black
        other = board.white
    end

    rook_moves = zeros(UInt64, 0)
    rook_edges = zeros(UInt64, 0)
    for rook in rooks
        moves, edges = orthogonal_attack(board.taken, rook)
        append!(rook_moves, moves)
        for edge in edges
            if edge & same == EMPTY
                append!(rook_moves, edge)
            end
        end
    end
    return rook_moves
end


function get_rooks_valid_list(board::Bitboard, color::String="white")
    if color == "white"
        rooks = board.R
        same = board.white
        other = board.black
    elseif color == "black"
        rooks = board.r
        same = board.black
        other = board.white
    end

    rook_moves = Set()
    for rook in rooks
        moves, edges = orthogonal_attack(board.taken, rook)
        for move in moves
            push!(rook_moves, (rook, move))
        end
        for edge in edges
            if edge & same == EMPTY
                push!(rook_moves, (rook, edge))
            end
        end
    end
    return rook_moves
end
