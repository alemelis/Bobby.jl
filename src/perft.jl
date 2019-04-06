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
    pt = explore(pt, board, depth, 1, color)
    # println(pt)
    # println(sum(pt.nodes))
    # print_perftree(pt)
    return pt
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
    max_depth::Int64, depth::Int64, color::String="white", move_name::String="")
    
    total_pieces = count_total_pieces(board)
    moves = get_all_valid_moves(board, color)

    if depth == 1
        for m in moves
            push!(pt.divide,
                m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]=>0)
        end
    else
        pt.divide[move_name] += length(moves)
    end

    if check_check_raytrace(board, color) && depth > 1
        check = true
        pt.checks[depth-1] += 1
    else
        check = false
    end

    if length(moves) == 0 # ???????? stalemate
        pt.mates[depth-1] += 1
        return pt
    end

    if depth > max_depth
        return pt
    end

    pt.nodes[depth] += length(moves)

    new_color = change_color(color)
    for m in moves
        move_piece!(board, m, color)
       
        if m.capture_type != "none"
            pt.captures[depth] += 1
        end
        if m.promotion_type != "none"
            pt.promotions[depth] += 1
        end
        
        if depth == 1
            move_name = m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]
        end

        pt = explore(pt, board, max_depth, depth+1, new_color, move_name)
        unmove_piece!(board, m, color)
    end

    return pt
end
