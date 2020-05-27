function getPieceMoves!(moves::Array{Move,1}, bitboard::UInt64, type::Symbol,
                        friends::UInt64, enemy::ChessSet, white::Bool, b::Board)
    if bitboard == EMPTY; return end
    if type == :pawn
        getPawnMoves!(moves, bitboard, b.taken, friends, enemy, white, b.enpassant)
    else
        b0, d = bitshift(bitboard)
        for i = 0:d
            if b0<<i & bitboard != EMPTY
                src = b0<<i
                piece_moves = EMPTY

                if type == :knight
                    piece_moves = KNIGHT[src]
                elseif type == :king
                    piece_moves = KING[src]
                    getCastlingMoves!(moves, src, b, white)
                elseif type == :rook
                    piece_moves = getMagicAttack(src, b.taken, true)
                elseif type == :bishop
                    piece_moves = getMagicAttack(src, b.taken, false)
                elseif type == :queen
                    piece_moves = getMagicAttack(src, b.taken, true)
                    piece_moves |= getMagicAttack(src, b.taken, false)
                end
                piece_moves &= ~friends

                if piece_moves == EMPTY; continue end
                
                b0_m, d_m = bitshift(piece_moves)
                for j = 0:d_m
                    if b0_m<<j & piece_moves != EMPTY
                        target = b0_m<<j
                        enemy_type = getTypeAt(enemy, target)
                        target & enemy.friends != EMPTY ? take = Piece(enemy_type, target) : take = NONE
                        push!(moves, Move(type, src, target, take, EMPTY, :none, NOCASTLING))
                    end
                end
            end
        end
    end
end

function getMoves(b::Board, white::Bool)
    white ? friends = b.white.friends : friends = b.black.friends
    white ? enemy = b.black : enemy = b.white
    white ? cs = b.white : cs = b.black

    moves = Array{Move,1}()
    for (bitboard, s) in zip([cs.P, cs.N, cs.B, cs.R, cs.Q, cs.K],
                             [:pawn, :knight, :bishop, :rook, :queen, :king])
        getPieceMoves!(moves, bitboard, s, friends, enemy, white, b)
    end
    return filterMoves(b, moves)
end

function filterMoves(b::Board, moves::Array{Move,1})
    filtered = Array{Move,1}()
    for m in moves
        b1 = makeMove(b, m)
        if ~inCheck(b1, b.active); push!(filtered, m) end
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
    if move.type == :pawn
        if move.promotion != :none
            newp = removeFrom(newp, move.from)
            if move.promotion == :queen
                newq |= move.to
            elseif move.promotion == :rook
                newr |= move.to
            elseif move.promotion == :knight
                newn |= move.to
            elseif move.promotion == :bishop
                newb |= move.to
            end
        else
            newp = moveFromTo(newp, move)
        end
    elseif move.type == :knight
        newn = moveFromTo(newn, move)
    elseif move.type == :bishop
        newb = moveFromTo(newb, move)
    elseif move.type == :rook
        newr = moveFromTo(newr, move)
    elseif move.type == :queen
        newq = moveFromTo(newq, move)
    elseif move.type == :king
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
    if piece.type == :pawn
        newp = removeFrom(newp, piece.square)
    elseif piece.type == :knight
        newn = removeFrom(newn, piece.square)
    elseif piece.type == :bishop
        newb = removeFrom(newb, piece.square)
    elseif piece.type == :rook
        newr = removeFrom(newr, piece.square)
    elseif piece.type == :queen
        newq = removeFrom(newq, piece.square)
    elseif piece.type == :king
        newk = removeFrom(newk, piece.square)
    end
    newf = newp|newn|newb|newr|newq|newk
    return ChessSet(newp, newn, newb, newr, newq, newk, newf)
end

function makeMove(board::Board, move::Move)
    castling = board.castling
    if board.active #true is white, false is black
        new_white = updateSet(board.white, move)

        if move.take != NONE
            new_black = updateSet(board.black, move.take)
            if move.take.type == :rook
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
                new_white = updateSet(new_white, Move(:rook, A1, D1, NONE, EMPTY, :none, NOCASTLING))
                castling ⊻= CQ
            elseif move.castling == CK
                new_white = updateSet(new_white, Move(:rook, H1, F1, NONE, EMPTY, :none, NOCASTLING))
                castling ⊻= CK
            end
        end
        if castling&CK != NOCASTLING && (move.type == :king || (move.type == :rook && move.from == H1))
            castling ⊻= CK
        end
        if castling&CQ != NOCASTLING && (move.type == :king || (move.type == :rook && move.from == A1))
            castling ⊻= CQ
        end
    else
        new_black = updateSet(board.black, move)

        if move.take != NONE
            new_white = updateSet(board.white, move.take)
            if move.take.type == :rook
                if  move.take.square == A1
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
                new_black = updateSet(new_black, Move(:rook, A8, D8, NONE, EMPTY, :none, NOCASTLING))
                castling ⊻= Cq
            elseif move.castling == Ck
                new_black = updateSet(new_black, Move(:rook, H8, F8, NONE, EMPTY, :none, NOCASTLING))
                castling ⊻= Ck
            end
        end
        if castling&Ck != NOCASTLING && (move.type == :king || (move.type == :rook && move.from == H8))
            castling ⊻= Ck
        end
        if castling&Cq != NOCASTLING && (move.type == :king || (move.type == :rook && move.from == A8))
            castling ⊻= Cq
        end
    end

    taken = new_white.friends | new_black.friends
    return Board(new_white, new_black, taken, ~board.active, castling,
                 move.enpassant, board.halfmove, board.fullmove)
end

function moveNow(b::Board, m::AbstractString)
    src = m[1:2]
    dst = m[3:4]
    if length(m) == 5
        prm = m[end]
    else
        prm = ""
    end

    avail_moves = Cassandra.getMoves(b, b.active)
    for am in avail_moves
        if Cassandra.UINT2PGN[am.from] == src && Cassandra.UINT2PGN[am.to] == dst
             if (prm == 'q' && am.promotion == :queen) ||
                (prm == 'r' && am.promotion == :rook) ||
                (prm == 'b' && am.promotion == :bishop) ||
                (prm == 'n' && am.promotion == :knight) ||
                (prm == "" && am.promotion == :none)
                b1 = Cassandra.makeMove(b, am)
                return b1
            end
        end
    end
end
