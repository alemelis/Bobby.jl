function getPawnMoves!(moves::Array{Move,1}, bitboard::UInt64, taken::UInt64, friends::UInt64,
                       enemy::ChessSet, white::Bool, enpassant::UInt64)
    white ? shift = 8 : shift = -8
    white ? home = MASK_RANKS[2] : home = MASK_RANKS[7]
    white ? prom = MASK_RANKS[8] : prom = MASK_RANKS[1]

    one_step = (bitboard << shift) & ~taken
    if one_step != EMPTY
        b0, d = bitshift(one_step)
        for j = 0:d
            if b0<<j & one_step != EMPTY
                target = b0<<j
                if target & prom != EMPTY
                    src = target>>shift
                    for p in [:knight, :bishop, :rook, :queen]
                        push!(moves, Move(:pawn, src, target, NONE, EMPTY, p, NOCASTLING))
                    end
                else
                    push!(moves, Move(:pawn, target>>shift, target, NONE, EMPTY, :none, NOCASTLING))
                end
            end
        end
    end

    two_steps = ((((bitboard & home) << shift) & ~taken) << shift) & ~taken
    if two_steps != EMPTY
        b0, d = bitshift(two_steps)
        for j = 0:d
            if b0<<j & two_steps != EMPTY
                target = b0<<j
                push!(moves, Move(:pawn, target>>(shift*2), target, NONE, target>>shift, :none, NOCASTLING))
            end
        end
    end

    white ? lx_clear = CLEAR_FILE_A : lx_clear = CLEAR_FILE_H
    white ? lx_shift = 9 : lx_shift = -9
    x_lx = (((bitboard & lx_clear) << lx_shift) & taken) & ~friends
    if x_lx != EMPTY
        b0, d = bitshift(x_lx)
        for j = 0:d
            if b0<<j & x_lx != EMPTY
                target = b0<<j
                if target & enemy.friends != EMPTY
                    take = Piece(getTypeAt(enemy, target), target)
                    if target & prom != EMPTY
                        src = target>>lx_shift
                        for p in  [:knight, :bishop, :rook, :queen]
                            push!(moves, Move(:pawn, src, target, take, EMPTY, p, NOCASTLING))
                        end
                    else
                        push!(moves, Move(:pawn, target>>lx_shift, target, take, EMPTY, :none, NOCASTLING))
                    end
                end
            end
        end
    end

    en_lx = (((bitboard & lx_clear) << lx_shift) & ~taken) & enpassant
    if en_lx != EMPTY
        b0, d = bitshift(en_lx)
        take = Piece(:pawn, enpassant<<-shift)
        push!(moves, Move(:pawn, b0>>lx_shift, enpassant, take, EMPTY, :none, NOCASTLING))
    end

    white ? rx_shift = 7 : rx_shift = -7
    white ? rx_clear = CLEAR_FILE_H : rx_clear = CLEAR_FILE_A
    x_rx = (((bitboard & rx_clear) << rx_shift) & taken) & ~friends
    if x_rx != EMPTY
        b0, d = bitshift(x_rx)
        for j = 0:d
            if b0<<j & x_rx != EMPTY
                target = b0<<j
                if target & enemy.friends != EMPTY
                    take = Piece(getTypeAt(enemy, target), target)
                    if target & prom != EMPTY
                        src = target>>rx_shift
                        for  p in  [:knight, :bishop, :rook, :queen]
                            push!(moves, Move(:pawn, src, target, take, EMPTY, p, NOCASTLING))
                        end
                    else
                        push!(moves, Move(:pawn, target>>rx_shift, target, take, EMPTY, :none, NOCASTLING))
                    end
                end
            end
        end
    end

    en_rx = (((bitboard & rx_clear) << rx_shift) & ~taken) & enpassant
    if en_rx != EMPTY
        b0, d = bitshift(en_rx)
        take = Piece(:pawn, enpassant<<-shift)
        push!(moves, Move(:pawn, b0>>rx_shift, enpassant, take, EMPTY, :none, NOCASTLING))
    end
end

function pawnMovesGen(white::Bool)
    pawn_moves = Dict{UInt64,UInt64}()
    pawn_attacks = Dict{UInt64,UInt64}()

    white ? home = MASK_RANKS[2] : home = MASK_RANKS[7]
    white ? lx_clear = CLEAR_FILE_A : lx_clear = CLEAR_FILE_H
    white ? rx_clear = CLEAR_FILE_H : rx_clear = CLEAR_FILE_A

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
        push!(pawn_moves, square=>targets)
        push!(pawn_attacks, square=>attacks)
    end

    return pawn_moves, pawn_attacks
end
const PAWN_WHITE, PAWN_X_WHITE = pawnMovesGen(true)
const PAWN_BLACK, PAWN_X_BLACK = pawnMovesGen(false)

