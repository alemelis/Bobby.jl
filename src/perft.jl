mutable struct PerftTree
    nodes :: Array{Int64,1}
    checks :: Array{Int64,1}
    mates :: Array{Int64,1}
    captures :: Array{Int64,1}
    divide :: Dict{String,Int64}
end


function perft(board, depth, color::String="white")
    pt = PerftTree(zeros(depth), zeros(depth), zeros(depth), zeros(depth),
        Dict{String,Int64}())
    pt = explore(pt, board, depth, 1, color)
    # println(pt)
    # println(sum(pt.nodes))
    print_perftree(pt)
end


function print_perftree(pt::PerftTree)
    println("Nodes    ", pt.nodes)
    println("Captures ", pt.captures)
    println("Checks   ", pt.checks)
    println("Mates    ", pt.mates)
    for x in sort(collect(pt.divide))
        println(x)
    end
end


function explore(pt::PerftTree, board::Bitboard, 
    max_depth::Int64, depth::Int64, color::String="white", move_name::String="")
    
    if check_check_raytrace(board, color)
        pt.checks[depth-1] += 1
        # Bobby.pretty_print(board)
    end
    total_pieces = count_total_pieces(board)
    moves = get_all_valid_moves(board, color)

    if depth == 1
        for m in moves
            push!(pt.divide, UINT2PGN[m.source]*UINT2PGN[m.target]=>0)
        end
    else
        pt.divide[move_name] += length(moves)
    end

    # for move in moves
    #     println(move.piece_type)#, " ", cvt_to_int(move.source), " ", cvt_to_int(move.target))
    # end
    if length(moves) == 0 # ?????????????????????????? stalemate
        pt.mates[depth-1] += 1
        return pt
    end

    if depth > max_depth
        return pt
    end

    pt.nodes[depth] += length(moves)

    new_color = change_color(color)
    for m in moves
        board = move_piece(board, m, color)
        # if m.check
        #     pt.checks[depth] += 1
            # if check_mate(board, new_color)
            #     pt.mates[depth] += 1
            #     board = unmove_piece(board, m, color)
            #     continue
            # end
        # end
        
        if count_total_pieces(board) < total_pieces
            pt.captures[depth] += 1
        end
        # println(UINT2PGN[m.source],UINT2PGN[m.target])
        if depth == 1
            move_name = UINT2PGN[m.source]*UINT2PGN[m.target]
        end
        pt = explore(pt, board, max_depth, depth+1, new_color, move_name)
        board = unmove_piece(board, m, color)
        # if depth == 1
        #     break
        # end
    end

    return pt
end


function count_total_pieces(board::Bitboard)
    total_pieces = 2
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
