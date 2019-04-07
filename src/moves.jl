struct Move
    source :: UInt64
    target :: UInt64
    piece_type :: String
    capture_type :: String
    promotion_type :: String
    enpassant_square :: UInt64
    castling_type :: String
end


function validate_move(board::Bitboard, move::Move, color::String="white")
    board = move_piece(board, move, color)
    in_check = check_check_raytrace(board, color)
    board = unmove_piece(board, move, color)
    return ~in_check
end


function get_all_moves(board::Bitboard, color::String="white")
    valid_moves = get_non_sliding_pieces_list(board, "king", color)
    union!(valid_moves, get_non_sliding_pieces_list(board, "night", color))
    union!(valid_moves, get_pawns_list(board, color))
    union!(valid_moves, get_sliding_pieces_list(board, "queen", color))
    union!(valid_moves, get_sliding_pieces_list(board, "rook", color))
    return union!(valid_moves, get_sliding_pieces_list(board, "bishop", color))
end


function get_all_valid_moves(board::Bitboard, color::String="white")
    moves = get_all_moves(board, color)
    valid_moves = Array{Move,1}()
    for move in moves
        if validate_move(board, move, color)
            push!(valid_moves, move)
        end
    end
    return valid_moves
end


function get_non_sliding_pieces_list(board::Bitboard, piece_type::String,
    color::String="white")

    if color == "white"
        same = board.white
        other = board.black
        other_king = board.k
        if piece_type == "king"
            pieces = board.K
            home_square = WHITE_KING_HOME
        else
            pieces = board.N
        end
        opponent_color = "black"
    else
        same = board.black
        other = board.white
        other_king = board.K
        if piece_type == "king"
            pieces = board.k
            home_square = BLACK_KING_HOME
        else
            pieces = board.n
        end
        opponent_color = "white"
    end

    piece_moves = Array{Move,1}()
    if piece_type == "king"
        piece_dict = KING_MOVES

        if pieces == home_square
            if color == "white"
                if board.white_can_castle_kingside == true
                    if board.free & PGN2UINT["f1"] != EMPTY &&
                        board.free & PGN2UINT["g1"] != EMPTY &&
                        PGN2UINT["h1"] in board.R
                        push!(piece_moves, Move(pieces, PGN2UINT["g1"],
                            piece_type, "none", "none", EMPTY, "K"))
                    end
                end
                if board.white_can_castle_queenside == true
                    if board.free & PGN2UINT["d1"] != EMPTY &&
                        board.free & PGN2UINT["c1"] != EMPTY &&
                        board.free & PGN2UINT["b1"] != EMPTY &&
                        PGN2UINT["a1"] in board.R
                        push!(piece_moves, Move(pieces, PGN2UINT["c1"],
                            piece_type, "none", "none", EMPTY, "Q"))
                    end
                end
            else
                if board.black_can_castle_kingside == true
                    if board.free & PGN2UINT["f8"] != EMPTY &&
                        board.free & PGN2UINT["g8"] != EMPTY &&
                        PGN2UINT["h8"] in board.r
                        push!(piece_moves, Move(pieces, PGN2UINT["g8"],
                            piece_type, "none", "none", EMPTY, "k"))
                    end
                end
                if board.black_can_castle_queenside == true
                    if board.free & PGN2UINT["d8"] != EMPTY &&
                        board.free & PGN2UINT["c8"] != EMPTY &&
                        board.free & PGN2UINT["b8"] != EMPTY &&
                        PGN2UINT["a8"] in board.r
                        push!(piece_moves, Move(pieces, PGN2UINT["c8"],
                            piece_type, "none", "none", EMPTY, "q"))
                    end
                end
            end
        end
    else
        piece_dict = NIGHT_MOVES
    end

    for piece in pieces
        for move in piece_dict[piece]
            if move & other_king == EMPTY
                if move & same == EMPTY && move & other == EMPTY
                    push!(piece_moves, Move(piece, move,
                        piece_type, "none", "none", EMPTY, "-"))
                elseif move & same == EMPTY && move & other != EMPTY
                    taken_piece = find_piece_type(board, move, opponent_color)
                    push!(piece_moves, Move(piece, move,
                        piece_type, taken_piece, "none", EMPTY, "-"))
                end
            end
        end
    end
    return piece_moves
end


