"""
    ugly_print(i::UInt64)

Print any UInt64 bitboard in shape 8x8 (transposed) to REPL for debugging
purposes.
"""
function ugly_print(i::UInt64)
    bit_array = uint_to_bitarray(i)
    uglyPrint(bit_array)
end

function ugly_print(pieces_array::Array{UInt64,1})
    pieces_uint = uint_array_to_uint(pieces_array)
    ugly_print(pieces_uint)
end


"""
    binary_string_to_bitarray(s::String)

Convert a binary string to BitArray format for plotting purposes.

Example:
--------

    julia> Bobby.binary_string_to_bitarray(
        "0000000000000000000000000000000000000000000000000000000000000001")
    64-element BitArray{1}:
     false
         ⋮
      true
"""
function binary_string_to_bitarray(s::String)
    bit_array = falses(64)
    for i = 1:64
        if s[i] == '1'
            bit_array[i] = true
        end
    end

    return bit_array
end


"""
    uint_to_bitarray(i::UInt64)

Convert a UInt64 to BitArray format for plotting purposes.

Example:
--------

    julia> Bobby.uint_to_bitarray(0x000000000000ffff)
    64-element BitArray{1}:
     false
         ⋮
      true
"""
function uint_to_bitarray(i::UInt64)
    bs = uint_to_binary_string(i)
    return binary_string_to_bitarray(bs)
end


"""
    uglyPrint(b::BitArray)

Print any BitArray bitboard in shape 8x8 (transposed) to REPL for debuggin
purposes.
"""
function uglyPrint(b::BitArray)

    r_b = Int.(transpose(reshape(b, 8, :)))
    ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]

    @printf("\n  o-----------------o\n")
    for i = 1:8
        @printf("%s | ", ranks[i])
        for j = 1:8
            @printf("%d ", r_b[i,j])
        end
        @printf("|\n")
    end
    @printf("  o-----------------o\n")
    @printf("    a b c d e f g h\n")
end


"""
    pretty_print(b::Bitboard, player_color::String="white")

Print the bitboard.
"""
function pretty_print(board::Bitboard, player_color::String="white")
    ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]
    
    free = transpose(reshape(uint_to_bitarray(board.free), 8, :))
    taken = transpose(reshape(uint_to_bitarray(board.taken), 8, :))

    p = transpose(reshape(uint_array_to_bitarray(board.p), 8, :))
    r = transpose(reshape(uint_array_to_bitarray(board.r), 8, :))
    n = transpose(reshape(uint_array_to_bitarray(board.n), 8, :))
    b = transpose(reshape(uint_array_to_bitarray(board.b), 8, :))
    q = transpose(reshape(uint_array_to_bitarray(board.q), 8, :))
    k = transpose(reshape(uint_to_bitarray(board.k), 8, :))
    P = transpose(reshape(uint_array_to_bitarray(board.P), 8, :))
    R = transpose(reshape(uint_array_to_bitarray(board.R), 8, :))
    N = transpose(reshape(uint_array_to_bitarray(board.N), 8, :))
    B = transpose(reshape(uint_array_to_bitarray(board.B), 8, :))
    Q = transpose(reshape(uint_array_to_bitarray(board.Q), 8, :))
    K = transpose(reshape(uint_to_bitarray(board.K), 8, :))
    white = transpose(reshape(uint_to_bitarray(board.white), 8, :))
    black = transpose(reshape(uint_to_bitarray(board.black), 8, :))
    
    pieces = Dict("pawn"=>" o",
        "rook"=>" Π",
        "knight"=>" ζ",
        "bishop"=>" Δ",
        "queen"=>" Ψ",
        "king"=>" +")
    # pieces = Dict("pawn"=>" o",
    #   "rook"=>" R",
    #   "knight"=>" N",
    #   "bishop"=>" B",
    #   "queen"=>" Q",
    #   "king"=>" K")
    labels = ["pawn", "knight", "bishop", "rook", "queen", "king"]

    @printf("\n  o-------------------------o\n")
    
    if player_color == "white"
        idxs = 1:8
    else
        idxs = 8:-1:1
    end

    bgc = "w"
    for i in idxs
        @printf(Crayon(reset=true), "%s | ", ranks[i])
        for j in idxs
            if free[i,j]
                if bgc == "w"
                    @printf(Crayon(reset=true, background=:dark_gray), "   ")
                    bgc = "b"
                else
                    @printf(Crayon(reset=true, background=:default), "   ")
                    bgc = "w"
                end
            else
                if black[i,j]
                    if p[i,j]
                        c = pieces["pawn"]
                    elseif r[i,j]
                        c = pieces["rook"]
                    elseif n[i,j]
                        c = pieces["knight"]
                    elseif b[i,j]
                        c = pieces["bishop"]
                    elseif q[i,j]
                        c = pieces["queen"]
                    elseif k[i,j]
                        c = pieces["king"]
                    else
                        error("Black piece not found")
                    end
                    color = :light_magenta
                else
                    if P[i,j]
                        c = pieces["pawn"]
                    elseif R[i,j]
                        c = pieces["rook"]
                    elseif N[i,j]
                        c = pieces["knight"]
                    elseif B[i,j]
                        c = pieces["bishop"]
                    elseif Q[i,j]
                        c = pieces["queen"]
                    elseif K[i,j]
                        c = pieces["king"]
                    else
                        error("White piece not found")
                    end
                    color = :light_cyan
                end
                if bgc == "w"
                    @printf(Crayon(bold=true, foreground=color,
                        background=:dark_gray), "%s ", c)
                    bgc = "b"
                else
                    @printf(Crayon(bold=true, foreground=color,
                        background=:default), "%s ", c)
                    bgc = "w"
                end
                
            end
        end
        
        if i > 1 && i < 8
            label = labels[i-1]
            piece = pieces[label]
            @printf(Crayon(reset=true), "| %s %s \n", piece, label)
        else
            @printf(Crayon(reset=true), "|\n")
        end
        if bgc == "w"
            bgc = "b"
        else
            bgc = "w"
        end
    end
    @printf(Crayon(reset=true), "  o-------------------------o\n")

    if player_color == "white"
        @printf("     a  b  c  d  e  f  g  h\n")
    else
        @printf("     h  g  f  e  d  c  b  a\n")
    end
