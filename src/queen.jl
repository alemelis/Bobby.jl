function get_queen_valid(board::Bitboard, color::String="white")
    if color == "white"
        queens = board.Q
        same = board.white
        other = board.black
    elseif color == "black"
        queens = board.q
        same = board.black
        other = board.white
    end

    occupancy = same | other

    queen_moves = zeros(UInt64, 0)
    queen_edges = zeros(UInt64, 0)
    for queen in queens
        moves, edges = star_attack(occupancy, queen)
        append!(queen_moves, moves)
        for edge in edges
            if edge & same == EMPTY
                append!(queen_moves, edge)
            end
        end
    end
    return queen_moves
end

#---
function getQueenValid(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")
    
    if color == "white"
        queen = board.Q
        same = board.white
        other = board.black
    elseif color == "black"
        queen = board.q
        same = board.black
        other = board.white
    end

    queen_no = sum.(Int.(queen))

    queen_valid = falses(64)

    if queen_no == 0
        return queen_valid
    end

    for s in zip(lu_tabs.starts, lu_tabs.steps, lu_tabs.ends)
        queen_on_diagonal = sum.(Int.(queen[s[1]:s[2]:s[3]]))
        if queen_on_diagonal != 0
            queen_arr = queen[s[1]:s[2]:s[3]]
            for j = 1:length(queen_arr)
                if queen_arr[j]
                    queen_valid[s[1]:s[2]:s[3]] .|= Bobby.slidePiece(
                        same[s[1]:s[2]:s[3]], other[s[1]:s[2]:s[3]], j)
                end
            end
        end
    end
    
    #files
    for j = 1:8
        queen_arr = queen[j:8:64]
        if any(queen_arr)
            same_arr = same[j:8:64]
            other_arr = other[j:8:64]
            for i = 1:8
                if queen_arr[i]
                    queen_valid[j:8:64] .|= Bobby.slidePiece(same_arr,
                        other_arr, i)
                end
            end
        end
    end

    #ranks
    for i = 1:8:64
        queen_arr = queen[i:i+7]
        if any(queen_arr)
            same_arr = same[i:i+7]
            other_arr = other[i:i+7]
            for j = 1:8
                if queen_arr[j]
                    queen_valid[i:i+7] .|= Bobby.slidePiece(same_arr,
                        other_arr, j)
                end
            end
        end
    end

    return queen_valid
end


function moveQueen(board::Bitboard, source::Int64, target::Int64,
    color::String="white")

    if color == "white"
        board.Q[source] = false
        board.Q[target] = true
        board = moveSourceTargetWhite(board, source, target)
    else
        board.q[source] = false
        board.q[target] = true
        board = moveSourceTargetBlack(board, source, target)
    end
    return board
end


function validateQueenMove(board, lu_tabs, source, target, color)
    tmp_b = deepcopy(board)
    tmp_b = moveQueen(tmp_b, source, target, color)

    return  ~willBeInCheck(tmp_b, lu_tabs, color)
end


function getQueenValidList(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")
    
    if color == "white"
        queen = board.Q
        same = board.white
        other = board.black
    elseif color == "black"
        queen = board.q
        same = board.black
        other = board.white
    end

    queen_no = sum.(Int.(queen))

    queen_valid = Set()

    if queen_no == 0
        return queen_valid
    end

    queen_seen = 0

    for s in zip(lu_tabs.starts, lu_tabs.steps, lu_tabs.ends)
        for i = s[1]:s[2]:s[3]
            if queen[i]
                queen_seen += 1
                queen_valids = falses(64)
                queen_arr = queen[s[1]:s[2]:s[3]]
                for j = 1:length(queen_arr)
                    if queen_arr[j]
                        queen_valids[s[1]:s[2]:s[3]] .|= Bobby.slidePiece(
                            same[s[1]:s[2]:s[3]], other[s[1]:s[2]:s[3]], j)
                        for k = 1:64
                            if queen_valids[k]
                                if validateQueenMove(board, lu_tabs, i, k,
                                    color)
                                    push!(queen_valid, (i, k))
                                end
                            end
                        end
                    end
                end
                if queen_seen == queen_no
                    @goto a
                end
            end
        end
    end
    @label a

    # files
    queen_seen = 0
    for j = 1:8
        for i = 1:8
            qi = (i-1)*8 + j
            if queen[qi]
                queen_seen += 1
                queen_valids = falses(64)
                same_arr = same[j:8:64]
                other_arr = other[j:8:64]
                queen_valids[j:8:64] .|= Bobby.slidePiece(same_arr,
                        other_arr, i)
                for k = 1:64
                    if queen_valids[k]
                        if validateQueenMove(board, lu_tabs, qi, k,
                            color)
                            push!(queen_valid, (qi, k))
                        end
                    end
                end
            end
            if queen_seen == queen_no
                @goto b
            end
        end
    end
    @label b

    #ranks
    queen_seen = 0
    for i = 1:8:64
        queen_arr = queen[i:i+7]
        for l = 1:8
            if queen_arr[l]
                queen_seen += 1
                same_arr = same[i:i+7]
                other_arr = other[i:i+7]
                for j = 1:8
                    qi = i + j - 1
                    if queen_arr[j]
                        queen_valids = falses(64)
                        queen_valids[i:i+7] = Bobby.slidePiece(same_arr,
                            other_arr, j)
                        for k = 1:64
                            if queen_valids[k]
                                if validateQueenMove(board, lu_tabs, qi, k,
                                    color)
                                    push!(queen_valid, (qi, k))
                                end
                            end
                        end
                    end
                end
            end
            if queen_seen == queen_no
                return queen_valid
            end
        end
    end

    return queen_valid
end