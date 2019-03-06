mutable struct PerftTree
    nodes :: Array{Int64,1}
    checks :: Array{Int64,1}
    mates :: Array{Int64,1}
    captures :: Array{Int64,1}
end

function perft(board, depth, color::String="white")
    pt = PerftTree(zeros(depth), zeros(depth), zeros(depth), zeros(depth))
    pt = explore(pt, board, depth, 1, color)
    println(pt)
    println(sum(pt.nodes))
end


function explore(pt::PerftTree, board::Bitboard, 
    max_depth::Int64, depth::Int64, color::String="white")

    if depth > max_depth
        return pt
    end
    
    total_pieces = count_total_pieces(board)
    moves = get_all_valid_moves(board, color)
    if length(moves) == 0
        return pt
    end
    pt.nodes[depth] += length(moves)

    new_color = change_color(color)
    for m in moves
        tmp_b = deepcopy(board)
        tmp_b = move_piece(tmp_b, m.source, m.target, color)
        if check_check(tmp_b, new_color)
            pt.checks[depth] += 1
            if check_mate(tmp_b, new_color)
                pt.mates[depth] += 1
                continue
            end
        end
        
        if count_total_pieces(tmp_b) < total_pieces
            pt.captures[depth] += 1
        end

        pt = explore(pt, tmp_b, max_depth, depth+1, new_color)
        # board = unmove_piece(board, m, color)
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