end

#-------------

"""
    prettyPrint(board::Bitboard_)

Print a colorful board with pieces in algebraic notation
(capitalised for white and lower cased for black).
"""
function prettyPrint(board::Bitboard_, player_color::String="white")
    
    ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]
    
    free = transpose(reshape(board.free, 8, :))
    taken = transpose(reshape(board.taken, 8, :))
    p = transpose(reshape(board.p, 8, :))
    r = transpose(reshape(board.r, 8, :))
    n = transpose(reshape(board.n, 8, :))
    b = transpose(reshape(board.b, 8, :))
    q = transpose(reshape(board.q, 8, :))
    k = transpose(reshape(board.k, 8, :))
    P = transpose(reshape(board.P, 8, :))
    R = transpose(reshape(board.R, 8, :))
    N = transpose(reshape(board.N, 8, :))
    B = transpose(reshape(board.B, 8, :))
    Q = transpose(reshape(board.Q, 8, :))
    K = transpose(reshape(board.K, 8, :))
    white = transpose(reshape(board.white, 8, :))
    black = transpose(reshape(board.black, 8, :))

    pieces = Dict("pawn"=>" o",
        "rook"=>" Π",
        "knight"=>" ζ",
        "bishop"=>" Δ",
        "queen"=>" Ψ",
        "king"=>" +")
    # pieces = Dict("pawn"=>" o",
    #   "rook"=>" R",
    #   "knight"=>" N",
    #   "bishop"=>" B",
    #   "queen"=>" Q",
    #   "king"=>" K")
    labels = ["pawn", "knight", "bishop", "rook", "queen", "king"]

    @printf("\n  o-------------------------o\n")
    
    if player_color == "white"
        idxs = 1:8
    else
        idxs = 8:-1:1
    end

    bgc = "w"
    for i in idxs
        @printf(Crayon(reset=true), "%s | ", ranks[i])
        for j in idxs
            if free[i,j]
                if bgc == "w"
                    @printf(Crayon(reset=true, background=:dark_gray), "   ")
                    bgc = "b"
                else
                    @printf(Crayon(reset=true, background=:default), "   ")
                    bgc = "w"
                end
            else
                if black[i,j]
                    if p[i,j]
                        c = pieces["pawn"]
                    elseif r[i,j]
                        c = pieces["rook"]
                    elseif n[i,j]
                        c = pieces["knight"]
                    elseif b[i,j]
                        c = pieces["bishop"]
                    elseif q[i,j]
                        c = pieces["queen"]
                    elseif k[i,j]
                        c = pieces["king"]
                    else
                        error("Black piece not found")
                    end
                    color = :light_magenta
                else
                    if P[i,j]
                        c = pieces["pawn"]
                    elseif R[i,j]
                        c = pieces["rook"]
                    elseif N[i,j]
                        c = pieces["knight"]
                    elseif B[i,j]
                        c = pieces["bishop"]
                    elseif Q[i,j]
                        c = pieces["queen"]
                    elseif K[i,j]
                        c = pieces["king"]
                    else
                        error("White piece not found")
                    end
                    color = :light_cyan
                end
                if bgc == "w"
                    @printf(Crayon(bold=true, foreground=color,
                        background=:dark_gray), "%s ", c)
                    bgc = "b"
                else
                    @printf(Crayon(bold=true, foreground=color,
                        background=:default), "%s ", c)
                    bgc = "w"
                end
                
            end
        end
        
        if i > 1 && i < 8
            label = labels[i-1]
            piece = pieces[label]
            @printf(Crayon(reset=true), "| %s %s \n", piece, label)
        else
            @printf(Crayon(reset=true), "|\n")
        end
        if bgc == "w"
            bgc = "b"
        else
            bgc = "w"
        end
    end
    @printf(Crayon(reset=true), "  o-------------------------o\n")

    if player_color == "white"
        @printf("     a  b  c  d  e  f  g  h\n")
    else
        @printf("     h  g  f  e  d  c  b  a\n")
    end
end