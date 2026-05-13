# Castling-rights delta: for each square, the mask of castling rights to clear
# if a piece moves from or to that square. Corner rook squares clear their own
# castling right; king starting squares clear both rights for that side.
# Indexed 1..64 by sq2idx.
const CASTLING_DELTA = let arr = zeros(UInt8, 64)
    arr[sq2idx(A1)] = CQ
    arr[sq2idx(H1)] = CK
    arr[sq2idx(E1)] = CK | CQ
    arr[sq2idx(A8)] = Cq
    arr[sq2idx(H8)] = Ck
    arr[sq2idx(E8)] = Ck | Cq
    Tuple(arr)
end

# Squares strictly between two collinear squares (same rank/file/diagonal).
# EMPTY for non-collinear pairs and when a == b. 64×64 UInt64 = 32 KiB (fits in L1d).
# Indexed BETWEEN[a_idx, b_idx]; symmetric.
const BETWEEN = let arr = zeros(UInt64, 64, 64)
    for a_sq in values(PGN2UINT), b_sq in values(PGN2UINT)
        a_sq == b_sq && continue
        a_idx = sq2idx(a_sq); b_idx = sq2idx(b_sq)
        ro = orthoAttack(a_sq, b_sq)
        if (ro & b_sq) != EMPTY
            arr[a_idx, b_idx] = ro & orthoAttack(b_sq, a_sq)
        else
            di = diagoAttack(a_sq, b_sq)
            if (di & b_sq) != EMPTY
                arr[a_idx, b_idx] = di & diagoAttack(b_sq, a_sq)
            end
        end
    end
    arr
end

function getPieceMoves!(moves::Moves, bitboard::UInt64, type::UInt8,
    friends::UInt64, enemy::ChessSet, white::Bool, b::Board,
    k_in_check::Bool=false)
    # Backward-compatible (pseudo-legal) entry point — used by the public getMoves API.
    # Perft's hot path uses getLegalPieceMoves! below which inlines pin/check filtering.
    if bitboard == EMPTY
        return
    end
    if type == PIECE_PAWN
        getPawnMoves!(moves, bitboard, b.taken, friends, enemy, white, b.enpassant)
    else
        bb = bitboard
        while bb != EMPTY
            src = lsb(bb)
            bb = popbit(bb)
            piece_moves = EMPTY

            if type == PIECE_KNIGHT
                piece_moves = KNIGHT[sq2idx(src)]
            elseif type == PIECE_KING
                piece_moves = KING[sq2idx(src)]
                if !k_in_check
                    getCastlingMoves!(moves, src, b, white)
                end
            elseif type == PIECE_ROOK
                piece_moves = getSliderAttack(src, b.taken, true)
            elseif type == PIECE_BISHOP
                piece_moves = getSliderAttack(src, b.taken, false)
            elseif type == PIECE_QUEEN
                piece_moves = getSliderAttack(src, b.taken, true)
                piece_moves |= getSliderAttack(src, b.taken, false)
            end
            piece_moves &= ~friends

            if piece_moves == EMPTY
                continue
            end

            pm = piece_moves
            while pm != EMPTY
                target = lsb(pm)
                pm = popbit(pm)
                enemy_type = getTypeAt(enemy, target)
                if enemy_type == PIECE_KING
                    continue
                end
                target & enemy.friends != EMPTY ? take = Piece(enemy_type, target) : take = NONE
                push!(moves, Move(type, src, target, take, EMPTY, PIECE_NONE, NOCASTLING))
            end
        end
    end
end

