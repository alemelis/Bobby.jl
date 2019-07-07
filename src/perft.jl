mutable struct PerftTree
    nodes :: Array{Int64,1}
    divide :: Dict{String,Int64}
end


function perft(chessboard::Chessboard, depth::Int64, color::String)

    pt = PerftTree(zeros(depth), Dict{String,Int64}())

    return explore(pt, chessboard, depth, 1, color)
end


function print_perftree(pt::PerftTree)
    println("Nodes      ", pt.nodes)
    for x in sort(collect(pt.divide))
        println(x)
    end
end


function sumdivide(pt::PerftTree)
    c = 0
    for k in keys(pt.divide)
        c += pt.divide[k]
    end
    println(c)
end


function explore(pt::PerftTree, chessboard::Chessboard,
    max_depth::Int64, depth::Int64, color::String="white",
    move_name::String="")

    moves = get_all_legal_moves(chessboard, color)

    if length(moves) == 0
        return pt
    end

    if depth == 1
        for m in moves
            push!(pt.divide,
                m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]=>0)
        end
    end

    pt.nodes[depth] += length(moves)
    if depth > 1
        pt.divide[move_name] += length(moves)
    end

    if depth == max_depth
        return pt
    end

    new_color = change_color(color)
    # b = deepcopy(board)
    for m in moves
        # newb = deepcopy(board)
        println(m)

        if color == "white"
            chessboard = move_piece(chessboard, m, color,
                chessboard.white, chessboard.black)
        else
            chessboard = move_piece(chessboard, m, color,
                chessboard.black, chessboard.whit)
        end
        update_both_sides_attacked!(chessboard)
        # board = update_attacked(board)
        chessboard = update_castling_rights(chessboard)

        if depth == 1
            move_name = m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]
        end
        #     pt.divide[move_name] += 1
        # end

        pt = explore(pt, chessboard, max_depth, depth+1, new_color, move_name)
        if color == "white"
            chessboard = unmove_piece(chessboard, m, color,
                chessboard.white, chessboard.black)
        else
            chessboard = unmove_piece(chessboard, m, color,
                chessboard.black, chessboard.whit)
        end
        update_both_sides_attacked!(chessboard)
        chessboard = update_castling_rights(chessboard)
        # test_unmove(b, board)
        # if ~test_unmove(b, board)
        #     println(move_name)
        #     ugly_print(b.white)
        #     ugly_print(board.white)
        # end
        # board = update_castling_rights(board)
    end

    return pt
end
