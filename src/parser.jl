"""
    binary_string_to_int(binary_string::String)

Convert a 64-characters long string representing a binary number into an UInt64.

Example:
--------

    julia> Bobby.binary_string_to_int(
    "0000000000000000000000000000000000000000000000000000000000000001")
    0x0000000000000001
"""
function binary_string_to_int(binary_string::String)
    return parse(UInt64, binary_string; base=2)
end


"""
    int_to_binary_string(i::UInt64)

Convert an UInt64 to a 64-characters long string.

Example:
--------

    julia> Bobby.int_to_binary_string(0x0000000000000001)
    "0000000000000000000000000000000000000000000000000000000000000001"
"""
function uint_to_binary_string(i::UInt64)
    return bitstring(i)
end


"""
    int_to_binary_string(i::Int64)

Convert an Int64 to a 64-characters long string.

Example:
--------

    julia> Bobby.int_to_binary_string(1)
    "0000000000000000000000000000000000000000000000000000000000000001"
"""
function int_to_binary_string(i::Int64)
    return bitstring(i)
end


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
    squares = generate_int_to_uint()
    return fen_to_bitboard(fen, squares)
end

function fen_to_bitboard(fen::String, squares::Dict{Int64,UInt64})
    white = UInt64(0)
    R = UInt64(0)
    N = UInt64(0)
    B = UInt64(0)
    Q = UInt64(0)
    K = UInt64(0)
    P = UInt64(0)

    black = UInt64(0)
    r = UInt64(0)
    n = UInt64(0)
    b = UInt64(0)
    q = UInt64(0)
    k = UInt64(0)
    p = UInt64(0)

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
                white |= squares[square_i]
                if c == 'R'
                    R |= squares[square_i]
                elseif c == 'N'
                    N |= squares[square_i]
                elseif c == 'B'
                    B |= squares[square_i]
                elseif c == 'Q'
                    Q |= squares[square_i]
                elseif c == 'K'
                    K |= squares[square_i]
                elseif c == 'P'
                    P |= squares[square_i]
                end
            else
                # black
                black |= squares[square_i]
                if c == 'r'
                    r |= squares[square_i]
                elseif c == 'n'
                    n |= squares[square_i]
                elseif c == 'b'
                    b |= squares[square_i]
                elseif c == 'q'
                    q |= squares[square_i]
                elseif c == 'k'
                    k |= squares[square_i]
                elseif c == 'p'
                    p |= squares[square_i]
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











# # rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
# function fen2Bitboard(fen::String)
#     white = falses(64)
#     P = falses(64)
#     R = falses(64)
#     N = falses(64)
#     B = falses(64)
#     Q = falses(64)
#     K = falses(64)

#     black = falses(64)
#     p = falses(64)
#     r = falses(64)
#     n = falses(64)
#     b = falses(64)
#     q = falses(64)
#     k = falses(64)

#     free = trues(64)
#     taken = falses(64)

#     white_attacks = falses(64)
#     black_attacks = falses(64)

#     #TODO: find a better way to initialise these flags
#     white_castled = false
#     black_castled = false
#     white_king_moved = false
#     black_king_moved = false
#     a1_rook_moved = false
#     h1_rook_moved = false
#     a8_rook_moved = false
#     h8_rook_moved = false
#     white_OO = false
#     white_OOO = false
#     black_OO = false
#     black_OOO = false

#     i = 1
#     ci = 1
#     while true
#         c = fen[ci]
#         if isnumeric(c)
#             i += parse(Int64, c)
#             ci += 1
#         elseif c == '/'
#             ci += 1
#         else
#             if isuppercase(c)
#                 white[i] = true
#                 if c == 'R'
#                     R[i] = true
#                 elseif c == 'N'
#                     N[i] = true
#                 elseif c == 'B'
#                     B[i] = true
#                 elseif c == 'Q'
#                     Q[i] = true
#                 elseif c == 'K'
#                     K[i] = true
#                 else
#                     P[i] = true
#                 end
#             else
#                 black[i] = true

#                 if c == 'r'
#                     r[i] = true
#                 elseif c == 'n'
#                     n[i] = true
#                 elseif c == 'b'
#                     b[i] = true
#                 elseif c == 'q'
#                     q[i] = true
#                 elseif c == 'k'
#                     k[i] = true
#                 else
#                     p[i] = true
#                 end
#             end
#             free[i] = false
#             taken[i] = true
#             ci += 1
#             i += 1
#         end
#         if ci > length(fen)
#             return Bitboard_(white, P, R, N, B, Q, K, black,
#                 p, r, n, b, q, k, free, taken,
#                 white_attacks, black_attacks,
#                 white_castled, black_castled,
#                 white_king_moved, black_king_moved,
#                 a1_rook_moved, h1_rook_moved,
#                 a8_rook_moved, h8_rook_moved,
#                 white_OO, white_OOO, black_OO, black_OOO)
#         end
#     end
# end