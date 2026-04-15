mutable struct Game
    history::Vector{Board}   # all positions including current
    moves::Vector{Move}      # applied moves (length = length(history) - 1)
    result::UInt8             # 0=ongoing, 1=white wins, 2=black wins, 3=draw
end

function newGame()
    b = setBoard()
    return Game([b], Move[], UInt8(0))
end

function newGame(fen::String)
    b = loadFen(fen)
    return Game([b], Move[], UInt8(0))
end

function currentBoard(g::Game)
    return g.history[end]
end

function applyMove!(g::Game, m::Move)
    b = makeMove(currentBoard(g), m)
    push!(g.history, b)
    push!(g.moves, m)
end

function undoMove!(g::Game)
    if length(g.history) > 1
        pop!(g.history)
        pop!(g.moves)
    end
end

function isThreefoldRepetition(g::Game)
    h = currentBoard(g).hash
    count = 0
    for b in g.history
        if b.hash == h
            count += 1
        end
        count >= 3 && return true
    end
    return false
end

function isFiftyMoveRule(g::Game)
    return currentBoard(g).halfmove >= 100
end

function isInsufficientMaterial(g::Game)
    b = currentBoard(g)
    # King vs King
    if b.white.friends == b.white.K && b.black.friends == b.black.K
        return true
    end
    # King + minor vs King
    white_minor = count_ones(b.white.N | b.white.B)
    black_minor = count_ones(b.black.N | b.black.B)
    white_only_minor = (b.white.friends == b.white.K | (b.white.N | b.white.B)) && count_ones(b.white.N | b.white.B) == 1 && b.white.R == EMPTY && b.white.Q == EMPTY && b.white.P == EMPTY
    black_only_minor = (b.black.friends == b.black.K | (b.black.N | b.black.B)) && count_ones(b.black.N | b.black.B) == 1 && b.black.R == EMPTY && b.black.Q == EMPTY && b.black.P == EMPTY
    white_king_only  = b.white.friends == b.white.K
    black_king_only  = b.black.friends == b.black.K
    if (white_only_minor && black_king_only) || (black_only_minor && white_king_only)
        return true
    end
    return false
end

function isDraw(g::Game)
    return isThreefoldRepetition(g) || isFiftyMoveRule(g) || isInsufficientMaterial(g)
end

function isCheckmate(g::Game)
    b = currentBoard(g)
    moves = getMoves(b, b.active)
    return length(moves.moves) == 0 && inCheck(b, ~b.active)
end

function isStalemate(g::Game)
    b = currentBoard(g)
    moves = getMoves(b, b.active)
    return length(moves.moves) == 0 && !inCheck(b, ~b.active)
end
