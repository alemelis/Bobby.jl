function validate_move(board::Bitboard, move::Tuple{UInt64,UInt64},
    color::String="white")
    
    tmp_b = deepcopy(board)
    tmp_b = move_piece(tmp_b, move[1], move[2], color)

    return ~check_check(tmp_b, color)
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
    valid_moves = Set()
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
        other_king = board.k
        if piece_type == "king"
            pieces = board.K
        else
            pieces = board.N
        end
    else
        same = board.black
        other_king = board.K
        if piece_type == "king"
            pieces = board.k
        else
            pieces = board.n
        end
    end

    if piece_type == "king"
        piece_dict = KING_MOVES
    else
        piece_dict = NIGHT_MOVES
    end

    piece_moves = Set()
    for piece in pieces
        for move in piece_dict[piece]
            if move & same == EMPTY && move & other_king == EMPTY
                push!(piece_moves, (piece, move))
            end
        end
    end
    return piece_moves
end

function get_sliding_pieces_list(board::Bitboard, piece_type::String,
    color::String="white")

    if color == "white"
        same = board.white
        other_king = board.k
        if piece_type == "queen"
            pieces = board.Q
        elseif piece_type == "rook"
            pieces = board.R
        else
            pieces = board.B
        end
    else
        same = board.black
        other_king = board.K
        if piece_type == "queen"
            pieces = board.q
        elseif piece_type == "rook"
            pieces = board.r
        else
            pieces = board.b
        end
    end

    if piece_type == "queen"
        attack_fun = star_attack
    elseif piece_type == "rook"
        attack_fun = orthogonal_attack
    else
        attack_fun = cross_attack
    end

    piece_moves = Set()
    for piece in pieces
        moves, edges = attack_fun(board.taken, piece)
        for move in moves
            push!(piece_moves, (piece, move))
        end
        for edge in edges
            if edge & same == EMPTY && edge & other_king == EMPTY
                push!(piece_moves, (piece, edge))
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

function move_white_piece(board::Bitboard, source::UInt64, target::UInt64)
    board.free |= source # +
    board.free = xor(board.free, target) # -
    board.taken |= target
    board.taken = xor(board.taken, source)
    board.white |= target
    board.white = xor(board.white, source)

    if board.black & target != EMPTY
        board.black = xor(board.black, target)
        filter!(e -> e != target, board.p)
        filter!(e -> e != target, board.q)
        filter!(e -> e != target, board.n)
        filter!(e -> e != target, board.b)
        filter!(e -> e != target, board.r)
    end

    if source in board.P
        filter!(e -> e != source, board.P)
        push!(board.P, target)
    elseif source in board.Q
        filter!(e -> e != source, board.Q)
        push!(board.Q, target)
    elseif source == board.K
        board.K = target
    elseif source in board.N
        filter!(e -> e != source, board.N)
        push!(board.N, target)
    elseif source in board.R
        filter!(e -> e != source, board.R)
        push!(board.R, target)
    elseif source in board.B
        filter!(e -> e != source, board.B)
        push!(board.B, target)
    end

    return update_attacked(board)
end

function move_black_piece(board::Bitboard, source::UInt64, target::UInt64)
    board.free |= source
    board.free = xor(board.free, target)
    board.taken |= target
    board.taken = xor(board.taken, source)
    board.black |= target
    board.black = xor(board.black, source)

    if board.white & target != EMPTY
        board.white = xor(board.white, target)
        filter!(e -> e != target, board.P)
        filter!(e -> e != target, board.Q)
        filter!(e -> e != target, board.N)
        filter!(e -> e != target, board.B)
        filter!(e -> e != target, board.R)
    end

    if source in board.p != EMPTY
        filter!(e -> e != source, board.p)
        push!(board.p, target)
    elseif source in board.q
        filter!(e -> e != source, board.q)
        push!(board.q, target)
    elseif source in board.k
        board.k = xor(board.k, source)
        board.k = target
    elseif source in board.n
        filter!(e -> e != source, board.n)
        push!(board.n, target)
    elseif source in board.r
        filter!(e -> e != source, board.r)
        push!(board.r, target)
    elseif source in board.b
        filter!(e -> e != source, board.b)
        push!(board.b, target)
    end
    return update_attacked(board)
end

function move_piece(board::Bitboard, source::UInt64, target::UInt64, color::String="white")
    if color == "white"
        return move_white_piece(board, source, target)
    else
        return move_black_piece(board, source, target)
    end
end
