"""
    fen_to_bitboard(fen::String)

Populate a Bitboard starting from a board position given in FEN notation.

Example:
--------

    julia> Bobby.fen_to_bitboard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    Bitboard(0x000000000000ffff, 0x000000000000ff00, 0x0000000000000081,
        0x0000000000000042, 0x0000000000000024, 0x0000000000000010,
        0x0000000000000008, 0xffff000000000000, 0x00ff000000000000,
        0x8100000000000000, 0x4200000000000000, 0x2400000000000000,
        0x1000000000000000, 0x0800000000000000, 0x0000ffffffff0000,
        0xffff00000000ffff, 0x0000000000000000, 0x0000000000000000,
        false, false, false, false, false, false,
        false, false, false, false, false, false)
"""
function fen_to_bitboard(fen::String)
    white = UInt64(0)
    R = zeros(UInt64, 0)
    N = zeros(UInt64, 0)
    B = zeros(UInt64, 0)
    Q = zeros(UInt64, 0)
    K = UInt64(0)
    P = zeros(UInt64, 0)

    black = UInt64(0)
    r = zeros(UInt64, 0)
    n = zeros(UInt64, 0)
    b = zeros(UInt64, 0)
    q = zeros(UInt64, 0)
    k = UInt64(0)
    p = zeros(UInt64, 0)

    white_attacks = UInt64(0)
    black_attacks = UInt64(0)

    white_castled = false
    black_castled = false
    white_king_moved = false
    black_king_moved = false
    a1_rook_moved = false
    h1_rook_moved = false
    a8_rook_moved = false
    h8_rook_moved = false
    white_OO = false
    white_OOO = false
    black_OO = false
    black_OOO = false

    int_to_uint = gen_int_to_uint_dict()

    square_i = 1
    fen_i = 1
    while true
        c = fen[fen_i]
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
                    push!(R, int_to_uint[square_i])
                elseif c == 'N'
                    push!(N, int_to_uint[square_i])
                elseif c == 'B'
                    push!(B, int_to_uint[square_i])
                elseif c == 'Q'
                    push!(Q, int_to_uint[square_i])
                elseif c == 'K'
                    K |= INT2UINT[square_i]
                elseif c == 'P'
                    push!(P, int_to_uint[square_i])
                end
            else
                # black
                black |= INT2UINT[square_i]
                if c == 'r'
                    push!(r, int_to_uint[square_i])
                elseif c == 'n'
                    push!(n, int_to_uint[square_i])
                elseif c == 'b'
                    push!(b, int_to_uint[square_i])
                elseif c == 'q'
                    push!(q, int_to_uint[square_i])
                elseif c == 'k'
                    k |= INT2UINT[square_i]
                elseif c == 'p'
                    push!(p, int_to_uint[square_i])
                end
            end
            square_i += 1
            fen_i += 1
        end

        if fen_i > length(fen)
            
            if square_i != 65
                throw(ArgumentError("Invalid FEN string: too short/long"))
            end

            taken = white | black
            free = ~taken

            return Bitboard(white, P, R, N, B, Q, K, black,
                p, r, n, b, q, k, free, taken,
                white_attacks, black_attacks,
                white_castled, black_castled,
                white_king_moved, black_king_moved,
                a1_rook_moved, h1_rook_moved,
                a8_rook_moved, h8_rook_moved,
                white_OO, white_OOO, black_OO, black_OOO) 
        end
    end
end