# Legal-move generation for non-king, non-pawn pieces (KNBRQ).
# Emits ONLY moves that survive pin and check_mask filtering, directly into `moves`.
# Caller must skip this entirely when n_checkers >= 2 (only king moves are legal).
#
# This is the perft hot-path move generator — avoids the second-pass filter loop
# that pushes each legal KNBRQ move twice (raw → filtered).
@inline function getLegalPieceMoves!(moves::Moves, bitboard::UInt64, type::UInt8,
    friends::UInt64, enemy::ChessSet, taken::UInt64,
    pinned::UInt64, pin_ray::Vector{UInt64}, check_mask::UInt64)
    bb = bitboard
    while bb != EMPTY
        src = lsb(bb)
        bb = popbit(bb)

        if type == PIECE_KNIGHT
            @inbounds piece_moves = KNIGHT[sq2idx(src)]
        elseif type == PIECE_ROOK
            piece_moves = getSliderAttack(src, taken, true)
        elseif type == PIECE_BISHOP
            piece_moves = getSliderAttack(src, taken, false)
        else # PIECE_QUEEN
            piece_moves = getSliderAttack(src, taken, true) | getSliderAttack(src, taken, false)
        end
        piece_moves &= ~friends & check_mask
        if (src & pinned) != EMPTY
            @inbounds piece_moves &= pin_ray[sq2idx(src)]
        end
        # A knight on a pin ray can never move; the AND zeroes it out — no special case needed.
        piece_moves == EMPTY && continue

        pm = piece_moves
        while pm != EMPTY
            target = lsb(pm)
            pm = popbit(pm)
            if (target & enemy.friends) != EMPTY
                enemy_type = getTypeAt(enemy, target)
                # King captures are impossible in legal positions; guard kept for safety.
                enemy_type == PIECE_KING && continue
                take = Piece(enemy_type, target)
            else
                take = NONE
            end
            push!(moves, Move(type, src, target, take, EMPTY, PIECE_NONE, NOCASTLING))
        end
    end
end

function getAttack(attack::UInt64, b::UInt64, type::UInt8, taken::UInt64)
    bb = b
    while bb != EMPTY
        src = lsb(bb)
        bb = popbit(bb)
        if type == PIECE_KNIGHT
            attack |= KNIGHT[sq2idx(src)]
        elseif type == PIECE_ROOK
            attack |= getSliderAttack(src, taken, true)
        elseif type == PIECE_BISHOP
            attack |= getSliderAttack(src, taken, false)
        elseif type == PIECE_QUEEN
            attack |= getSliderAttack(src, taken, false)
            attack |= getSliderAttack(src, taken, true)
        end
    end
    return attack
end

function getAttack(b::Board, white::Bool)
    cs = white ? b.white : b.black
    attack = KING[sq2idx(cs.K)]
    attack = getAttack(attack, cs.R, PIECE_ROOK, b.taken)
    attack = getAttack(attack, cs.B, PIECE_BISHOP, b.taken)
    attack = getAttack(attack, cs.Q, PIECE_QUEEN, b.taken)
    return getPawnAttack(attack, cs.P, white)
end

function getMoves(b::Board, white::Bool)
    if white
        friends, enemy, cs = b.white.friends, b.black, b.white
    else
        friends, enemy, cs = b.black.friends, b.white, b.black
    end

    moves = Moves()
    king_in_check = inCheck(b, b.active)
    for (bitboard, s) in zip([cs.P, cs.N, cs.B, cs.R, cs.Q, cs.K],
        [PIECE_PAWN, PIECE_KNIGHT, PIECE_BISHOP, PIECE_ROOK, PIECE_QUEEN, PIECE_KING])
        getPieceMoves!(moves, bitboard, s, friends, enemy, white, b, king_in_check)
    end
    return filterMoves(b, moves)
end

