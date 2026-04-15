function getPieceMoves!(moves::Moves, bitboard::UInt64, type::UInt8,
                        friends::UInt64, enemy::ChessSet, white::Bool, b::Board,
                        k_in_check::Bool=false)
    if bitboard == EMPTY; return end
    if type == PIECE_PAWN
        getPawnMoves!(moves, bitboard, b.taken, friends, enemy, white, b.enpassant)
    else
        bb = bitboard
        while bb != EMPTY
            src = lsb(bb)
            bb  = popbit(bb)
            piece_moves = EMPTY

            if type == PIECE_KNIGHT
                piece_moves = KNIGHT[sq2idx(src)]
            elseif type == PIECE_KING
                piece_moves = KING[sq2idx(src)]
                if ~k_in_check; getCastlingMoves!(moves, src, b, white) end
            elseif type == PIECE_ROOK
                piece_moves = getMagicAttack(src, b.taken, true)
            elseif type == PIECE_BISHOP
                piece_moves = getMagicAttack(src, b.taken, false)
            elseif type == PIECE_QUEEN
                piece_moves = getMagicAttack(src, b.taken, true)
                piece_moves |= getMagicAttack(src, b.taken, false)
            end
            piece_moves &= ~friends

            if piece_moves == EMPTY; continue end

            pm = piece_moves
            while pm != EMPTY
                target = lsb(pm)
                pm = popbit(pm)
                enemy_type = getTypeAt(enemy, target)
                if enemy_type == PIECE_KING; continue end
                target & enemy.friends != EMPTY ? take = Piece(enemy_type, target) : take = NONE
                push!(moves, Move(type, src, target, take, EMPTY, PIECE_NONE, NOCASTLING))
            end
        end
    end
end

function getAttack(attack::UInt64, b::UInt64, type::UInt8, taken::UInt64)
    bb = b
    while bb != EMPTY
        src = lsb(bb)
        bb  = popbit(bb)
        if type == PIECE_KNIGHT
            attack |= KNIGHT[sq2idx(src)]
        elseif type == PIECE_ROOK
            attack |= getMagicAttack(src, taken, true)
        elseif type == PIECE_BISHOP
            attack |= getMagicAttack(src, taken, false)
        elseif type == PIECE_QUEEN
            attack |= getMagicAttack(src, taken, false)
            attack |= getMagicAttack(src, taken, true)
        end
    end
    return attack
end

function getAttack(b::Board, white::Bool)
    white ? cs = b.white : cs = b.black
    attack = KING[sq2idx(cs.K)]
    attack = getAttack(attack, cs.R, PIECE_ROOK, b.taken)
    attack = getAttack(attack, cs.B, PIECE_BISHOP, b.taken)
    attack = getAttack(attack, cs.Q, PIECE_QUEEN, b.taken)
    return getPawnAttack(attack, cs.P, white)
end

function getMoves(b::Board, white::Bool)
    white ? friends = b.white.friends : friends = b.black.friends
    white ? enemy = b.black : enemy = b.white
    white ? cs = b.white : cs = b.black

    moves = Moves()
    king_in_check = inCheck(b, ~b.active)
    for (bitboard, s) in zip([cs.P, cs.N, cs.B, cs.R, cs.Q, cs.K],
                             [PIECE_PAWN, PIECE_KNIGHT, PIECE_BISHOP, PIECE_ROOK, PIECE_QUEEN, PIECE_KING])
        getPieceMoves!(moves, bitboard, s, friends, enemy, white, b, king_in_check)
    end
    return filterMoves(b, moves)
end

function filterMoves(b::Board, moves::Moves)
    filtered = Moves()
    for m in moves.moves
        if m.type == PIECE_NONE || m.take.type == PIECE_KING; continue end
        b1 = makeMove(b, m)
        king_in_check = inCheck(b1, b.active)
        if ~king_in_check
            push!(filtered, m)
        end
    end
    return filtered
end

function moveFromTo(bitboard, move)
    return bitboard ⊻= move.from | move.to
