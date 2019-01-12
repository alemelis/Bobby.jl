function moveSourceTargetWhite(board::Bitboard, source::Int64, target::Int64)
    board.free[source] = true
    board.free[target] = false
    board.taken[source] = false
    board.taken[target] = true
    board.white[source] = false
    board.white[target] = true

    if board.black[target]
        board.black[target] = false
        if board.p[target]
            board.p[target] = false
        elseif board.r[target]
            board.r[target] = false
        elseif board.n[target]
            board.n[target] = false
        elseif board.b[target]
            board.b[target] = false
        elseif board.q[target]
            board.q[target] = false
        elseif board.k[target]
            throw(DomainError("black king in target square"))
        end
    end
    return board
end


function moveSourceTargetBlack(board::Bitboard, source::Int64, target::Int64)
    board.free[source] = true
    board.free[target] = false
    board.taken[source] = false
    board.taken[target] = true
    board.black[source] = false
    board.black[target] = true

    if board.white[target]
        board.white[target] = false
        if board.P[target]
            board.P[target] = false
        elseif board.R[target]
            board.R[target] = false
        elseif board.N[target]
            board.N[target] = false
        elseif board.B[target]
            board.B[target] = false
        elseif board.Q[target]
            board.Q[target] = false
        elseif board.K[target]
            throw(DomainError("white king in target square"))
        end
    end
    return board
end


function getAttacked(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    attacked = falses(64)
    attacked .|= getPawnsAttackGeneric(board, lu_tabs, color)
    attacked .|= getKingValid(board, lu_tabs, color)
    attacked .|= getNightsValid(board, lu_tabs, color)
    attacked .|= getQueenValid(board, lu_tabs, color)
    attacked .|= getBishopsValid(board, lu_tabs, color)
    attacked .|= getRooksValid(board, lu_tabs, color)

    return attacked
end


function updateAttacked(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        opponent_color = "black"
    else
        opponent_color = "white"
    end

    opponent_attacked = getAttacked(board, lu_tabs, opponent_color)
    if opponent_color == "white"
        board.white_attacks = opponent_attacked
    else
        board.black_attacks = opponent_attacked
    end

    if checkCheck(board, color)
        throw(ErrorException("invalid move! $color would be in check!"))
    end

    attacked = getAttacked(board, lu_tabs, color)
    if color == "white"
        board.white_attacks = attacked
    else
        board.black_attacks = attacked
    end

    return board
end


function countAllValidMoves(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    validators = Dict()
    validators['k'] = getKingValid
    validators['p'] = getPawnsValid
    validators['q'] = getQueenValid
    validators['b'] = getBishopsValid
    validators['r'] = getRooksValid
    validators['n'] = getNightsValid
    valids_count = 0
    for piece in keys(validators)
        valid_moves = validators[piece](board, lu_tabs, color)
        valids_count += sum(Int.(valid_moves))
    end
    return valids_count
end