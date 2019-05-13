mutable struct PerftTree
    nodes :: Array{Int64,1}
    checks :: Array{Int64,1}
    mates :: Array{Int64,1}
    captures :: Array{Int64,1}
    divide :: Dict{String,Int64}
    promotions :: Array{Int64,1}
    stalemates :: Array{Int64,1}
end


function perft(board, depth, color::String="white")
    pt = PerftTree(zeros(depth), zeros(depth), zeros(depth), zeros(depth),
        Dict{String,Int64}(), zeros(depth), zeros(depth))
    # pt =
    # pt =
    # println(pt)
    # println(sum(pt.nodes))
    # print_perftree(pt)
    return explore(pt, board, depth, 1, color)
end


function print_perftree(pt::PerftTree)
    println("Nodes      ", pt.nodes)
    println("Captures   ", pt.captures)
    println("Promotions ", pt.promotions)
    println("Checks     ", pt.checks)
    println("Mates      ", pt.mates)
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

function count_total_pieces(board::Bitboard)
    total_pieces = 2 # kings
    total_pieces += length(board.p)
    total_pieces += length(board.n)
    total_pieces += length(board.r)
    total_pieces += length(board.q)
    total_pieces += length(board.P)
    total_pieces += length(board.N)
    total_pieces += length(board.R)
    total_pieces += length(board.Q)
    return total_pieces
end


function explore(pt::PerftTree, board::Bitboard,
    max_depth::Int64, depth::Int64, color::String="white",
    move_name::String="")

    # if king_in_check(board, color) && depth > 1
    #     check = true
    #     pt.checks[depth-1] += 1
    # else
    #     check = false
    # end

    # total_pieces = count_total_pieces(board)
    # if move_name == "night-f6d7"
    #     pretty_print(board)
    # end

    moves = get_all_valid_moves(board, color)
    # println(move_name, " ", length(moves))

    if length(moves) == 0
        # if check
        #     pt.mates[depth-1] += 1
        # end
        return pt
    end
    # else: stalemate += 1; return

    if depth == 1
        for m in moves
            push!(pt.divide,
                m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]=>0)
        end
    end

    # if depth > max_depth
    #     return pt
    # end

    pt.nodes[depth] += length(moves)
    # pt[depth] += length(moves)

    if depth == max_depth
        return pt
    end

    new_color = change_color(color)
    # fen = board.fen

    # if move_name == "rook-a8a2"
    #     pretty_print(board)
    #     println(length(moves))
    # end

    c = 1
    for m in moves
        # pt.nodes[depth] += 1
        newb = deepcopy(board)
        newb = move_piece(newb, m, color)
        newb = update_attacked(newb)
        newb = update_castling_rights(newb)

        # if m.capture_type != "none"
        #     pt.captures[depth] += 1
        # end
        # if m.promotion_type != "none"
        #     pt.promotions[depth] += 1
        # end

        if depth == 1
            move_name = m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]
        else
            pt.divide[move_name] += 1
        end
        # if move_name == "rook-a8a2"
        #     println(c, " ", m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target])
        # end
        # move_name = m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]
        # println(depth, " ", move_name)
        # println(m)

        pt = explore(pt, newb, max_depth, depth+1, new_color, move_name)
        # board = unmove_piece(board, m, color)
        # board = update_attacked(board)
        # board = update_castling_rights(board)
    end

    return pt
end
