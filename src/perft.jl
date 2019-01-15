function getAllMoves(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    valid_moves = getKingValidList(board, lu_tabs, color)
    union!(valid_moves, getQueenValidList(board, lu_tabs, color))
    union!(valid_moves, getPawnsValidList(board, lu_tabs, color))
    union!(valid_moves, getBishopsValidList(board, lu_tabs, color))
    union!(valid_moves, getRooksValidList(board, lu_tabs, color))
    union!(valid_moves, getNightsValidList(board, lu_tabs, color))

    return valid_moves
end

mutable struct PerftTree
    nodes :: Array{Int64, 1}
    checks :: Array{Int64, 1}
    mates :: Array{Int64, 1}
end


function perft(board, lu_tabs, depth, color::String="white")
    pt = PerftTree(zeros(depth), zeros(depth), zeros(depth))
    pt = explore(pt, board, lu_tabs, depth, 1, color)
    println(pt)
    println(sum(pt.nodes))
end

function explore(pt::PerftTree, board::Bitboard, lu_tabs::LookUpTables, 
    max_depth::Int64, depth::Int64, color::String="white")

    if depth > max_depth
        return pt
    end
    
    moves = getAllMoves(board, lu_tabs, color)
    if length(moves) == 0
        return pt
    end
    pt.nodes[depth] += length(moves)

    new_color = changeColor(color)
    for m in moves
        tmp_b = deepcopy(board)
        new_board, e = move(tmp_b, lu_tabs, m[1], m[2], color)
        if checkCheck(new_board, new_color)
            pt.checks[depth] += 1
            if checkMate(new_board, lu_tabs, new_color)
                pt.mates[depth] += 1
                continue
            end
        end

        pt = explore(pt, new_board, lu_tabs, max_depth, depth+1, new_color)
    end

    return pt
end