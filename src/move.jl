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

# ---------------------------------------------------------------------------
# Pin detection and check mask computation
# ---------------------------------------------------------------------------

# Returns (pinned::UInt64, check_mask::UInt64, n_checkers::Int).
# Writes per-square pin-ray masks into the pre-allocated pin_ray vector (indexed 1..64).
# A piece on square sq is pinned iff (pinned & sq) != EMPTY; it may only move to squares
# in pin_ray[sq2idx(sq)].  check_mask is ~EMPTY when not in check; in single check it is
# the set of squares (between king and checker, inclusive) a non-king piece must target.
function computePinData!(pin_ray::Vector{UInt64}, b::Board, white::Bool)
    if white
        king = b.white.K; own = b.white; opp = b.black
    else
        king = b.black.K; own = b.black; opp = b.white
    end

    fill!(pin_ray, EMPTY)
    pinned = EMPTY

    # --- diagonal pins (enemy bishop or queen on an empty-board diagonal) ---
    diag_pinners = getMagicAttack(king, EMPTY, false) & (opp.B | opp.Q)
    bb = diag_pinners
    while bb != EMPTY
        pinner = lsb(bb); bb = popbit(bb)
        between = getMagicAttack(king, pinner, false) & getMagicAttack(pinner, king, false)
        blocking = between & b.taken
        if count_ones(blocking) == 1 && (blocking & own.friends) != EMPTY
            pinned |= blocking
            @inbounds pin_ray[sq2idx(blocking)] = between | pinner
        end
    end

    # --- orthogonal pins (enemy rook or queen) ---
    ortho_pinners = getMagicAttack(king, EMPTY, true) & (opp.R | opp.Q)
    bb = ortho_pinners
    while bb != EMPTY
        pinner = lsb(bb); bb = popbit(bb)
        between = getMagicAttack(king, pinner, true) & getMagicAttack(pinner, king, true)
        blocking = between & b.taken
        if count_ones(blocking) == 1 && (blocking & own.friends) != EMPTY
            pinned |= blocking
            @inbounds pin_ray[sq2idx(blocking)] = between | pinner
        end
    end

    # --- checkers ---
    kidx     = sq2idx(king)
    checkers = EMPTY
    checkers |= KNIGHT[kidx] & opp.N
    checkers |= (white ? PAWN_X_WHITE[kidx] : PAWN_X_BLACK[kidx]) & opp.P
    checkers |= getMagicAttack(king, b.taken, true)  & (opp.R | opp.Q)
    checkers |= getMagicAttack(king, b.taken, false) & (opp.B | opp.Q)

    n_checkers = count_ones(checkers)

    check_mask = ~EMPTY
    if n_checkers == 1
        checker = lsb(checkers)
        if (checker & (opp.N | opp.P)) != EMPTY
            # Knight or pawn: can only capture, no blocking square
            check_mask = checker
        elseif getMagicAttack(king, b.taken, true) & checker != EMPTY
            # Orthogonal slider (rook or queen on rank/file)
            between   = getMagicAttack(king, checker, true) & getMagicAttack(checker, king, true)
            check_mask = between | checker
        else
            # Diagonal slider (bishop or queen on diagonal)
            between   = getMagicAttack(king, checker, false) & getMagicAttack(checker, king, false)
            check_mask = between | checker
        end
    end

    return pinned, check_mask, n_checkers
end

# ---------------------------------------------------------------------------
# Zero-allocation variants for the perft hot loop
# ---------------------------------------------------------------------------

function filterMoves!(filtered::Moves, raw::Moves,
                      board_stack::Vector{Board}, depth::Int, active::Bool)
    empty!(filtered)
    b = board_stack[depth]
    for m in raw.moves
        if m.type == PIECE_NONE || m.take.type == PIECE_KING; continue end
        board_stack[depth + 1] = makeMove(b, m)
        if !inCheck(board_stack[depth + 1], active)
            push!(filtered, m)
        end
    end
end

