function get_piece_color(chessboard::Chessboard, ui::UInt64)
    if ui & chessboard.white.pieces == EMPTY
        return "black"
    else
        return "white"
    end
end


function get_piece_type(board::Bitboard, ui::UInt64)
    for uil in zip([board.K, board.P, board.R, board.Q, board.B, board.N],
        ["king", "pawn", "rook", "queen", "bishop", "night"])
        if uil[1] & ui != EMPTY
            return uil[2]
        end
    end
end


function find_all_semi_legal_moves(chessboard::Chessboard, player_color::String)
    if player_color == "white"
        friends = chessboard.white
        enemy = chessboard.black
        rooks = chessboard.white.R
    else
        friends = chessboard.black
        enemy = chessboard.white
        rooks = chessboard.black.R
    end

    semi_legal_moves = Array{Move,1}()
    for i in 1:64
        ui = INT2UINT[i]

        if ui & chessboard.taken == EMPTY
            continue
        end
        
        piece_color = get_piece_color(chessboard, ui)
        if piece_color != player_color
            continue
        end

        if piece_color == "white"
            piece_type = get_piece_type(chessboard.white, ui)
        else
            piece_type = get_piece_type(chessboard.black, ui)
        end

        if piece_type == "night"
            get_night_moves!(semi_legal_moves, ui, friends.pieces, enemy)
        elseif piece_type in ["queen", "rook", "bishop"]
            get_sliding_pieces_moves!(semi_legal_moves, ui, friends.pieces,
                enemy, chessboard.taken, piece_type)
        elseif piece_type == "pawn"
            get_pawn_moves!(semi_legal_moves, ui, friends, enemy,
                chessboard.taken, player_color, chessboard.enpassant_square)
        elseif piece_type == "king"
            get_king_moves!(semi_legal_moves, ui, friends, enemy, player_color,
                chessboard, rooks)
        end
    end
    return semi_legal_moves
end


function add_to_square(b::UInt64, s::UInt64)
    b |= s
    return b
end


function remove_from_square(b::UInt64, s::UInt64)
    return xor(b, s)
end


function update_from_to_squares(b::UInt64, s::UInt64, t::UInt64)
    b = remove_from_square(b, s)
    return add_to_square(b, t)
end


function update_side_bitboards!(board::Bitboard)
    board.pieces = EMPTY | board.K
    board.pieces |= board.P
    board.pieces |= board.B
    board.pieces |= board.N
    board.pieces |= board.Q
    board.pieces |= board.R
end


function update_both_sides_bitboard!(chessboard::Chessboard)
    update_side_bitboards!(chessboard.white)
    update_side_bitboards!(chessboard.black)
    if length(chessboard.enpassant_history) > 0
        chessboard.enpassant_square = chessboard.enpassant_history[end]
    else
        chessboard.enpassant_square = EMPTY
    end
    chessboard.taken = EMPTY | chessboard.white.pieces | chessboard.black.pieces
    chessboard.free = ~chessboard.taken
end


function move_piece(chessboard::Chessboard, move::Move, player_color::String,
    friends::Bitboard, enemy::Bitboard)
    push!(chessboard.game, player_color*move.piece_type*UINT2PGN[move.source])
    push!(chessboard.enpassant_history, move.enpassant_square)

    if move.capture_type != "none"
        if move.capture_type == "pawn"
            enemy.P = remove_from_square(enemy.P, move.target)
        elseif move.capture_type == "night"
            enemy.N = remove_from_square(enemy.N, move.target)
        elseif move.capture_type == "bishop"
            enemy.B = remove_from_square(enemy.B, move.target)
        elseif move.capture_type == "queen"
            enemy.Q = remove_from_square(enemy.Q, move.target)
        elseif move.capture_type == "rook"
            enemy.R = remove_from_square(enemy.R, move.target)
        end
    end

    if move.piece_type == "pawn"
        if move.took_enpassant != EMPTY
            enemy.P = remove_from_square(enemy.P, enemy.one_step[move.target])
        end
        friends.P = update_from_to_squares(friends.P, move.source, move.target)
    elseif move.piece_type == "night"
        friends.N = update_from_to_squares(friends.N, move.source, move.target)
    elseif move.piece_type == "bishop"
        friends.B = update_from_to_squares(friends.B, move.source, move.target)
    elseif move.piece_type == "queen"
        friends.Q = update_from_to_squares(friends.Q, move.source, move.target)
    elseif move.piece_type == "rook"
        friends.R = update_from_to_squares(friends.R, move.source, move.target)
    elseif move.piece_type == "king"
        friends.K = update_from_to_squares(friends.K, move.source, move.target)
        if move.castling_type != "-"
            if move.castling_type == "K"
                friends.R = update_from_to_squares(friends.R,
                    friends.king_side_rook_sq, friends.king_side_castling_sq)
            elseif move.castling_type == "Q"
                friends.R = update_from_to_squares(friends.R,
                    friends.queen_side_rook_sq,
                    friends.queen_side_castling_sq)
            end
        end
    end

    if move.promotion_type != "none"
        friends.P = remove_from_square(friends.P, move.target)
        if move.promotion_type == "queen"
            friends.Q = add_to_square(friends.Q, move.target)
        elseif move.promotion_type == "rook"
            friends.R = add_to_square(friends.R, move.target)
        elseif move.promotion_type == "night"
            friends.N = add_to_square(friends.N, move.target)
        elseif move.promotion_type == "bishop"
            friends.B = add_to_square(friends.B, move.target)
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


