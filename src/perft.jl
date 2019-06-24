mutable struct PerftTree
    nodes :: Array{Int64,1}
    divide :: Dict{String,Int64}
end


function perft(board::Bitboard, depth::Int64, color::String)

    pt = PerftTree(zeros(depth), Dict{String,Int64}())

    return explore(pt, board, depth, 1, color)
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

function test_unmove(b, bm)
    if b.white != bm.white
        println("white")
        return false
    end
    if Set(b.P) != Set(bm.P)
        println("P")
        return false
    end
    if Set(b.R) != Set(bm.R)
        println("R")
        return false
    end
    if Set(b.N) != Set(bm.N)
        println("N")
        return false
    end
    if Set(b.B) != Set(bm.B)
        println("B")
        return false
    end
    if Set(b.Q) != Set(bm.Q)
        println("Q")
        return false
    end
    if b.K != bm.K
        println("K")
        return false
    end
    if Set(b.A) != Set(bm.A)
        println("A")
        return false
    end
    if b.black != bm.black
        println("black")
        return false
    end
    if Set(b.p) != Set(bm.p)
        println("p")
        return false
    end
    if Set(b.r) != Set(bm.r)
        println("r")
        return false
    end
    if Set(b.n) != Set(bm.n)
        println("n")
        return false
    end
    if Set(b.b) != Set(bm.b)
        println("b")
        return false
    end
    if Set(b.q) != Set(bm.q)
        println("q")
        return false
    end
    if b.k != bm.k
        println("k")
        return false
    end
    if Set(b.a) != Set(bm.a)
        println("a")
        return false
    end
    if b.free != bm.free
        println("free")
        return false
    end
    if b.taken != bm.taken
        println("taken")
        return false
    end
    if b.white_attacks != bm.white_attacks
        println("white_attacks")
        return false
    end
    if b.black_attacks != bm.black_attacks
        println("black_attacks")
        return false
    end
    if b.player_color != bm.player_color
        println("player_color")
        return false
    end
    if b.white_can_castle_queenside != bm.white_can_castle_queenside
        println("white_can_castle_queenside")
        return false
    end
    if b.white_can_castle_kingside  != bm.white_can_castle_kingside 
        println("white_can_castle_kingside ")
        return false
    end
    if b.black_can_castle_queenside != bm.black_can_castle_queenside
        println("black_can_castle_queenside")
        return false
    end
    if b.black_can_castle_kingside  != bm.black_can_castle_kingside 
        println("black_can_castle_kingside ")
        return false
    end
    if b.white_king_moved != bm.white_king_moved
        println("white_king_moved")
        return false
    end
    if b.black_king_moved != bm.black_king_moved
        println("black_king_moved")
        return false
    end
    if b.enpassant_square != bm.enpassant_square
        println("enpassant_square")
        return false
    end
    if b.enpassant_done != bm.enpassant_done
        println("enpassant_done")
        return false
    end
    if b.halfmove_clock != bm.halfmove_clock
        println("halfmove_clock")
        return false
    end
    if b.fullmove_clock != bm.fullmove_clock
        println("fullmove_clock")
        return false
    end
    if b.fen != bm.fen
        println("fen")
        return false
    end
    if b.game != bm.game
        println("game")
        return false
    end
    return true
end


function explore(pt::PerftTree, board::Bitboard,
    max_depth::Int64, depth::Int64, color::String="white",
    move_name::String="")

    moves = get_all_valid_moves(board, color)

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
    b = deepcopy(board)
    for m in moves
        # newb = deepcopy(board)
        board = move_piece(board, m, color)
        # board = update_attacked(board)
        board = update_castling_rights(board)

        if depth == 1
            move_name = m.piece_type*"-"*UINT2PGN[m.source]*UINT2PGN[m.target]
        end
        #     pt.divide[move_name] += 1
        # end

        pt = explore(pt, board, max_depth, depth+1, new_color, move_name)
        board = unmove_piece(board, m, color)
        board = update_castling_rights(board)
        board = update_attacked(board)
        # test_unmove(b, board)
        if ~test_unmove(b, board)
            println(move_name)
            ugly_print(b.white)
            ugly_print(board.white)
        end
        # board = update_castling_rights(board)
    end

    return pt
end