function find_piece_type(board::Bitboard, ui::UInt64, color::String)
    if color == "white"
        if ui == board.K
            return "king"
        elseif ui in board.Q
            return "queen"
        elseif ui in board.R
            return "rook"
        elseif ui in board.P
            return "pawn"
        elseif ui in board.B
            return "bishop"
        elseif ui in board.N
            return "night"
        else
            return "none"
        end
    else
        if ui == board.k
            return "king"
        elseif ui in board.q
            return "queen"
        elseif ui in board.r
            return "rook"
        elseif ui in board.p
            return "pawn"
        elseif ui in board.b
            return "bishop"
        elseif ui in board.n
            return "night"
        else
            return "none"
        end
    end
end


function get_sliding_pieces_list(board::Bitboard, piece_type::String,
    color::String="white")

    if color == "white"
        same = board.white
        other_king = board.k
        other = board.black
        if piece_type == "queen"
            pieces = board.Q
        elseif piece_type == "rook"
            pieces = board.R
        else
            pieces = board.B
        end
        opponent_color = "black"
    else
        same = board.black
        other_king = board.K
        other = board.white
        if piece_type == "queen"
            pieces = board.q
        elseif piece_type == "rook"
            pieces = board.r
        else
            pieces = board.b
        end
        opponent_color = "white"
    end

    if piece_type == "queen"
        attack_fun = star_attack
    elseif piece_type == "rook"
        attack_fun = orthogonal_attack
    else
        attack_fun = cross_attack
    end

    piece_moves = Array{Move,1}()
    for piece in pieces
        moves, edges = attack_fun(board.taken, piece)
        for move in moves
            push!(piece_moves, Move(piece, move, piece_type,
                "none", "none", EMPTY, "-"))
        end
        for edge in edges
            if edge & other_king == EMPTY
                if edge & same == EMPTY && edge & other == EMPTY
                    push!(piece_moves, Move(piece, edge, piece_type,
                                            "none", "none", EMPTY, "-"))
                elseif edge & same == EMPTY && edge & other != EMPTY
                    taken_piece = find_piece_type(board, edge, opponent_color)
                    push!(piece_moves, Move(piece, edge, piece_type,
                                            taken_piece, "none", EMPTY, "-"))
                end
            end
        end
    end
    return piece_moves
end


function get_attacked(board::Bitboard, color::String="white")
    attacked = EMPTY
    if color == "white"
        for target in KING_MOVES[board.K]
            attacked |= target
        end
        for night in board.N
            for target in NIGHT_MOVES[night]
                attacked |= target
            end
        end
        for pawn in board.P
            for target in WHITE_PAWN_ATTACK[pawn]
                attacked |= target
            end
        end
        for queen in board.Q
            moves, edges = star_attack(board.taken, queen)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        for rook in board.R
            moves, edges = orthogonal_attack(board.taken, rook)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        for bishop in board.B
            moves, edges = cross_attack(board.taken, bishop)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        return attacked
    else
        for target in KING_MOVES[board.k]
            attacked |= target
        end
        for night in board.n
            for target in NIGHT_MOVES[night]
                attacked |= target
            end
        end
        for pawn in board.p
            for target in BLACK_PAWN_ATTACK[pawn]
                attacked |= target
            end
        end
        for queen in board.q
            moves, edges = star_attack(board.taken, queen)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        for rook in board.r
            moves, edges = orthogonal_attack(board.taken, rook)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        for bishop in board.b
            moves, edges = cross_attack(board.taken, bishop)
            for move in moves
                attacked |= move
            end
            for edge in edges
                attacked |= edge
            end
        end
        return attacked
    end
end


function update_attacked(board::Bitboard)
    board.white_attacks = get_attacked(board, "white")
    board.black_attacks = get_attacked(board, "black")
    return board
end


# function move_white_piece(board::Bitboard, source::UInt64, target::UInt64,
#     promotion_type::String="none", castling_type::String="-")

#     board.free |= source # +
#     board.free = xor(board.free, target) # -
#     board.taken |= target
#     board.taken = xor(board.taken, source)
#     board.white |= target
#     board.white = xor(board.white, source)

#     if board.black & target != EMPTY
#         board.black = xor(board.black, target)
#         filter!(e -> e != target, board.p)
#         filter!(e -> e != target, board.q)
#         filter!(e -> e != target, board.n)
#         filter!(e -> e != target, board.b)
#         filter!(e -> e != target, board.r)
#     end

