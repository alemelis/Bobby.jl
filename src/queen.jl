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

    queen_moves = zeros(UInt64, 0)
    queen_edges = zeros(UInt64, 0)
    for queen in queens
        moves, edges = star_attack(board.taken, queen)
        append!(queen_moves, moves)
        for edge in edges
            if edge & same == EMPTY
                append!(queen_moves, edge)
            end
        end
    end
    return queen_moves
end

function get_queen_valid_list(board::Bitboard, color::String="white")
    if color == "white"
        queens = board.Q
        same = board.white
        other = board.black
    elseif color == "black"
        queens = board.q
        same = board.black
        other = board.white
    end

    queen_moves = Set()
    for queen in queens
        moves, edges = star_attack(board.taken, queen)
        for move in moves
            push!(queen_moves, (queen, move))
        end
        for edge in edges
            if edge & same == EMPTY
                push!(queen_moves, (queen, edge))
            end
        end
    end
    return queen_moves
end
