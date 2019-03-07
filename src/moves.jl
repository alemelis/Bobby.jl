mutable struct Move
    source :: UInt64
    target :: UInt64
    piece_type :: String
    capture_type :: String
    promotion_type :: String
    check :: Bool
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
    valid_moves = Set{Move}()
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
        else
            pieces = board.n
        end
        opponent_color = "white"
    end

    if piece_type == "king"
        piece_dict = KING_MOVES
    else
        piece_dict = NIGHT_MOVES
    end

    piece_moves = Set{Move}()
    for piece in pieces
        for move in piece_dict[piece]
            if move & other_king == EMPTY
                if move & same == EMPTY && move & other == EMPTY
                    push!(piece_moves, Move(piece, move,
                                            piece_type, "none", "none", false))
                elseif move & same == EMPTY && move & other != EMPTY
                    taken_piece = find_piece_type(board, move, opponent_color)
                    push!(piece_moves, Move(piece, move,
                                            piece_type, taken_piece,
                                            "none", false))
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

    piece_moves = Set{Move}()
    for piece in pieces
        moves, edges = attack_fun(board.taken, piece)
        for move in moves
            push!(piece_moves, Move(piece, move, piece_type,
                "none", "none", false))
        end
        for edge in edges
            if edge & other_king == EMPTY
                if edge & same == EMPTY && edge & other == EMPTY
                    push!(piece_moves, Move(piece, edge, piece_type,
                                            "none", "none", false))
                elseif edge & same == EMPTY && edge & other != EMPTY
                    taken_piece = find_piece_type(board, edge, opponent_color)
                    push!(piece_moves, Move(piece, edge, piece_type,
                                            taken_piece, "none", false))
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
    return board
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
    return board
end

function move_piece(board::Bitboard, move::Move, color::String="white")
    if color == "white"
        board = move_white_piece(board, move.source, move.target)
    else
        board = move_black_piece(board, move.source, move.target)
    end
    # board = update_attacked(board)
    if check_check_raytrace(board, change_color(color))
        move.check = true
    end
    return board
end

function unmove_piece(board::Bitboard, move::Move, color::String="white")
    if color == "white"
        board = move_white_piece(board, move.target, move.source)
        if move.capture_type != "none"
            if move.capture_type == "queen"
                push!(board.q, move.target)
            elseif move.capture_type == "rook"
                push!(board.r, move.target)
            elseif move.capture_type == "pawn"
                push!(board.p, move.target) 
            elseif move.capture_type == "night"
                push!(board.n, move.target)
            elseif move.capture_type == "bishop"
                push!(board.b, move.target)
            end
            board.black |= move.target
            board.taken |= move.target
            board.free = xor(board.free, move.target)
        end
    else
        board = move_black_piece(board, move.target, move.source)
        if move.capture_type != "none"
            if move.capture_type == "queen"
                push!(board.Q, move.target)
            elseif move.capture_type == "rook"
                push!(board.R, move.target)
            elseif move.capture_type == "pawn"
                push!(board.P, move.target) 
            elseif move.capture_type == "night"
                push!(board.N, move.target)
            elseif move.capture_type == "bishop"
                push!(board.B, move.target)
            end
            board.white |= move.target
            board.taken |= move.target
            board.free = xor(board.free, move.target)
        end
    end
    # return update_attacked(board)
    return board
end