end

function updateSet(cs::ChessSet, move::Move)
    newp = cs.P
    newn = cs.N
    newb = cs.B
    newr = cs.R
    newq = cs.Q
    newk = cs.K
    if move.type == PIECE_PAWN
        if move.promotion != PIECE_NONE
            newp = removeFrom(newp, move.from)
            if move.promotion == PIECE_QUEEN
                newq |= move.to
            elseif move.promotion == PIECE_ROOK
                newr |= move.to
            elseif move.promotion == PIECE_KNIGHT
                newn |= move.to
            elseif move.promotion == PIECE_BISHOP
                newb |= move.to
            end
        else
            newp = moveFromTo(newp, move)
        end
    elseif move.type == PIECE_KNIGHT
        newn = moveFromTo(newn, move)
    elseif move.type == PIECE_BISHOP
        newb = moveFromTo(newb, move)
    elseif move.type == PIECE_ROOK
        newr = moveFromTo(newr, move)
    elseif move.type == PIECE_QUEEN
        newq = moveFromTo(newq, move)
    elseif move.type == PIECE_KING
        newk = moveFromTo(newk, move)
    end
    newf = newp|newn|newb|newr|newq|newk
    return ChessSet(newp, newn, newb, newr, newq, newk, newf)
end

function removeFrom(bitboard::UInt64, square::UInt64)
    return bitboard ⊻= square
end

function updateSet(cs::ChessSet, piece::Piece)
    newp = cs.P
    newn = cs.N
    newb = cs.B
    newr = cs.R
    newq = cs.Q
    newk = cs.K
    if piece.type == PIECE_PAWN
        newp = removeFrom(newp, piece.square)
    elseif piece.type == PIECE_KNIGHT
        newn = removeFrom(newn, piece.square)
    elseif piece.type == PIECE_BISHOP
        newb = removeFrom(newb, piece.square)
    elseif piece.type == PIECE_ROOK
        newr = removeFrom(newr, piece.square)
    elseif piece.type == PIECE_QUEEN
        newq = removeFrom(newq, piece.square)
    elseif piece.type == PIECE_KING
        newk = removeFrom(newk, piece.square)
    end
    newf = newp|newn|newb|newr|newq|newk
    return ChessSet(newp, newn, newb, newr, newq, newk, newf)
end