function filterMoves(b::Board, moves::Moves)
    filtered = Moves()
    for m in moves.moves
        if m.type == PIECE_NONE || m.take.type == PIECE_KING
            continue
        end
        b1 = makeMove(b, m)
        king_in_check = inCheck(b1, b.active)
        if !king_in_check
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
        king = b.white.K
        own = b.white
        opp = b.black
    else
        king = b.black.K
        own = b.black
        opp = b.white
    end

    fill!(pin_ray, EMPTY)
    pinned = EMPTY

    king_idx = sq2idx(king)

    # --- diagonal pins (enemy bishop or queen on an empty-board diagonal) ---
    diag_pinners = getSliderAttack(king, EMPTY, false) & (opp.B | opp.Q)
    bb = diag_pinners
    while bb != EMPTY
        pinner = lsb(bb)
        bb = popbit(bb)
        @inbounds between = BETWEEN[king_idx, sq2idx(pinner)]
        blocking = between & b.taken
        if count_ones(blocking) == 1 && (blocking & own.friends) != EMPTY
            pinned |= blocking
            @inbounds pin_ray[sq2idx(blocking)] = between | pinner
        end
    end

    # --- orthogonal pins (enemy rook or queen) ---
    ortho_pinners = getSliderAttack(king, EMPTY, true) & (opp.R | opp.Q)
    bb = ortho_pinners
    while bb != EMPTY
        pinner = lsb(bb)
        bb = popbit(bb)
        @inbounds between = BETWEEN[king_idx, sq2idx(pinner)]
        blocking = between & b.taken
        if count_ones(blocking) == 1 && (blocking & own.friends) != EMPTY
            pinned |= blocking
            @inbounds pin_ray[sq2idx(blocking)] = between | pinner
        end
    end

    # --- checkers ---
    checkers = EMPTY
    @inbounds checkers |= KNIGHT[king_idx] & opp.N
    @inbounds checkers |= (white ? PAWN_X_WHITE[king_idx] : PAWN_X_BLACK[king_idx]) & opp.P
    checkers |= getSliderAttack(king, b.taken, true)  & (opp.R | opp.Q)
    checkers |= getSliderAttack(king, b.taken, false) & (opp.B | opp.Q)

    n_checkers = count_ones(checkers)

    check_mask = ~EMPTY
    if n_checkers == 1
        checker = lsb(checkers)
        if (checker & (opp.N | opp.P)) != EMPTY
            # Knight or pawn: can only capture, no blocking square
            check_mask = checker
        else
            # Slider (rook/bishop/queen): blocking or capture squares
            @inbounds check_mask = BETWEEN[king_idx, sq2idx(checker)] | checker
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
        if m.type == PIECE_NONE || m.take.type == PIECE_KING
            continue
        end
        board_stack[depth+1] = makeMove(b, m)
        if !inCheck(board_stack[depth+1], active)
            push!(filtered, m)
        end
    end
end

function getMoves!(raw::Moves, filtered::Moves,
    board_stack::Vector{Board}, depth::Int, white::Bool)
    b = board_stack[depth]
    if white
        friends, enemy, cs = b.white.friends, b.black, b.white
    else
        friends, enemy, cs = b.black.friends, b.white, b.black
    end
    empty!(raw)
    king_in_check = inCheck(b, b.active)
    for (bitboard, s) in ((cs.P, PIECE_PAWN), (cs.N, PIECE_KNIGHT),
        (cs.B, PIECE_BISHOP), (cs.R, PIECE_ROOK),
        (cs.Q, PIECE_QUEEN), (cs.K, PIECE_KING))
        getPieceMoves!(raw, bitboard, s, friends, enemy, white, b, king_in_check)
    end
    filterMoves!(filtered, raw, board_stack, depth, b.active)
end


