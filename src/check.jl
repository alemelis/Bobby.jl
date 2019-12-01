function is_in_check(board::Bitboard, ui::UInt64, taken::UInt64)
    if ui & board.A[1] != EMPTY
        return true
    end
    if ui & board.A[2] != EMPTY
        return true
    end
    if ui & board.A[4] != EMPTY || ui & board.A[3] != EMPTY
        squares, edges = orthogonal_attack(taken, ui)
        for square in edges
            if board.R & square != EMPTY || board.Q & square != EMPTY
                return true
            end
        end
    end
    if ui & board.A[5] != EMPTY || ui & board.A[3] != EMPTY
        squares, edges = cross_attack(taken, ui)
        for square in edges
            if board.B & square != EMPTY || board.Q & square != EMPTY
                return true
            end
        end
    end
    return false
end


function is_in_check(chessboard::Chessboard, ui::UInt64, color::String)
    if color == "white"
        return is_in_check(chessboard.black, ui, chessboard.taken)
    else
        return is_in_check(chessboard.white, ui, chessboard.taken)
    end
end


function king_in_check(chessboard::Chessboard, color::String="white")
    if color == "white"
        if chessboard.white.K & chessboard.black_attacks == EMPTY
            return false
        end
        return is_in_check(chessboard, chessboard.white.K, color)
    else
        if chessboard.black.K & chessboard.white_attacks == EMPTY
            return false
        end
        return is_in_check(chessboard, chessboard.black.K, color)
    end
end
