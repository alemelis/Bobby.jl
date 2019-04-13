# function check_check(board::Bitboard, color::String="white")
#     if color == "white"
#         if board.K & board.black_attacks != EMPTY
#             return true
#         end
#     else
#         if board.k & board.white_attacks != EMPTY
#             return true
#         end
#     end
#     return false
# end

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


function kingtrace(board::Bitboard, color::String="white")
    if color == "white"
        if board.K & board.a[1] != EMPTY
            return true
        end
        if board.K & board.a[2] != EMPTY
            return true
        end
        if board.K & board.a[4] != EMPTY
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
        end
        if board.K & board.a[5] != EMPTY
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
        end
        return false
    else
        if board.k & board.A[1] != EMPTY
            return true
        end
        if board.k & board.A[2] != EMPTY
            return true
        end
        if board.k & board.A[4] != EMPTY
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
        end
        if board.k & board.A[5] != EMPTY
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
