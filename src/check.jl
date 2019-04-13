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


function square_in_check(board::Bitboard, ui::UInt64, color::String="white")
    if color == "white"
        if ui & board.a[1] != EMPTY
            return true
        end
        if ui & board.a[2] != EMPTY
            return true
        end
        if ui & board.a[4] != EMPTY
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
        if ui & board.a[5] != EMPTY
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
        if ui & board.A[4] != EMPTY
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
        if ui & board.A[5] != EMPTY
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
