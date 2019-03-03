function check_check(board::Bitboard, color::String="white")
    if color == "white"
        if board.K & board.black_attacks != EMPTY
            return true
        end
    else
        if board.k & board.white_attacks != EMPTY
            return true
        end
    end
    return false
end

function check_mate(board::Bitboard, color::String="white")
    if color == "white"
        king = board.K
    elseif color == "black"
        king = board.k
    end

    if length(get_current_king_valid(board, color)) != 0
        return false
    else
        if length(get_all_valid_moves(board, color)) == 0
            return true
        else
            return false
        end
    end
end
