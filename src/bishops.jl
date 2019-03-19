function slide_diagonal(board::UInt64, diag_mask::UInt64, ui::UInt64,
    compass_direction::String="NW")

    if compass_direction == "NW"
        increment_mod = 9
    else
        increment_mod = 7
    end
    direction = 1
    increment = direction*increment_mod

    moves = zeros(UInt64, 0)
    edges = zeros(UInt64, 0)

    while true
        if ((ui >> increment) & diag_mask) != EMPTY # we are on the diagonal
            if (board & ((ui>>increment) & diag_mask) == EMPTY &&
                ((ui>>increment) & diag_mask) != EMPTY)

                push!(moves, ui>>increment)
                increment += direction*increment_mod
            else
                push!(edges, ui>>increment)

                if direction == 1
                    direction = -1
                    increment = increment_mod*direction
                else
                    return moves, edges
                end
            end
        else
            if direction == 1
                direction = -1
                increment = increment_mod*direction
            else
                return moves, edges
            end
        end
    end
end


function diagonal_attack(board::UInt64, ui::UInt64)
    for i in 1:15
        if DIAGONALS[i] & ui != EMPTY
            return slide_diagonal(board, DIAGONALS[i], ui, "NW")
        end
    end
end

function antidiagonal_attack(board::UInt64, ui::UInt64)
    for i in 1:15
        if ANTIDIAGONALS[i] & ui != EMPTY
            return slide_diagonal(board, ANTIDIAGONALS[i], ui, "NE")
        end
    end
end


function cross_attack(board::UInt64, ui::UInt64)
    moves, edges = diagonal_attack(board, ui)
    anti_moves, anti_edges = antidiagonal_attack(board, ui)

    for move in anti_moves
        push!(moves, move)
    end

    for edge in anti_edges
        push!(edges, edge)
    end

    return moves, edges
end


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
