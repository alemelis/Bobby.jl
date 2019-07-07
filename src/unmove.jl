function unmove_piece_(chessboard::Chessboard, move::Move, player_color::String,
    friends::Bitboard, enemy::Bitboard)
    pop!(chessboard.game)

    if move.capture_type != "none"
        if move.capture_type == "pawn"
            enemy.P = add_to_square(enemy.P, move.target)
        elseif move.capture_type == "night"
            enemy.N = add_to_square(enemy.N, move.target)
        elseif move.capture_type == "bishop"
            enemy.B = add_to_square(enemy.B, move.target)
        elseif move.capture_type == "queen"
            enemy.Q = add_to_square(enemy.Q, move.target)
        elseif move.capture_type == "rook"
            enemy.R = add_to_square(enemy.R, move.target)
        end
    end

    if move.promotion_type != "none"
        friends.P = add_to_square(friends.P, move.target)
        if move.promotion_type == "queen"
            friends.Q = remove_from_square(friends.Q, move.target)
        elseif move.promotion_type == "rook"
            friends.R = remove_from_square(friends.R, move.target)
        elseif move.promotion_type == "night"
            friends.N = remove_from_square(friends.N, move.target)
        elseif move.promotion_type == "bishop"
            friends.B = remove_from_square(friends.B, move.target)
        end
    end

    if move.piece_type == "pawn"
        if move.target == chessboard.enpassant_square
            enemy.P = add_to_square(enemy.P, move.target >> 8)
            chessboard.enpassant_done = false
        else
            chessboard.enpassant_done = false
            if move.enpassant_square != EMPTY
                chessboard.enpassant_square = move.enpassant_square
            end
        end
        friends.P = update_from_to_squares(friends.P, move.target, move.source)
    elseif move.piece_type == "night"
        friends.N = update_from_to_squares(friends.N, move.target, move.source)
    elseif move.piece_type == "bishop"
        friends.B = update_from_to_squares(friends.B, move.target, move.source)
    elseif move.piece_type == "queen"
        friends.Q = update_from_to_squares(friends.Q, move.target, move.source)
    elseif move.piece_type == "rook"
        friends.R = update_from_to_squares(friends.R, move.target, move.source)
    elseif move.piece_type == "king"
        friends.K = update_from_to_squares(friends.K, move.target, move.source)
        if move.castling_type != "-"
            if move.castling_type == "K"
                friends.R = update_from_to_squares(friends.R,
                    friends.king_side_castling_sq,
                    friends.king_side_rook_sq)
            elseif move.castling_type == "Q"
                friends.R = update_from_to_squares(friends.R,
                    friends.queen_side_castling_sq,
                    friends.queen_side_rook_sq)
            end
        end
    end

    if player_color == "white"
        chessboard.white = friends
        chessboard.black = enemy
    else
        chessboard.white = enemy
        chessboard.black = friends
    end

    update_both_sides_bitboard!(chessboard)
    return chessboard
end