function update_attacked!(board::Bitboard)
    board.A[1] = EMPTY
    board.A[2] = EMPTY
    board.A[3] = EMPTY
    board.A[4] = EMPTY
    board.A[5] = EMPTY
    for i in 1:64
        ui = INT2UINT[i]
        if ui & board.P != EMPTY
            for a in board.attacks[ui]
                board.A[1] |= a
            end
        elseif ui & board.N != EMPTY
            for a in NIGHT_MOVES[ui]
                board.A[2] |= a
            end
        elseif ui & board.Q != EMPTY
            board.A[3] |= ORTHO_MASKS[ui] | DIAG_MASKS[ui]
        elseif ui & board.R != EMPTY
            board.A[4] |= ORTHO_MASKS[ui]
        elseif ui & board.B != EMPTY
            board.A[5] |= DIAG_MASKS[ui]
        end
    end
end


function update_both_sides_attacked!(chessboard::Chessboard)
    update_attacked!(chessboard.white)
    update_attacked!(chessboard.black)
    chessboard.white_attacks = EMPTY
    chessboard.black_attacks = EMPTY
    for i = 1:5
        chessboard.black_attacks |= chessboard.black.A[i]
        chessboard.white_attacks |= chessboard.white.A[i]
    end
end


function validate_move(chessboard::Chessboard, move::Move, player_color::String)
    if player_color == "white"
        chessboard = move_piece(chessboard, move, player_color,
            chessboard.white, chessboard.black)
    else
        chessboard = move_piece(chessboard, move, player_color,
            chessboard.black, chessboard.white)
    end
    update_both_sides_attacked!(chessboard)

    in_check = king_in_check(chessboard, player_color)

    if player_color == "white"
        chessboard = unmove_piece(chessboard, move, player_color,
            chessboard.white, chessboard.black)
    else
        chessboard = unmove_piece(chessboard, move, player_color,
            chessboard.black, chessboard.white)
    end
    update_both_sides_attacked!(chessboard)

    return ~in_check
end


function get_all_legal_moves(chessboard::Chessboard, player_color::String)
    semi_legal_moves = find_all_semi_legal_moves(chessboard, player_color)
    legal_moves = Array{Move,1}()
    for move in semi_legal_moves
        if validate_move(chessboard, move, player_color)
            push!(legal_moves, move)
        end
    end
    return legal_moves
end


function update_castling_rights(chessboard::Chessboard)
    if chessboard.white.K == E1
        chessboard.white.king_moved = false
    end
    if A1 == chessboard.white.R
        chessboard.white.can_castle_queenside = true
    end
    if H1 == chessboard.white.R
        chessboard.white.can_castle_kingside = true
    end
    if chessboard.black.K == E8
        chessboard.black.king_moved = false
    end
    if A8 == chessboard.black.R
        chessboard.black.can_castle_queenside = true
    end
    if H8 == chessboard.black.R
        chessboard.black.can_castle_kingside = true
    end
    for move in chessboard.game
        if move == "whitekinge1"
            chessboard.white.king_moved = true
        elseif move == "whiterooka1"
            chessboard.white.can_castle_queenside = false
        elseif move == "whiterookh1"
            chessboard.white.can_castle_kingside = false
        elseif move == "blackkinge8"
            chessboard.black.king_moved = true
        elseif move == "blackrooka8"
            chessboard.black.can_castle_queenside = false
        elseif move == "blackrookh8"
            chessboard.black.can_castle_kingside = false
        end
    end
    return chessboard
end