function getMoves!(raw::Moves, filtered::Moves,
                   board_stack::Vector{Board}, depth::Int, white::Bool)
    b = board_stack[depth]
    white ? (friends = b.white.friends; enemy = b.black; cs = b.white) :
            (friends = b.black.friends; enemy = b.white; cs = b.black)
    empty!(raw)
    king_in_check = inCheck(b, ~b.active)
    for (bitboard, s) in ((cs.P, PIECE_PAWN),   (cs.N, PIECE_KNIGHT),
                           (cs.B, PIECE_BISHOP), (cs.R, PIECE_ROOK),
                           (cs.Q, PIECE_QUEEN),  (cs.K, PIECE_KING))
        getPieceMoves!(raw, bitboard, s, friends, enemy, white, b, king_in_check)
    end
    filterMoves!(filtered, raw, board_stack, depth, b.active)
end

function moveFromTo(bitboard, move)
    return bitboard ⊻= move.from | move.to
end

@inline function updateSet(cs::ChessSet, move::Move)
    ft   = move.from | move.to
    newf = (cs.friends ⊻ move.from) | move.to   # incremental: remove from, add to
    if move.type == PIECE_PAWN
        if move.promotion != PIECE_NONE
            promo = move.promotion
            newf  = cs.friends ⊻ move.from | move.to
            return ChessSet(cs.P ⊻ move.from,
                promo == PIECE_KNIGHT ? cs.N | move.to : cs.N,
                promo == PIECE_BISHOP ? cs.B | move.to : cs.B,
                promo == PIECE_ROOK   ? cs.R | move.to : cs.R,
                promo == PIECE_QUEEN  ? cs.Q | move.to : cs.Q,
                cs.K, newf)
        else
            return ChessSet(cs.P ⊻ ft, cs.N, cs.B, cs.R, cs.Q, cs.K, newf)
        end
    elseif move.type == PIECE_KNIGHT
        return ChessSet(cs.P, cs.N ⊻ ft, cs.B, cs.R, cs.Q, cs.K, newf)
    elseif move.type == PIECE_BISHOP
        return ChessSet(cs.P, cs.N, cs.B ⊻ ft, cs.R, cs.Q, cs.K, newf)
    elseif move.type == PIECE_ROOK
        return ChessSet(cs.P, cs.N, cs.B, cs.R ⊻ ft, cs.Q, cs.K, newf)
    elseif move.type == PIECE_QUEEN
        return ChessSet(cs.P, cs.N, cs.B, cs.R, cs.Q ⊻ ft, cs.K, newf)
    else # PIECE_KING
        return ChessSet(cs.P, cs.N, cs.B, cs.R, cs.Q, cs.K ⊻ ft, newf)
    end
end

@inline function removeFrom(bitboard::UInt64, square::UInt64)
    return bitboard ⊻ square
end

@inline function updateSet(cs::ChessSet, piece::Piece)
    sq   = piece.square
    newf = cs.friends ⊻ sq
    if piece.type == PIECE_PAWN
        return ChessSet(cs.P ⊻ sq, cs.N, cs.B, cs.R, cs.Q, cs.K, newf)
    elseif piece.type == PIECE_KNIGHT
        return ChessSet(cs.P, cs.N ⊻ sq, cs.B, cs.R, cs.Q, cs.K, newf)
    elseif piece.type == PIECE_BISHOP
        return ChessSet(cs.P, cs.N, cs.B ⊻ sq, cs.R, cs.Q, cs.K, newf)
    elseif piece.type == PIECE_ROOK
        return ChessSet(cs.P, cs.N, cs.B, cs.R ⊻ sq, cs.Q, cs.K, newf)
    elseif piece.type == PIECE_QUEEN
        return ChessSet(cs.P, cs.N, cs.B, cs.R, cs.Q ⊻ sq, cs.K, newf)
    else # PIECE_KING — shouldn't happen, but safe
        return ChessSet(cs.P, cs.N, cs.B, cs.R, cs.Q, cs.K ⊻ sq, newf)
    end
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