#     if board.enpassant_square != EMPTY && target == board.enpassant_square
#         board.black = xor(board.black, board.enpassant_square >> 8)
#         filter!(e -> e != board.enpassant_square >> 8, board.p )
#         board.free |= board.enpassant_square >> 8
#         board.taken = xor(board.taken, board.enpassant_square)
#     end
#     board.enpassant_square = EMPTY

#     if promotion_type == "none"
#         if source in board.P
#             filter!(e -> e != source, board.P)
#             push!(board.P, target)
#         elseif source in board.Q
#             filter!(e -> e != source, board.Q)
#             push!(board.Q, target)
#         elseif source == board.K
#             board.K = target
#         elseif source in board.N
#             filter!(e -> e != source, board.N)
#             push!(board.N, target)
#         elseif source in board.R
#             filter!(e -> e != source, board.R)
#             push!(board.R, target)
#         elseif source in board.B
#             filter!(e -> e != source, board.B)
#             push!(board.B, target)
#         end
#     else
#         filter!(e -> e != source, board.P)
#         if promotion_type == "queen"
#             push!(board.Q, target)
#         elseif promotion_type == "rook"
#             push!(board.R, target)
#         elseif promotion_type == "night"
#             push!(board.N, target)
#         elseif promotion_type == "bishop"
#             push!(board.B, target)
#         end
#     end

#     if castling_type != "-"
#         if castling_type == "K"
#             c_move = Move(board.K, PGN2UINT["f1"], "king",
#                 "none", "none", EMPTY, "-")
#             if validate_move(board, c_move)
#                 c_move = Move(board.K, PGN2UINT["g1"], "king",
#                 "none", "none", EMPTY, "-")
#                 if validate_move(board, c_move)
#                     board = move_white_piece(board, PGN2UINT["h1"],
#                         PGN2UINT["f1"])
#                 end
#             end
#         elseif castling_type == "Q"
#             c_move = Move(board.K, PGN2UINT["d1"], "king",
#                 "none", "none", EMPTY, "-")
#             if validate_move(board, c_move)
#                 c_move = Move(board.K, PGN2UINT["c1"], "king",
#                     "none", "none", EMPTY, "-")
#                 if validate_move(board, c_move)
#                     board = move_white_piece(board, PGN2UINT["a1"],
#                         PGN2UINT["d1"])
#                 end
#             end
#         end
#         board.white_can_castle_queenside = false
#         board.white_can_castle_kingside = false
#     end

#     return board
# end


# function move_black_piece(board::Bitboard, source::UInt64, target::UInt64,
#     promotion_type::String="none", castling_type::String="-")

#     board.free |= source
#     board.free = xor(board.free, target)
#     board.taken |= target
#     board.taken = xor(board.taken, source)
#     board.black |= target
#     board.black = xor(board.black, source)

#     if board.white & target != EMPTY
#         board.white = xor(board.white, target)
#         filter!(e -> e != target, board.P)
#         filter!(e -> e != target, board.Q)
#         filter!(e -> e != target, board.N)
#         filter!(e -> e != target, board.B)
#         filter!(e -> e != target, board.R)
#     end

#     if board.enpassant_square != EMPTY && target == board.enpassant_square
#         board.white = xor(board.white, board.enpassant_square << 8)
#         filter!(e -> e != board.enpassant_square << 8, board.P)
#         board.free |= board.enpassant_square << 8
#         board.taken = xor(board.taken, board.enpassant_square)
#     end
#     board.enpassant_square = EMPTY

#     if promotion_type == "none"
#         if source in board.p
#             filter!(e -> e != source, board.p)
#             push!(board.p, target)
#         elseif source in board.q
#             filter!(e -> e != source, board.q)
#             push!(board.q, target)
#         elseif source in board.k
#             board.k = target
#         elseif source in board.n
#             filter!(e -> e != source, board.n)
#             push!(board.n, target)
#         elseif source in board.r
#             filter!(e -> e != source, board.r)
#             push!(board.r, target)
#         elseif source in board.b
#             filter!(e -> e != source, board.b)
#             push!(board.b, target)
#         end
#     else
#         filter!(e -> e != source, board.p)
#         if promotion_type == "queen"
#             push!(board.q, target)
#         elseif promotion_type == "rook"
#             push!(board.r, target)
#         elseif promotion_type == "night"
#             push!(board.n, target)
#         elseif promotion_type == "bishop"
#             push!(board.b, target)
#         end
#     end

