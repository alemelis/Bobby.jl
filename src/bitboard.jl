function show(b::UInt64)
    border = "\n   " * '▄'^18 * "\n"
    @printf(Crayon(reset=true, foreground=:dark_gray), "%s", border)
    dark = false
    for rank = 8:-1:1
        @printf(Crayon(reset=true, foreground=:dark_gray), " %s █", rank)
        for file = 1:8
            i = (8-rank)*8+file
            if b & INT2UINT[i] != EMPTY
                @printf(Crayon(reset=true, foreground=:red, bold=true,
                               background=(dark ? :dark_gray : :light_gray)), "%s", 'x')
            else
                @printf(Crayon(reset=true, foreground=(dark ? :dark_gray : :light_gray)), "█")
            end
            @printf(Crayon(reset=true, foreground=(dark ? :dark_gray : :light_gray)), "█")
            file != 8 ? dark = !dark : continue
        end
        @printf(Crayon(reset=true, foreground=:dark_gray), "█")
        rank != 1 ? @printf("\n") : continue
    end
    lower_border = "\n   " * '▀'^18 * "\n"
    @printf("%s", lower_border)
    @printf("    a b c d e f g h\n")
end

function getSymbol(cs::ChessSet, sq::UInt64)
    if cs.P & sq != EMPTY
        return 'o'
    elseif cs.N & sq != EMPTY
        return 'ζ'
    elseif cs.B & sq != EMPTY
        return 'Δ'
    elseif cs.R & sq != EMPTY
        return 'Π'
    elseif cs.Q & sq != EMPTY
        return 'Ψ'
    elseif cs.K & sq != EMPTY
        return '+'
    end
    return ' '
end

function Base.show(io::IO, b::Board)
    frame = :dark_gray
    dark_square = :blue
    light_square = :cyan
    border = "\n   " * '▄'^18 * "\n"
    @printf(Crayon(reset=true, foreground=frame), "%s", border)
    dark = false
    for rank = 8:-1:1
        @printf(Crayon(reset=true, foreground=frame), " %s █", rank)
        for file = 1:8
            i = (8-rank)*8+file
            if b.taken & INT2UINT[i] != EMPTY
                c = getSymbol(b.white, INT2UINT[i])
                if c != ' '
                    color = :red
                else
                    color = :dark_gray
                    c = getSymbol(b.black, INT2UINT[i])
                end
                @printf(Crayon(reset=true, foreground=color, bold=true,
                               background=(dark ? dark_square : light_square)), "%s", c)
            else
                @printf(Crayon(reset=true, foreground=(dark ? dark_square : light_square)), "█")
            end
            @printf(Crayon(reset=true, foreground=(dark ? dark_square : light_square)), "█")
            file != 8 ? dark = !dark : continue
        end
        @printf(Crayon(reset=true, foreground=frame), "█")
        rank != 1 ? @printf("\n") : continue
    end
    lower_border = "\n   " * '▀'^18 * "\n"
    @printf("%s", lower_border)
    @printf("    a b c d e f g h\n")
end

function plainPrint(b::Board)
    border = "\n   " * '▄'^18 * "\n"
    @printf("%s", border)
    dark = false
    for rank = 8:-1:1
        @printf(" %s █", rank)
        for file = 1:8
            i = (8-rank)*8+file
            if b.taken & INT2UINT[i] != EMPTY
                c = getSymbol(b.white, INT2UINT[i])
                if c != ' '
                    color = :red
                else
                    color = :dark_gray
                    c = getSymbol(b.black, INT2UINT[i])
                end
                @printf("%s", c)
            else
                @printf("⋅")
            end
            @printf(" ")
            file != 8 ? dark = !dark : continue
        end
        @printf("█")
        rank != 1 ? @printf("\n") : continue
    end
    lower_border = "\n   " * '▀'^18 * "\n"
    @printf("%s", lower_border)
    @printf("    a b c d e f g h\n")
end


function loadFen(fen::String)
    board, active_str, castling_str, enpassant, halfmove, fullmove = split(fen)
    active = active_str == "w"
    castling = UInt8(0)
    if castling_str != "-"
        if occursin("K", castling_str); castling |= CK end
        if occursin("Q", castling_str); castling |= CQ end
        if occursin("k", castling_str); castling |= Ck end
        if occursin("q", castling_str); castling |= Cq end
    end
    enpassant != "-" ? enpassant = PGN2UINT[enpassant] : enpassant = EMPTY

    pieces = Dict{Char,UInt64}()
    for c in ['P', 'N', 'B', 'R', 'Q', 'K']
        push!(pieces, c=>EMPTY)
        push!(pieces, lowercase(c)=>EMPTY)
    end

    i = 1
    str_i = 1
    while str_i <= length(board)
        c = board[str_i]
        if isnumeric(c)
            i += parse(Int64, c)
        elseif c != '/'
            pieces[c] |= INT2UINT[i]
            i += 1
        end
        str_i += 1
    end

    whites = EMPTY
    blacks = EMPTY
    for c in ['P', 'N', 'B', 'R', 'Q', 'K']
        whites |= pieces[c]
        blacks |= pieces[lowercase(c)]
    end

    white = ChessSet(pieces['P'], pieces['N'], pieces['B'],
                     pieces['R'], pieces['Q'], pieces['K'],
                     whites)
    black = ChessSet(pieces['p'], pieces['n'], pieces['b'],
                     pieces['r'], pieces['q'], pieces['k'],
                     blacks)

    taken = EMPTY
    taken = whites |= blacks

    halfmove = parse(Int64, halfmove)
    fullmove = parse(Int64, fullmove)

    b = Board(white, black, taken, active, castling, enpassant, halfmove, fullmove, UInt64(0))
    return Board(white, black, taken, active, castling, enpassant, halfmove, fullmove, computeHash(b))
end

function setBoard()
    return loadFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
end

function computeHash(b::Board)::UInt64
    h = UInt64(0)
    for (cs, color) in ((b.white, 1), (b.black, 2))
        for (bb, pt) in ((cs.P, PIECE_PAWN), (cs.N, PIECE_KNIGHT), (cs.B, PIECE_BISHOP),
                         (cs.R, PIECE_ROOK), (cs.Q, PIECE_QUEEN), (cs.K, PIECE_KING))
            bbt = bb
            while bbt != EMPTY
                sq = lsb(bbt); bbt = popbit(bbt)
                h ⊻= ZOBRIST_PIECES[pt, color, sq2idx(sq)]
            end
        end
    end
    h ⊻= ZOBRIST_CASTLING[b.castling + 1]
    if b.enpassant != EMPTY
        h ⊻= ZOBRIST_EP[((trailing_zeros(b.enpassant) % 8) + 1)]
    else
        h ⊻= ZOBRIST_EP[9]
    end
    if !b.active
        h ⊻= ZOBRIST_SIDE
    end
    return h
end

function getTypeAt(pieces::ChessSet, square::UInt64)::UInt8
    pieces.P & square != EMPTY && return PIECE_PAWN
    pieces.N & square != EMPTY && return PIECE_KNIGHT
    pieces.B & square != EMPTY && return PIECE_BISHOP
    pieces.R & square != EMPTY && return PIECE_ROOK
    pieces.Q & square != EMPTY && return PIECE_QUEEN
    pieces.K & square != EMPTY && return PIECE_KING
    return PIECE_NONE
end


