function checkCheck(board::Bitboard, color::String="white")
    if color == "white"
        king = board.K
        attacked = board.black_attacks
    elseif color == "black"
        king = board.k
        attacked = board.white_attacks
    end

    return any(king .& attacked)
end


function checkMate(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        king = board.K
    elseif color == "black"
        king = board.k
    end

    if sum(Int.(getKingValid(board, lu_tabs, color))) != 0
        return false
    else
        moves = getAllMoves(board, lu_tabs, color)
        if length(moves) == 0
            return true
        else
            return false
        end
    end
end


function willBeInCheck(board::Bitboard, lu_tabs::LookUpTables,
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
        return true
    end

    return false
end