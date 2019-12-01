function fen_to_chessboard(fen_string::String)
    white = EMPTY
    R = EMPTY
    N = EMPTY
    B = EMPTY
    Q = EMPTY
    K = EMPTY
    P = EMPTY

    black = EMPTY
    r = EMPTY
    n = EMPTY
    b = EMPTY
    q = EMPTY
    k = EMPTY
    p = EMPTY

    free = EMPTY
    taken = EMPTY

    white_attacks = EMPTY
    black_attacks = EMPTY

    # board
    fen = split(fen_string, ' ')
    board = fen[1]
    square_i = 1
    fen_i = 1
    while true
        c = board[fen_i]
        if isnumeric(c)
            square_i += parse(Int64, c)
            fen_i += 1
        elseif c == '/'
            fen_i += 1
        else
            if isuppercase(c)
                # white
                white |= INT2UINT[square_i]
                if c == 'R'
                    R |= INT2UINT[square_i]
                elseif c == 'N'
                    N |= INT2UINT[square_i]
                elseif c == 'B'
                    B |= INT2UINT[square_i]
                elseif c == 'Q'
                    Q |= INT2UINT[square_i]
                elseif c == 'K'
                    K |= INT2UINT[square_i]
                elseif c == 'P'
                    P |= INT2UINT[square_i]
                end
            else
                # black
                black |= INT2UINT[square_i]
                if c == 'r'
                    r |= INT2UINT[square_i]
                elseif c == 'n'
                    n |= INT2UINT[square_i]
                elseif c == 'b'
                    b |= INT2UINT[square_i]
                elseif c == 'q'
                    q |= INT2UINT[square_i]
                elseif c == 'k'
                    k |= INT2UINT[square_i]
                elseif c == 'p'
                    p |= INT2UINT[square_i]
                end
            end
            square_i += 1
            fen_i += 1
        end

        if fen_i > length(board)
            
            if square_i != 65
                throw(ArgumentError("Invalid FEN string: too short/long"))
            end

            taken = white | black
            free = ~taken

            break
        end
    end

    if fen[2] == "w"
        player_color = "white"
    else
        player_color = "black"
    end

    white_king_moved = false
    black_king_moved = false
    if k != PGN2UINT["e8"]
        black_king_moved = true
    end
    if K != PGN2UINT["e1"]
        white_king_moved = true
    end
    white_can_castle_queenside = false
    white_can_castle_kingside = false
    black_can_castle_queenside = false
    black_can_castle_kingside = false
    for c in fen[3]
        if c == '-'
            break
        elseif c == 'K'
            white_can_castle_kingside = true
        elseif c == 'Q'
            white_can_castle_queenside = true
        elseif c == 'k'
            black_can_castle_kingside = true
        elseif c == 'q'
            black_can_castle_queenside = true
        end
    end
    
    enpassant_square = EMPTY
    if fen[4] != "-"
        enpassant_square = PGN2UINT[fen[4]]
    end 
    
    if length(fen) >= 5
        halfmove_clock = parse(Int64, fen[5])
    else
        halfmove_clock = 1
        fullmove_clock = 0
    end
    if length(fen) == 6
        fullmove_clock = parse(Int64, fen[6])
    end

    game = Array{String,1}[]
    enpassant_history = Array{UInt64,1}[]
    
    A = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY]
    a = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY]

    white_board = Bitboard(white, P, R, N, B, Q, K, A, "white",
        MASK_RANK_2, MASK_RANK_7, WHITE_PAWN_ONESTEP_MOVES,
        WHITE_PAWN_TWOSTEPS_MOVES, WHITE_PAWN_ATTACK, MASK_RANK_6,
        WHITE_KING_HOME, F1, G1, D1, C1, H1, A1,
        white_king_moved, white_can_castle_kingside, white_can_castle_queenside)

    black_board = Bitboard(black, p, r, n, b, q, k, a, "black",
        MASK_RANK_7, MASK_RANK_2, BLACK_PAWN_ONESTEP_MOVES,
        BLACK_PAWN_TWOSTEPS_MOVES, BLACK_PAWN_ATTACK, MASK_RANK_3,
        BLACK_KING_HOME, F8, G8, D8, C8, H8, A8,
        black_king_moved, black_can_castle_kingside, black_can_castle_queenside)

    chessboard = Chessboard(white_board, black_board, free, taken,
        white_attacks, black_attacks, player_color,
        enpassant_square, halfmove_clock, fullmove_clock,
        fen_string, game, enpassant_history)

    update_both_sides_attacked!(chessboard)
    return chessboard
end
