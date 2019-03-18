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

function check_check_raytrace(board::Bitboard, color::String="white")
    if color == "white"
        squares = NIGHT_MOVES[board.K]
        for night in board.n
            if night in squares
                return true
            end
        end
        squares = WHITE_PAWN_ATTACK[board.K]
        for pawn in board.p
            if pawn in squares
                return true
            end
        end
        squares, edges = cross_attack(board.taken, board.K)
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
        squares, edges = orthogonal_attack(board.taken, board.K)
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
        return false
    else
        squares = NIGHT_MOVES[board.k]
        for night in board.N
            if night in squares
                return true
            end
        end
        squares = BLACK_PAWN_ATTACK[board.k]
        for pawn in board.P
            if pawn in squares
                return true
            end
        end
        squares, edges = cross_attack(board.taken, board.k)
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
        squares, edges = orthogonal_attack(board.taken, board.k)
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
        return false
    end
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
