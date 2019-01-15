# rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR

function fen2Bitboard(fen::String)
    white = falses(64)
    P = falses(64)
    R = falses(64)
    N = falses(64)
    B = falses(64)
    Q = falses(64)
    K = falses(64)

    black = falses(64)
    p = falses(64)
    r = falses(64)
    n = falses(64)
    b = falses(64)
    q = falses(64)
    k = falses(64)

    free = trues(64)
    taken = falses(64)

    white_attacks = falses(64)
    black_attacks = falses(64)

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

    i = 1
    ci = 1
    while true
        c = fen[ci]
        if isnumeric(c)
            i += parse(Int64, c)
            ci += 1
        elseif c == '/'
            ci += 1
        else
            if isuppercase(c)
                white[i] = true
                if c == 'R'
                    R[i] = true
                elseif c == 'N'
                    N[i] = true
                elseif c == 'B'
                    B[i] = true
                elseif c == 'Q'
                    Q[i] = true
                elseif c == 'K'
                    K[i] = true
                else
                    P[i] = true
                end
            else
                black[i] = true

                if c == 'r'
                    r[i] = true
                elseif c == 'n'
                    n[i] = true
                elseif c == 'b'
                    b[i] = true
                elseif c == 'q'
                    q[i] = true
                elseif c == 'k'
                    k[i] = true
                else
                    p[i] = true
                end
            end
            free[i] = false
            taken[i] = true
            ci += 1
            i += 1
        end
        if ci > length(fen)
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




    