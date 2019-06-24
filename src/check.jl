function is_in_check(chessboard::Chessboard, ui::UInt64, color::String)
    if color == "white"
        if ui & chessboard.black.A[1] != EMPTY
            return true
        end
        if ui & chessboard.black.A[2] != EMPTY
            return true
        end
        if ui & chessboard.black.A[4] != EMPTY ||
         ui & chessboard.black.A[3] != EMPTY
            squares, edges = orthogonal_attack(chessboard.taken, ui)
            for square in edges
                if chessboard.black.R & square != EMPTY || 
                    chessboard.black.Q & square != EMPTY
                    return true
                end
            end
        end
        if ui & chessboard.black.A[5] != EMPTY ||
         ui & chessboard.black.A[3] != EMPTY
            squares, edges = cross_attack(chessboard.taken, ui)
            for square in edges
                if chessboard.black.B & square != EMPTY || 
                    chessboard.black.Q & square != EMPTY
                    return true
                end
            end
        end
        return false
    else
        if ui & chessboard.white.A[1] != EMPTY
            return true
        end
        if ui & chessboard.white.A[2] != EMPTY
            return true
        end
        if ui & chessboard.white.A[4] != EMPTY ||
         ui & chessboard.white.A[3] != EMPTY
            squares, edges = orthogonal_attack(chessboard.taken, ui)
            for square in edges
                if chessboard.white.R & square != EMPTY || 
                    chessboard.white.Q & square != EMPTY
                    return true
                end
            end
        end
        if ui & chessboard.white.A[5] != EMPTY ||
         ui & chessboard.white.A[3] != EMPTY
            squares, edges = cross_attack(chessboard.taken, ui)
            for square in edges
                if chessboard.white.B & square != EMPTY || 
                    chessboard.white.Q & square != EMPTY
                    return true
                end
            end
        end
        return false
    end
end


function king_in_check(chessboard::Chessboard, color::String="white")
    if color == "white"
        if chessboard.white.K & chessboard.black_attacks == EMPTY
            return false
        end
    else
        if chessboard.black.k & chessboard.white_attacks == EMPTY
            return false
        end
    end
    return kingtrace(chessboard, color)
end


function king_in_check(board::Bitboard, color::String="white")
    if color == "white"
        if board.K & board.black_attacks == EMPTY
            return false
        end
    else
        if board.k & board.white_attacks == EMPTY
            return false
        end
    end
    return kingtrace(board, color)
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


function kingtrace(board::Bitboard, color::String="white")
    if color == "white"
        return square_in_check(board, board.K, color)
    else
        return square_in_check(board, board.k, color)
    end
end

function kingtrace(chessboard::Chessboard, color::String="white")
    if color == "white"
        return square_in_check(chessboard.white, chessboard.white.K, color)
    else
        return square_in_check(chessboard.black, chessboard.black.K, color)
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