#     if castling_type != "-"
#         if castling_type == "k"
#             c_move = Move(board.k, PGN2UINT["f8"], "king",
#                 "none", "none", EMPTY, "-")
#             if validate_move(board, c_move)
#                 c_move = Move(board.k, PGN2UINT["g8"], "king",
#                     "none", "none", EMPTY, "-")
#                 if validate_move(board, c_move)
#                     board = move_black_piece(board, PGN2UINT["h8"],
#                         PGN2UINT["f8"])
#                 end
#             end
#         elseif castling_type == "q"
#             c_move = Move(board.k, PGN2UINT["d8"], "king",
#                 "none", "none", EMPTY, "-")
#             if validate_move(board, c_move)
#                 c_move = Move(board.k, PGN2UINT["c8"], "king",
#                     "none", "none", EMPTY, "-")
#                 if validate_move(board, c_move)
#                     board = move_black_piece(board, PGN2UINT["a8"],
#                         PGN2UINT["d8"])
#                 end
#             end
#         end
#         board.black_can_castle_queenside = false
#         board.black_can_castle_kingside = false
#     end

#     return board
# end


# function move_piece(board::Bitboard, move::Move, color::String="white")
#     if move.enpassant_square != EMPTY
#         board.enpassant_square = move.enpassant_square
#     else
#         board.enpassant_square = EMPTY
#     end
#     if color == "white"
#         board = move_white_piece(board, move.source, move.target,
#             move.promotion_type, move.castling_type)
#     else
#         board = move_black_piece(board, move.source, move.target,
#             move.promotion_type, move.castling_type)
#     end
#     return board
# end


# function manual_move(board::Bitboard, source::String, target::String,
#     promotion_type::String="none")

#     s = PGN2UINT[source]
#     t = PGN2UINT[target]
#     enpassant_square = EMPTY
#     castling_type = "-"
#     if s & board.white != EMPTY
#         color = "white"
        
#         if s in board.P
#             piece_type = "pawn"
#             if source[2] == '2' && target[2] == '4'
#                 enpassant_square = PGN2UINT[source[1]*"3"]
#             end
#         elseif s in board.Q
#             piece_type = "queen"
#         elseif s in board.N
#             piece_type = "night"
#         elseif s in board.B
#             piece_type = "bishop"
#         elseif s in board.R
#             piece_type = "rook"
#         elseif s == board.K
#             piece_type = "king"
#             if source == "e1" && target == "g1"
#                 castling_type = "K"
#             elseif source == "e1" && target == "c1"
#                 castling_type = "Q"
#             end
#         end

#         if t & board.white != EMPTY
#             throw(ArgumentError("Invalid target UCI string: same color piece"))
#         elseif t & board.black != EMPTY
#             if t in board.p
#                 capture_type = "pawn"
#             elseif t in board.q
#                 capture_type = "queen"
#             elseif t in board.n
#                 capture_type = "night"
#             elseif t in board.b
#                 capture_type = "bishop"
#             elseif t in board.r
#                 capture_type = "rook"
#             end
#         else
#             capture_type = "none"
#         end

#         promotion_mask = MASK_RANK_8
#         if t & promotion_mask != EMPTY
#             if promotion_type == "none"
#                 throw(ArgumentError("You should specify the promotion type"))
#             end
#         end
#     elseif s & board.black != EMPTY
#         color = "black"

#         if s in board.p
#             piece_type = "pawn"
#             if source[2] == '7' && target[2] == '5'
#                 enpassant_square = PGN2UINT[source[1]*"6"]
#             end
#         elseif s in board.q
#             piece_type = "queen"
#         elseif s in board.n
#             piece_type = "night"
#         elseif s in board.b
#             piece_type = "bishop"
#         elseif s in board.r
#             piece_type = "rook"
#         elseif s == board.k
#             piece_type = "king"
#             println(source, " ", target)
#             if source == "e8" && target == "g8"
#                 castling_type = "k"
#             elseif source == "e8" && target == "c8"
#                 castling_type = "q"
#             end
#         end