function makeMove(board::Board, move::Move)
    castling = board.castling
    h = board.hash

    # --- board update ---
    if board.active #true is white, false is black
        new_white = updateSet(board.white, move)

        if move.take != NONE
            new_black = updateSet(board.black, move.take)
            if move.take.type == PIECE_ROOK
                if move.take.square == A8
                    castling ⊻= Cq
                elseif move.take.square == H8
                    castling ⊻= Ck
                end
            end
        else
            new_black = board.black
        end

        if move.castling != NOCASTLING
            if move.castling == CQ
                new_white = updateSet(new_white, Move(PIECE_ROOK, A1, D1, NONE, EMPTY, PIECE_NONE, NOCASTLING))
                castling ⊻= CQ
            elseif move.castling == CK
                new_white = updateSet(new_white, Move(PIECE_ROOK, H1, F1, NONE, EMPTY, PIECE_NONE, NOCASTLING))
                castling ⊻= CK
            end
        end
        if castling&CK != NOCASTLING && (move.type == PIECE_KING || (move.type == PIECE_ROOK && move.from == H1))
            castling ⊻= CK
        end
        if castling&CQ != NOCASTLING && (move.type == PIECE_KING || (move.type == PIECE_ROOK && move.from == A1))
            castling ⊻= CQ
        end
    else
        new_black = updateSet(board.black, move)

        if move.take != NONE
            new_white = updateSet(board.white, move.take)
            if move.take.type == PIECE_ROOK
                if move.take.square == A1
                    castling ⊻= CQ
                elseif move.take.square == H1
                    castling ⊻= CK
                end
            end
        else
            new_white = board.white
        end

        if move.castling != NOCASTLING
            if move.castling == Cq
                new_black = updateSet(new_black, Move(PIECE_ROOK, A8, D8, NONE, EMPTY, PIECE_NONE, NOCASTLING))
                castling ⊻= Cq
            elseif move.castling == Ck
                new_black = updateSet(new_black, Move(PIECE_ROOK, H8, F8, NONE, EMPTY, PIECE_NONE, NOCASTLING))
                castling ⊻= Ck
            end
        end
        if castling&Ck != NOCASTLING && (move.type == PIECE_KING || (move.type == PIECE_ROOK && move.from == H8))
            castling ⊻= Ck
        end
        if castling&Cq != NOCASTLING && (move.type == PIECE_KING || (move.type == PIECE_ROOK && move.from == A8))
            castling ⊻= Cq
        end
    end

    # --- incremental Zobrist hash ---
    color = board.active ? 1 : 2

    # castling rights delta
    h ⊻= ZOBRIST_CASTLING[board.castling + 1]
    h ⊻= ZOBRIST_CASTLING[castling + 1]

    # en passant delta
    if board.enpassant != EMPTY
        h ⊻= ZOBRIST_EP[(trailing_zeros(board.enpassant) % 8) + 1]
    else
        h ⊻= ZOBRIST_EP[9]
    end
    if move.enpassant != EMPTY
        h ⊻= ZOBRIST_EP[(trailing_zeros(move.enpassant) % 8) + 1]
    else
        h ⊻= ZOBRIST_EP[9]
    end

    # moved piece: XOR out from source, XOR in at target
    moved_type = move.type
    h ⊻= ZOBRIST_PIECES[moved_type, color, sq2idx(move.from)]
    promo = move.promotion
    placed_type = promo != PIECE_NONE ? promo : moved_type
    h ⊻= ZOBRIST_PIECES[placed_type, color, sq2idx(move.to)]

    # captured piece
    if move.take != NONE
        opp = board.active ? 2 : 1
        h ⊻= ZOBRIST_PIECES[move.take.type, opp, sq2idx(move.take.square)]
    end

    # castling rook movement
    if move.castling != NOCASTLING
        if move.castling == CQ
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(A1)]
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(D1)]
        elseif move.castling == CK
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(H1)]
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(F1)]
        elseif move.castling == Cq
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(A8)]
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(D8)]
        elseif move.castling == Ck
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(H8)]
            h ⊻= ZOBRIST_PIECES[PIECE_ROOK, color, sq2idx(F8)]
        end
    end

    # flip side
    h ⊻= ZOBRIST_SIDE

    taken = new_white.friends | new_black.friends
    return Board(new_white, new_black, taken, ~board.active, castling,
                 move.enpassant, board.halfmove, board.fullmove, h)
end

# ---------------------------------------------------------------------------
# UCI string conversion utilities
# ---------------------------------------------------------------------------

function moveToUCI(m::Move)::String
    from_str = UINT2PGN[m.from]
    to_str   = UINT2PGN[m.to]
    if m.promotion != PIECE_NONE
        promo_char = m.promotion == PIECE_QUEEN  ? 'q' :
                     m.promotion == PIECE_ROOK   ? 'r' :
                     m.promotion == PIECE_BISHOP ? 'b' : 'n'
        return from_str * to_str * promo_char
    end
    return from_str * to_str
end

function uciMoveToMove(b::Board, uci::String)::Move
    from_sq = PGN2UINT[uci[1:2]]
    to_sq   = PGN2UINT[uci[3:4]]
    promo   = PIECE_NONE
    if length(uci) == 5
        promo = uci[5] == 'q' ? PIECE_QUEEN  :
                uci[5] == 'r' ? PIECE_ROOK   :
                uci[5] == 'b' ? PIECE_BISHOP : PIECE_KNIGHT
    end
    moves = getMoves(b, b.active)
    for m in moves.moves
        if m.from == from_sq && m.to == to_sq && m.promotion == promo
            return m
        end
    end
    error("Illegal UCI move: $uci")
end

