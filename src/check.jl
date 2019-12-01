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


function square_in_check(board::Bitboard, ui::UInt64, color::String="white")
    if color == "white"
        if ui & board.a[1] != EMPTY
            return true
        end
        if ui & board.a[2] != EMPTY
            return true
        end
        if ui & board.a[4] != EMPTY || ui & board.a[3] != EMPTY
            squares, edges = orthogonal_attack(board.taken, ui)
            for rook in board.r
                if rook in edges
                    return true
                end
            end
            for queen in board.q
                if queen in edges
                    return true
                end
            end
        end
        if ui & board.a[5] != EMPTY || ui & board.a[3] != EMPTY
            squares, edges = cross_attack(board.taken, ui)
            for bishop in board.b
                if bishop in edges
                    return true
                end
            end
            for queen in board.q
                if queen in edges
                    return true
                end
            end
        end
        return false
    else
        if ui & board.A[1] != EMPTY
            return true
        end
        if ui & board.A[2] != EMPTY
            return true
        end
        if ui & board.A[4] != EMPTY || ui & board.A[3] != EMPTY
            squares, edges = orthogonal_attack(board.taken, ui)
            for rook in board.R
                if rook in edges
                    return true
                end
            end
            for queen in board.Q
                if queen in edges
                    return true
                end
            end
        end
        if ui & board.A[5] != EMPTY || ui & board.A[3] != EMPTY
            squares, edges = cross_attack(board.taken, ui)
            for bishop in board.B
                if bishop in edges
                    return true
                end
            end
            for queen in board.Q
                if queen in edges
                    return true
                end
            end
        end
        return false
    end
end


function check_mate(board::Bitboard, color::String="white")
    if color == "white"
        king = board.K
    else
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
