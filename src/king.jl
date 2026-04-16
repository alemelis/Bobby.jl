#http://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/nonsliding.html
const K_CLEAR_FILES = (0x7f7f7f7f7f7f7f7f, 0xffffffffffffffff, 
                       0xfefefefefefefefe, 0xfefefefefefefefe,
                       0xfefefefefefefefe, 0xffffffffffffffff,
                       0x7f7f7f7f7f7f7f7f, 0x7f7f7f7f7f7f7f7f)
const K_MASK_FILES = (0x8080808080808080, 0xffffffffffffffff,
                      0x0101010101010101, 0x0101010101010101,
                      0x0101010101010101, 0xffffffffffffffff,
                      0x8080808080808080, 0x8080808080808080)
const K_SHIFTS = (9, 8, 7, -1, -9, -8, -7, 1)

#pseudo moves
function kingMovesGen()
    king_moves = Vector{UInt64}(undef, 64)

    for square in values(PGN2UINT)
        targets = EMPTY
        for (mask, clear, shift) in zip(K_MASK_FILES, K_CLEAR_FILES, K_SHIFTS)
            if square & mask != EMPTY
                targets |= (square & clear) << shift
            else
                targets |= square << shift
            end
        end
        king_moves[sq2idx(square)] = targets
    end

    return king_moves
end
const KING = kingMovesGen()

function inCheck(b::Board, white::Bool, K::UInt64=EMPTY)
    if K == EMPTY; K = white ? b.white.K : b.black.K end
    enemy = white ? b.black : b.white

    kidx = sq2idx(K)
    if KNIGHT[kidx] & enemy.N != EMPTY; return true end

    if KING[kidx] & enemy.K != EMPTY; return true end

    ortho = getMagicAttack(K, b.taken, true)
    if ortho & enemy.R != EMPTY || ortho & enemy.Q != EMPTY; return true end

    diago = getMagicAttack(K, b.taken, false)
    if diago & enemy.B != EMPTY || diago & enemy.Q != EMPTY; return true end

    x_pawn = white ? PAWN_X_WHITE : PAWN_X_BLACK
    if x_pawn[kidx] & enemy.P != EMPTY; return true end

    return false
end

function getCastlingMoves!(moves::Moves, K::UInt64, b::Board, white::Bool)
    if b.castling == NOCASTLING || inCheck(b, white); return end
    if white
        if CQ&b.castling != NOCASTLING && A1&b.white.R != EMPTY
            if B1C1D1 & b.taken == EMPTY
                if !inCheck(b, white, D1) && !inCheck(b, white, C1)
                    push!(moves, Move(PIECE_KING, K, C1, NONE, EMPTY, PIECE_NONE, CQ))
                end
            end
        end
        if CK&b.castling != NOCASTLING && H1&b.white.R != EMPTY
            if F1G1 & b.taken == EMPTY
                if !inCheck(b, white, F1) && !inCheck(b, white, G1)
                    push!(moves, Move(PIECE_KING, K, G1, NONE, EMPTY, PIECE_NONE, CK))
                end
            end
        end
    else
        if Cq&b.castling != NOCASTLING && A8&b.black.R != EMPTY
            if B8C8D8 & b.taken == EMPTY
                if !inCheck(b, white, D8) && !inCheck(b, white, C8)
                    push!(moves, Move(PIECE_KING, K, C8, NONE, EMPTY, PIECE_NONE, Cq))
                end
            end
        end
        if Ck&b.castling != NOCASTLING && H8&b.black.R != EMPTY
            if F8G8 & b.taken == EMPTY
                if !inCheck(b, white, F8) && !inCheck(b, white, G8)
                    push!(moves, Move(PIECE_KING, K, G8, NONE, EMPTY, PIECE_NONE, Ck))
                end
            end
        end
    end
end