#         if t & board.black != EMPTY
#             throw(ArgumentError("Invalid target UCI string: same color piece"))
#         elseif t & board.white != EMPTY
#             if t in board.P
#                 capture_type = "pawn"
#             elseif t in board.Q
#                 capture_type = "queen"
#             elseif t in board.N
#                 capture_type = "night"
#             elseif t in board.B
#                 capture_type = "bishop"
#             elseif t in board.R
#                 capture_type = "rook"
#             end
#         else
#             capture_type = "none"
#         end

#         promotion_mask = MASK_RANK_1
#         if t & promotion_mask != EMPTY
#             if promotion_type == "none"
#                 throw(ArgumentError("You should specify the promotion type"))
#             end
#         end
#     else
#         throw(ArgumentError("Invalid source UCI string: no piece to move"))
#     end

#     println(castling_type)
    
#     move = Move(s, t, piece_type, capture_type,
#                 promotion_type, enpassant_square, castling_type)
#     return move_piece(board, move, color)
# end


# function unmove_piece(board::Bitboard, move::Move, color::String="white")
#     if color == "white"
#         if move.promotion_type != "none"
#             new_piece_type = find_piece_type(board, move.target, "white")
#             if new_piece_type == "queen"
#                 filter!(e -> e != move.target, board.Q)
#             elseif new_piece_type == "rook"
#                 filter!(e -> e != move.target, board.R)
#             elseif new_piece_type == "night"
#                 filter!(e -> e != move.target, board.N)
#             elseif new_piece_type == "bishop"
#                 filter!(e -> e != move.target, board.B)
#             end
#             push!(board.P, move.target)
#         end
#         board = move_white_piece(board, move.target, move.source)
#         if move.capture_type != "none"
#             if move.capture_type == "queen"
#                 push!(board.q, move.target)
#             elseif move.capture_type == "rook"
#                 push!(board.r, move.target)
#             elseif move.capture_type == "pawn"
#                 push!(board.p, move.target) 
#             elseif move.capture_type == "night"
#                 push!(board.n, move.target)
#             elseif move.capture_type == "bishop"
#                 push!(board.b, move.target)
#             end
#             board.black |= move.target
#             board.taken |= move.target
#             board.free = xor(board.free, move.target)
#         else
#             if move.piece_type == "pawn"
#                 if move.source == move.target >> 9 ||
#                     move.source == move.target >> 7
#                     board.enpassant_square = move.target
#                 end
#             else
#                 board.enpassant_square = EMPTY
#             end
#         end
#     else
#         if move.promotion_type != "none"
#             new_piece_type = find_piece_type(board, move.target, "black")
#             if new_piece_type == "queen"
#                 filter!(e -> e != move.target, board.q)
#             elseif new_piece_type == "rook"
#                 filter!(e -> e != move.target, board.r)
#             elseif new_piece_type == "night"
#                 filter!(e -> e != move.target, board.n)
#             elseif new_piece_type == "bishop"
#                 filter!(e -> e != move.target, board.b)
#             end
#             push!(board.p, move.target)
#         end
#         board = move_black_piece(board, move.target, move.source)
#         if move.capture_type != "none"
#             if move.capture_type == "queen"
#                 push!(board.Q, move.target)
#             elseif move.capture_type == "rook"
#                 push!(board.R, move.target)
#             elseif move.capture_type == "pawn"
#                 push!(board.P, move.target) 
#             elseif move.capture_type == "night"
#                 push!(board.N, move.target)
#             elseif move.capture_type == "bishop"
#                 push!(board.B, move.target)
#             end
#             board.white |= move.target
#             board.taken |= move.target
#             board.free = xor(board.free, move.target)
#         else
#             if move.piece_type == "pawn"
#                 if move.source == move.target << 9 ||
#                     move.source == move.target << 7
#                     board.enpassant_square = move.target
#                 end
#             else
#                 board.enpassant_square = EMPTY
#             end
#         end
#     end
#     return board
# end


function remove_from_square(b::UInt64, s::UInt64)
    return xor(b, s)
end


function remove_from_square(bs::Array{UInt64,1}, s::UInt64)
    filter!(e -> e != s, bs)
    return bs
end


function add_to_square(b::UInt64, s::UInt64)
    return b |= s
