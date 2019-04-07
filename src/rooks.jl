function slide(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64,
    shift::Int64, mask::UInt64)

    i = 1
    direction = 1
    while true
        new_position = ui >> (direction*i*shift)
        if new_position & mask == EMPTY
            if direction == -1
                return free_squares, edge_squares
            else
                direction = -1
                i = 1
            end
        else
            if new_position & occ == EMPTY
                push!(free_squares, new_position)
                i += 1
            else
                push!(edge_squares, new_position)
                if direction == -1
                    return free_squares, edge_squares
                else
                    direction = -1
                    i = 1
                end
            end
        end
    end
end

function slide_rank(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    for i in 1:8
        if MASK_RANKS[i] & ui != EMPTY
            return slide(free_squares, edge_squares, occ,
                ui, 1, MASK_RANKS[i])
        end
    end
end

function slide_file(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    for i in 1:8
        if MASK_FILES[i] & ui != EMPTY
            return slide(free_squares, edge_squares, occ,
                ui, 8, MASK_FILES[i])
        end
    end
end

function orthogonal_attack(occ::UInt64, ui::UInt64)
    free_squares = Array{UInt64,1}()
    edge_squares = Array{UInt64,1}()

    free_squares, edge_squares = slide_rank(free_squares, edge_squares,
        occ, ui)
    free_squares, edge_squares = slide_file(free_squares, edge_squares,
        occ, ui)

    return free_squares, edge_squares
end

function orthogonal_attack(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    free_squares, edge_squares = slide_rank(free_squares, edge_squares,
        occ, ui)
    free_squares, edge_squares = slide_file(free_squares, edge_squares,
        occ, ui)

    return free_squares, edge_squares
end
