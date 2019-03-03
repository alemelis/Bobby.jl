function get_bishops_valid(board::Bitboard, color::String="white")
    if color == "white"
        bishops = board.B
        same = board.white
        other = board.black
    elseif color == "black"
        bishops = board.b
        same = board.black
        other = board.white
    end

    bishop_moves = zeros(UInt64, 0)
    bishop_edges = zeros(UInt64, 0)
    for bishop in bishops
        moves, edges = cross_attack(board.taken, bishop)
        append!(bishop_moves, moves)
        for edge in edges
            if edge & same == EMPTY
                append!(bishop_moves, edge)
            end
        end
    end
    return bishop_moves
end