end


function add_to_square(bs::Array{UInt64,1}, s::UInt64)
    push!(bs, s)
    return bs
end


function update_from_to_squares(b::UInt64, s::UInt64, t::UInt64)
    b = remove_from_square(b, s)
    b = add_to_square(b, t)
    return b
end


function update_from_to_squares(bs::Array{UInt64,1}, s::UInt64, t::UInt64)
    bs = remove_from_square(bs, s)
    bs = add_to_square(bs, t)
    return bs
end


function move_piece(board::Bitboard, move::Move, color::String="white")
    if color == "white"
        board.white = update_from_to_squares(board.white, move.source,
            move.target)
        board.taken = update_from_to_squares(board.taken, move.source,
            move.target)

        if move.capture_type != "none"
            board.black = remove_from_square(board.black, move.target)
            if move.capture_type == "pawn"
                board.p = remove_from_square(board.p, move.target)
            elseif move.capture_type == "night"
                board.n = remove_from_square(board.n, move.target)
            elseif move.capture_type == "bishop"
                board.b = remove_from_square(board.b, move.target)
            elseif move.capture_type == "queen"
                board.q = remove_from_square(board.q, move.target)
            elseif move.capture_type == "rook"
                board.q = remove_from_square(board.r, move.target)
            end
        end

        if move.piece_type == "pawn"
            if move.target == board.enpassant_square
                board.black = remove_from_square(board.black, move.target>>8)
                board.p = remove_from_square(board.p, move.target>>8)
                board.taken = remove_from_square(board.taken, move.target>>8)
                board.enpassant_done = true
            else
                board.enpassant_done = false
            end
            board.P = update_from_to_squares(board.P, move.source, move.target)
            # board.enpassant_square = move.enpassant_square
        elseif move.piece_type == "night"
            board.N = update_from_to_squares(board.N, move.source, move.target)
        elseif move.piece_type == "bishop"
            board.B = update_from_to_squares(board.B, move.source, move.target)
        elseif move.piece_type == "queen"
            board.Q = update_from_to_squares(board.Q, move.source, move.target)
        elseif move.piece_type == "rook"
            board.R = update_from_to_squares(board.R, move.source, move.target)
        elseif move.piece_type == "king"
            board.K = update_from_to_squares(board.K, move.source, move.target)
        end

        if move.promotion_type != "none"
            board.P = remove_from_square(board.P, move.target)
            if move.promotion_type == "queen"
                board.Q = add_to_square(board.Q, move.target)
            elseif move.promotion_type == "rook"
                board.R = add_to_square(board.R, move.target)
            elseif move.promotion_type == "night"
                board.N = add_to_square(board.N, move.target)
            elseif move.promotion_type == "bishop"
                board.B = add_to_square(board.B, move.target)
            end
        end
    else
        board.black = update_from_to_squares(board.black, move.source,
            move.target)
        board.taken = update_from_to_squares(board.taken, move.source,
            move.target)

        if move.capture_type != "none"
            board.white = remove_from_square(board.white, move.target)
            if move.capture_type == "pawn"
                board.P = remove_from_square(board.P, move.target)
            elseif move.capture_type == "night"
                board.N = remove_from_square(board.N, move.target)
            elseif move.capture_type == "bishop"
                board.B = remove_from_square(board.B, move.target)
            elseif move.capture_type == "queen"
                board.Q = remove_from_square(board.Q, move.target)
            elseif move.capture_type == "rook"
                board.R = remove_from_square(board.R, move.target)
            end
        end

        if move.piece_type == "pawn"
            if move.target == board.enpassant_square
                board.white = remove_from_square(board.white, move.target<<8)
                board.P = remove_from_square(board.P, move.target<<8)
                board.taken = remove_from_square(board.taken, move.target<<8)
                board.enpassant_done = true
            else
                board.enpassant_done = false
            end
            board.p = update_from_to_squares(board.p, move.source, move.target)
            # board.enpassant_square = move.enpassant_square
        elseif move.piece_type == "night"
            board.n = update_from_to_squares(board.n, move.source, move.target)
        elseif move.piece_type == "bishop"
            board.b = update_from_to_squares(board.b, move.source, move.target)
        elseif move.piece_type == "queen"
            board.q = update_from_to_squares(board.q, move.source, move.target)
        elseif move.piece_type == "rook"
            board.r = update_from_to_squares(board.r, move.source, move.target)
        elseif move.piece_type == "king"
            board.k = update_from_to_squares(board.k, move.source, move.target)
        end
        
        if move.promotion_type != "none"
            board.p = remove_from_square(board.p, move.target)
            if move.promotion_type == "queen"
                board.q = add_to_square(board.q, move.target)
            elseif move.promotion_type == "rook"
                board.r = add_to_square(board.r, move.target)
            elseif move.promotion_type == "night"
                board.n = add_to_square(board.n, move.target)
            elseif move.promotion_type == "bishop"
                board.b = add_to_square(board.b, move.target)
            end
        end
    end
    board.free = ~board.taken

    return board
