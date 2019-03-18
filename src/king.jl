function gen_king_valid(source_square::UInt64)
    target_squares = zeros(UInt64, 0)

    for cms in zip(KING_MASK_FILES, KING_CLEAR_FILES, KING_SHIFTS)
        if source_square & cms[1] != EMPTY
            candidate_square = (source_square & cms[2]) << cms[3]
        else
            candidate_square = source_square << cms[3]
        end

        if candidate_square != EMPTY
            push!(target_squares, candidate_square)
        end
    end
    return target_squares
end


function gen_all_king_valid_moves()
    king_moves = Dict{UInt64, Array{UInt64,1}}()
    for i in 1:64
        king_moves[INT2UINT[i]] = gen_king_valid(INT2UINT[i])
    end
    return king_moves
end
const KING_MOVES = gen_all_king_valid_moves()


function get_current_king_valid(board::Bitboard, color::String="white")
    if color == "white"
        king = board.K
        same_color = board.white
        enemy_attack = board.black_attacks
    else
        king = board.k
        same_color = board.black
        enemy_attack = board.white_attacks
    end

    king_valid = Set()

    targets = KING_MOVES[king]
    for target in targets
        if target & same_color == EMPTY
            if target & enemy_attack == EMPTY
                push!(king_valid, (king, target))
            end
        end
    end
    return king_valid
end
