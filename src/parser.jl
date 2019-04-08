function fen_to_bitboard(fen_string::String)
    white = EMPTY
    R = zeros(UInt64, 0)
    N = zeros(UInt64, 0)
    B = zeros(UInt64, 0)
    Q = zeros(UInt64, 0)
    K = EMPTY
    P = zeros(UInt64, 0)

    black = EMPTY
    r = zeros(UInt64, 0)
    n = zeros(UInt64, 0)
    b = zeros(UInt64, 0)
    q = zeros(UInt64, 0)
    k = EMPTY
    p = zeros(UInt64, 0)

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
                    push!(R, INT2UINT[square_i])
                elseif c == 'N'
                    push!(N, INT2UINT[square_i])
                elseif c == 'B'
                    push!(B, INT2UINT[square_i])
                elseif c == 'Q'
                    push!(Q, INT2UINT[square_i])
                elseif c == 'K'
                    K |= INT2UINT[square_i]
                elseif c == 'P'
                    push!(P, INT2UINT[square_i])
                end
            else
                # black
                black |= INT2UINT[square_i]
                if c == 'r'
                    push!(r, INT2UINT[square_i])
                elseif c == 'n'
                    push!(n, INT2UINT[square_i])
                elseif c == 'b'
                    push!(b, INT2UINT[square_i])
                elseif c == 'q'
                    push!(q, INT2UINT[square_i])
                elseif c == 'k'
                    k |= INT2UINT[square_i]
                elseif c == 'p'
                    push!(p, INT2UINT[square_i])
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
    enpassant_done = false
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

    return Bitboard(white, P, R, N, B, Q, K,
                    black, p, r, n, b, q, k,
                    free, taken,
                    white_attacks, black_attacks,
                    player_color,
                    white_can_castle_queenside,
                    white_can_castle_kingside,
                    black_can_castle_queenside,
                    black_can_castle_kingside,
                    enpassant_square,
                    enpassant_done,
                    halfmove_clock, fullmove_clock,
                    fen_string) 
end


function bitboard_to_fen(b::Bitboard)
    fen = ""
    i = 1
    rank_counter = 1
    empty_counter = 0
    for i = 1:64
        c = ""
        if INT2UINT[i] & b.taken != EMPTY
            if INT2UINT[i] & b.white != EMPTY
                if INT2UINT[i] in b.P
                    c = "P"
                elseif INT2UINT[i] in b.R
                    c = "R"
                elseif INT2UINT[i] in b.N
                    c = "N"
                elseif INT2UINT[i] in b.B
                    c = "B"
                elseif INT2UINT[i] in b.Q
                    c = "Q"
                elseif INT2UINT[i] == b.K
                    c = "K"
                end
            elseif INT2UINT[i] & b.black != EMPTY
                if INT2UINT[i] in b.p
                    c = "p"
                elseif INT2UINT[i] in b.r
                    c = "r"
                elseif INT2UINT[i] in b.n
                    c = "n"
                elseif INT2UINT[i] in b.b
                    c = "b"
                elseif INT2UINT[i] in b.q
                    c = "q"
                elseif INT2UINT[i] == b.k
                    c = "k"
                end
            end
        else
            c = ""
            empty_counter += 1
        end

        if c != "" && empty_counter != 0
            fen *= string(empty_counter)
            empty_counter = 0
        end
        fen *= c
        rank_counter += 1
        if (rank_counter > 8 && i != 64) || empty_counter == 8
            if empty_counter != 0
                fen *= string(empty_counter)
                empty_counter = 0
            end
            if i != 64
                fen *= "/"
            end
            rank_counter = 1
            empty_counter = 0
        end

        if i == 64 && empty_counter != 0
            fen *= string(empty_counter)
            break
        end
    end

    if b.player_color == "white"
        fen *= " w "
    else
        fen *= " b "
    end

    no_castling = true
    if b.white_can_castle_kingside
        fen *= "K"
        no_castling = false
    end
    if b.white_can_castle_queenside
        fen *= "Q"
        no_castling = false
    end
    if b.black_can_castle_kingside
        fen *= "k"
        no_castling = false
    end
    if b.black_can_castle_queenside
        fen *= "q"
        no_castling = false
    end
    if no_castling
        fen *= "-"
    end

    if b.enpassant_square != EMPTY
        fen *= " "*UINT2PGN[b.enpassant_square]*" "
    else
        fen *= " - "
    end

    fen *= string(b.halfmove_clock)*" "
    fen *= string(b.fullmove_clock)

    return fen
end
