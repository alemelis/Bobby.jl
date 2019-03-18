# https://web.archive.org/web/20180109042730/http://www.rivalchess.com/magic-bitboards/
function gen_rook_mask(i::Int64)
    pgn = INT2PGN[i]

    file = Int(pgn[1]) - 96
    rank = parse(Int, pgn[2])

    mask = xor(MASK_FILES[file], MASK_RANKS[rank])

    if INT2UINT[i] & FRAME != EMPTY # rook on the board frame
        if INT2UINT[i] & CORNERS != EMPTY # rook on a corner
            return mask & ~CORNERS
        else
            if file == 1
                return mask & CLEAR_RANK_1 & CLEAR_RANK_8 & CLEAR_FILE_H
            elseif file == 8
                return mask & CLEAR_RANK_1 & CLEAR_RANK_8 & CLEAR_FILE_A
            elseif rank == 1
                return mask & CLEAR_FILE_A & CLEAR_FILE_H & CLEAR_RANK_8
            elseif rank == 8
                return mask & CLEAR_FILE_A & CLEAR_FILE_H & CLEAR_RANK_1
            end
        end
    else
        return mask & ~FRAME # rook in the middle of the board
    end
end


function gen_rook_masks()
    rook_masks = Dict{UInt64, UInt64}()
    for i in 1:64
        rook_masks[INT2UINT[i]] = gen_rook_mask(i)
    end
    return rook_masks
end
const ROOK_MASKS = gen_rook_masks()


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
