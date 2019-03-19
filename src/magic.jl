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




function star_attack(board::UInt64, ui::UInt64)
    ortho_moves, ortho_edges = orthogonal_attack(board, ui)
    cross_moves, cross_edges = cross_attack(board, ui)

    for m in cross_moves
        push!(ortho_moves, m)
    end
    for e in cross_edges
        push!(ortho_edges, e)
    end
    return ortho_moves, ortho_edges

end
