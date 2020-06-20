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
    
    return Board(white, black, taken, active, castling, enpassant, halfmove, fullmove)
end

function setBoard()
    return loadFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
end

function getTypeAt(pieces::ChessSet, square::UInt64)
    if pieces.P & square != EMPTY
        return :pawn
    elseif pieces.N & square != EMPTY
        return :knight
    elseif pieces.B & square != EMPTY
        return :bishop
    elseif pieces.R & square != EMPTY
        return :rook
    elseif pieces.Q & square != EMPTY
        return :queen
    elseif pieces.K & square != EMPTY
        return :king
    else
        return :none
    end
end

function bitshift(p::UInt64)
    rx = 64-trailing_zeros(p)
    return INT2UINT[rx], abs(leading_zeros(p)+1-rx)    
end


