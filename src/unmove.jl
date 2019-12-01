function unmove_piece(chessboard::Chessboard, move::Move, player_color::String,
    friends::Bitboard, enemy::Bitboard)
    pop!(chessboard.game)
    pop!(chessboard.enpassant_history)
    if length(chessboard.enpassant_history) > 0
        chessboard.enpassant_square = chessboard.enpassant_history[end]
    else
        chessboard.enpassant_square = EMPTY
    end

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
        if move.took_enpassant != EMPTY
            enemy.P = add_to_square(enemy.P, move.took_enpassant)
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


function check_unmove(b, bm)
    try
        @assert b.white.P == bm.white.P
        @assert b.white.R == bm.white.R
        @assert b.white.N == bm.white.N
        @assert b.white.B == bm.white.B
        @assert b.white.Q == bm.white.Q
        @assert b.white.K == bm.white.K
        @assert Set(b.white.A) == Set(bm.white.A)
        @assert b.black.P == bm.black.P
        @assert b.black.R == bm.black.R
        @assert b.black.N == bm.black.N
        @assert b.black.B == bm.black.B
        @assert b.black.Q == bm.black.Q
        @assert b.black.K == bm.black.K
        @assert Set(b.black.A) == Set(bm.black.A)
        @assert b.free == bm.free
        @assert b.taken == bm.taken
        @assert b.white_attacks == bm.white_attacks
        @assert b.black_attacks == bm.black_attacks
        @assert b.player_color == bm.player_color
        @assert b.white.can_castle_queenside == bm.white.can_castle_queenside
        @assert b.white.can_castle_kingside  == bm.white.can_castle_kingside 
        @assert b.black.can_castle_queenside == bm.black.can_castle_queenside
        @assert b.black.can_castle_kingside  == bm.black.can_castle_kingside 
        @assert b.white.king_moved == bm.white.king_moved
        @assert b.black.king_moved == bm.black.king_moved
        @assert b.enpassant_square == bm.enpassant_square
        @assert b.enpassant_done == bm.enpassant_done
        @assert b.halfmove_clock == bm.halfmove_clock
        @assert b.fullmove_clock == bm.fullmove_clock
        @assert b.fen == bm.fen
        @assert b.game == bm.game
    catch e
        println(e)
        return false
    end
    return true
end
