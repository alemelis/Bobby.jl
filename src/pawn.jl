function getPawnAttack(attack::UInt64, b::UInt64, white::Bool)
    if white
        lx_clear, lx_shift = CLEAR_FILE_A, 9
        rx_shift, rx_clear = 7, CLEAR_FILE_H
    else
        lx_clear, lx_shift = CLEAR_FILE_H, -9
        rx_shift, rx_clear = -7, CLEAR_FILE_A
    end
    attack |= (b & lx_clear) << lx_shift
    return attack |= (b & rx_clear) << rx_shift
end

function getPawnMoves!(moves::Moves, bitboard::UInt64, taken::UInt64, friends::UInt64,
                       enemy::ChessSet, white::Bool, enpassant::UInt64)
    if white
        shift, home, prom = 8, MASK_RANKS[2], MASK_RANKS[8]
    else
        shift, home, prom = -8, MASK_RANKS[7], MASK_RANKS[1]
    end

    one_step = (bitboard << shift) & ~taken
    bb = one_step
    while bb != EMPTY
        target = lsb(bb); bb = popbit(bb)
        if target & prom != EMPTY
            src = target >> shift
            for p in (PIECE_KNIGHT, PIECE_BISHOP, PIECE_ROOK, PIECE_QUEEN)
                push!(moves, Move(PIECE_PAWN, src, target, NONE, EMPTY, p, NOCASTLING))
            end
        else
            push!(moves, Move(PIECE_PAWN, target >> shift, target, NONE, EMPTY, PIECE_NONE, NOCASTLING))
        end
    end

    two_steps = ((((bitboard & home) << shift) & ~taken) << shift) & ~taken
    bb = two_steps
    while bb != EMPTY
        target = lsb(bb); bb = popbit(bb)
        push!(moves, Move(PIECE_PAWN, target >> (shift*2), target, NONE, target >> shift, PIECE_NONE, NOCASTLING))
    end

    lx_clear, lx_shift = white ? (CLEAR_FILE_A, 9) : (CLEAR_FILE_H, -9)
    x_lx = (((bitboard & lx_clear) << lx_shift) & taken) & ~friends
    bb = x_lx
    while bb != EMPTY
        target = lsb(bb); bb = popbit(bb)
        if target & enemy.friends != EMPTY
            take = Piece(getTypeAt(enemy, target), target)
            if target & prom != EMPTY
                src = target >> lx_shift
                for p in (PIECE_KNIGHT, PIECE_BISHOP, PIECE_ROOK, PIECE_QUEEN)
                    push!(moves, Move(PIECE_PAWN, src, target, take, EMPTY, p, NOCASTLING))
                end
            else
                push!(moves, Move(PIECE_PAWN, target >> lx_shift, target, take, EMPTY, PIECE_NONE, NOCASTLING))
            end
        end
    end

    en_lx = (((bitboard & lx_clear) << lx_shift) & ~taken) & enpassant
    if en_lx != EMPTY
        src = lsb(en_lx) >> lx_shift
        take = Piece(PIECE_PAWN, enpassant << -shift)
        push!(moves, Move(PIECE_PAWN, src, enpassant, take, EMPTY, PIECE_NONE, NOCASTLING))
    end

    rx_shift, rx_clear = white ? (7, CLEAR_FILE_H) : (-7, CLEAR_FILE_A)
    x_rx = (((bitboard & rx_clear) << rx_shift) & taken) & ~friends
    bb = x_rx
    while bb != EMPTY
        target = lsb(bb); bb = popbit(bb)
        if target & enemy.friends != EMPTY
            take = Piece(getTypeAt(enemy, target), target)
            if target & prom != EMPTY
                src = target >> rx_shift
                for p in (PIECE_KNIGHT, PIECE_BISHOP, PIECE_ROOK, PIECE_QUEEN)
                    push!(moves, Move(PIECE_PAWN, src, target, take, EMPTY, p, NOCASTLING))
                end
            else
                push!(moves, Move(PIECE_PAWN, target >> rx_shift, target, take, EMPTY, PIECE_NONE, NOCASTLING))
            end
        end
    end

    en_rx = (((bitboard & rx_clear) << rx_shift) & ~taken) & enpassant
    if en_rx != EMPTY
        src = lsb(en_rx) >> rx_shift
        take = Piece(PIECE_PAWN, enpassant << -shift)
        push!(moves, Move(PIECE_PAWN, src, enpassant, take, EMPTY, PIECE_NONE, NOCASTLING))
    end
end

function pawnMovesGen(white::Bool)
    pawn_moves   = Vector{UInt64}(undef, 64)
    pawn_attacks = Vector{UInt64}(undef, 64)

    if white
        home, lx_clear, rx_clear = MASK_RANKS[2], CLEAR_FILE_A, CLEAR_FILE_H
    else
        home, lx_clear, rx_clear = MASK_RANKS[7], CLEAR_FILE_H, CLEAR_FILE_A
    end

    for square in values(PGN2UINT)
        targets = EMPTY
        attacks = EMPTY
        white ? targets |= square << 8 : targets |= square >> 8
        if square & lx_clear != EMPTY
            attacks |= square << (white ? 9 : -9)
        end
        if square & rx_clear != EMPTY
            attacks |= square << (white ? 7 : -7)
        end
        if square & home != EMPTY
            white ? targets |= square << 16 : targets |= square >> 16
        end
        idx = sq2idx(square)
        pawn_moves[idx]   = targets
        pawn_attacks[idx] = attacks
    end

    return pawn_moves, pawn_attacks
end
const PAWN_WHITE, PAWN_X_WHITE = pawnMovesGen(true)
const PAWN_BLACK, PAWN_X_BLACK = pawnMovesGen(false)