end


function unmove_piece(board::Bitboard, move::Move, color::String="white")
    if color == "white"
        board.white = update_from_to_squares(board.white, move.target,
            move.source)
        board.taken = update_from_to_squares(board.taken, move.target,
            move.source)

        if move.piece_type == "pawn"
            if board.enpassant_done
                board.black = add_to_square(board.black, move.target>>8)
                board.black = add_to_square(board.p, move.target>>8)
                board.black = add_to_square(board.taken, move.target>>8)
                board.enpassant_done = false
                board.enpassant_square = move.target
            end
            board.P = update_from_to_squares(board.P, move.target, move.source)
        elseif move.piece_type == "night"
            board.N = update_from_to_squares(board.N, move.target, move.source)
        elseif move.piece_type == "bishop"
            board.B = update_from_to_squares(board.B, move.target, move.source)
        elseif move.piece_type == "queen"
            board.Q = update_from_to_squares(board.Q, move.target, move.source)
        elseif move.piece_type == "rook"
            board.R = update_from_to_squares(board.R, move.target, move.source)
        elseif move.piece_type == "king"
            board.K = update_from_to_squares(board.K, move.target, move.source)
        end

        if move.capture_type != "none"
            board.black = add_to_square(board.black, move.target)
            board.taken = add_to_square(board.taken, move.target)
            if move.capture_type == "pawn"
                board.p = add_to_square(board.p, move.target)
            elseif move.capture_type == "night"
                board.n = add_to_square(board.n, move.target)
            elseif move.capture_type == "bishop"
                board.b = add_to_square(board.b, move.target)
            elseif move.capture_type == "queen"
                board.q = add_to_square(board.q, move.target)
            elseif move.capture_type == "rook"
                board.r = add_to_square(board.r, move.target)
            end
        end
    else
        board.black = update_from_to_squares(board.black, move.target,
            move.source)
        board.taken = update_from_to_squares(board.taken, move.target,
            move.source)

        if move.piece_type == "pawn"
            if board.enpassant_done
                board.white = add_to_square(board.white, move.target<<8)
                board.P = add_to_square(board.P, move.target<<8)
                board.taken = add_to_square(board.taken, move.target<<8)
                board.enpassant_done = false
                board.enpassant_square = move.target
            end
            board.p = update_from_to_squares(board.p, move.target, move.source)
        elseif move.piece_type == "night"
            board.n = update_from_to_squares(board.n, move.target, move.source)
        elseif move.piece_type == "bishop"
            board.b = update_from_to_squares(board.b, move.target, move.source)
        elseif move.piece_type == "queen"
            board.q = update_from_to_squares(board.q, move.target, move.source)
        elseif move.piece_type == "rook"
            board.r = update_from_to_squares(board.r, move.target, move.source)
        elseif move.piece_type == "king"
            board.k = update_from_to_squares(board.k, move.target, move.source)
        end

        if move.capture_type != "none"
            board.white = add_to_square(board.white, move.target)
            board.taken = add_to_square(board.taken, move.target)
            if move.capture_type == "pawn"
                board.P = add_to_square(board.P, move.target)
            elseif move.capture_type == "night"
                board.N = add_to_square(board.N, move.target)
            elseif move.capture_type == "bishop"
                board.B = add_to_square(board.B, move.target)
            elseif move.capture_type == "queen"
                board.Q = add_to_square(board.Q, move.target)
            elseif move.capture_type == "rook"
                board.R = add_to_square(board.R, move.target)
            end
        end
    end
    board.free = ~board.taken

    return board
end