@inline function updateSet(cs::ChessSet, move::Move)
    ft = move.from | move.to
    newf = (cs.friends ⊻ move.from) | move.to   # incremental: remove from, add to
    if move.type == PIECE_PAWN
        if move.promotion != PIECE_NONE
            promo = move.promotion
            newf = cs.friends ⊻ move.from | move.to
            return ChessSet(cs.P ⊻ move.from,
                promo == PIECE_KNIGHT ? cs.N | move.to : cs.N,
                promo == PIECE_BISHOP ? cs.B | move.to : cs.B,
                promo == PIECE_ROOK ? cs.R | move.to : cs.R,
                promo == PIECE_QUEEN ? cs.Q | move.to : cs.Q,
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
    sq = piece.square
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
    h = board.hash
    from_idx = sq2idx(move.from)
    to_idx   = sq2idx(move.to)

    # --- board update ---
    if board.active #true is white, false is black
        new_white = updateSet(board.white, move)
        new_black = move.take != NONE ? updateSet(board.black, move.take) : board.black

        if move.castling == CQ
            new_white = updateSet(new_white, Move(PIECE_ROOK, A1, D1, NONE, EMPTY, PIECE_NONE, NOCASTLING))
        elseif move.castling == CK
            new_white = updateSet(new_white, Move(PIECE_ROOK, H1, F1, NONE, EMPTY, PIECE_NONE, NOCASTLING))
        end
    else
        new_black = updateSet(board.black, move)
        new_white = move.take != NONE ? updateSet(board.white, move.take) : board.white

        if move.castling == Cq
            new_black = updateSet(new_black, Move(PIECE_ROOK, A8, D8, NONE, EMPTY, PIECE_NONE, NOCASTLING))
        elseif move.castling == Ck
            new_black = updateSet(new_black, Move(PIECE_ROOK, H8, F8, NONE, EMPTY, PIECE_NONE, NOCASTLING))
        end
    end

    # Castling rights: a single mask handles king-moves, rook-moves-from-corner,
    # and rook-captured-on-corner — all 4 prior branches collapse into one AND-NOT.
    @inbounds castling = board.castling & ~(CASTLING_DELTA[from_idx] | CASTLING_DELTA[to_idx])

    # --- incremental Zobrist hash ---
    color = board.active ? 1 : 2

    # castling rights delta
    h ⊻= ZOBRIST_CASTLING[board.castling+1]
    h ⊻= ZOBRIST_CASTLING[castling+1]

    # en passant delta
    if board.enpassant != EMPTY
        h ⊻= ZOBRIST_EP[(trailing_zeros(board.enpassant)%8)+1]
    else
        h ⊻= ZOBRIST_EP[9]
    end
    if move.enpassant != EMPTY
        h ⊻= ZOBRIST_EP[(trailing_zeros(move.enpassant)%8)+1]
    else
        h ⊻= ZOBRIST_EP[9]
    end

    # moved piece: XOR out from source, XOR in at target
    moved_type = move.type
    h ⊻= zobristPiece(moved_type, color, from_idx)
    promo = move.promotion
    placed_type = promo != PIECE_NONE ? promo : moved_type
    h ⊻= zobristPiece(placed_type, color, to_idx)

    # captured piece
    if move.take != NONE
        opp = board.active ? 2 : 1
        h ⊻= zobristPiece(move.take.type, opp, sq2idx(move.take.square))
    end

    # castling rook movement
    if move.castling != NOCASTLING
        if move.castling == CQ
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(A1))
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(D1))
        elseif move.castling == CK
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(H1))
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(F1))
        elseif move.castling == Cq
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(A8))
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(D8))
        elseif move.castling == Ck
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(H8))
            h ⊻= zobristPiece(PIECE_ROOK, color, sq2idx(F8))
        end
    end

    # flip side
    h ⊻= ZOBRIST_SIDE

    taken = new_white.friends | new_black.friends
    return Board(new_white, new_black, taken, !board.active, castling,
        move.enpassant, board.halfmove, board.fullmove, h)
end

# ---------------------------------------------------------------------------
# UCI string conversion utilities
# ---------------------------------------------------------------------------

function moveToUCI(m::Move)::String
    from_str = UINT2PGN[m.from]
    to_str = UINT2PGN[m.to]
    if m.promotion != PIECE_NONE
        promo_char = m.promotion == PIECE_QUEEN ? 'q' :
                     m.promotion == PIECE_ROOK ? 'r' :
                     m.promotion == PIECE_BISHOP ? 'b' : 'n'
        return from_str * to_str * promo_char
    end
    return from_str * to_str
end

function uciMoveToMove(b::Board, uci::String)::Move
    from_sq = PGN2UINT[uci[1:2]]
    to_sq = PGN2UINT[uci[3:4]]
    promo = PIECE_NONE
    if length(uci) == 5
        promo = uci[5] == 'q' ? PIECE_QUEEN :
                uci[5] == 'r' ? PIECE_ROOK :
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
