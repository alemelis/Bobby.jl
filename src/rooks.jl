function slide(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64,
    shift::Int64, mask::UInt64)

    i = 1
    while true
        new_position = ui >> (i*shift)
        if new_position & mask == EMPTY
            if shift < 0
                return free_squares, edge_squares
            else
                shift *= -1
                i = 1
            end
        else
            if new_position & occ == EMPTY
                push!(free_squares, new_position)
                i += 1
            else
                push!(edge_squares, new_position)
                if shift < 0
                    return free_squares, edge_squares
                else
                    shift *= -1
                    i = 1
                end
            end
        end
    end
end


function slide(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64,
    masks::Array{UInt64,1}, shift::Int64)

    for i in 1:length(masks)
        if masks[i] & ui != EMPTY
            return slide(free_squares, edge_squares, occ,
                ui, shift, masks[i])
        end
    end
end


function orthogonal_attack(occ::UInt64, ui::UInt64)
    free_squares = Array{UInt64,1}()
    edge_squares = Array{UInt64,1}()

    free_squares, edge_squares = slide(free_squares, edge_squares,
        occ, ui, MASK_FILES, 8)
    free_squares, edge_squares = slide(free_squares, edge_squares,
        occ, ui, MASK_RANKS, 1)

    return free_squares, edge_squares
end


function orthogonal_attack(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    free_squares, edge_squares = slide(free_squares, edge_squares,
        occ, ui, MASK_FILES, 8)
    free_squares, edge_squares = slide(free_squares, edge_squares,
        occ, ui, MASK_RANKS, 1)

    return free_squares, edge_squares
end


function gen_all_orthogonal_masks()
    ortho_masks = Dict{UInt64, UInt64}()
    for i = 1:64
        ui = INT2UINT[i]
        ortho_mask = EMPTY
        for j = 1:8
            if ui & MASK_RANKS[j] != EMPTY
                ortho_mask |= MASK_RANKS[j]
                break
            end
        end
        for k = 1:8
            if ui & MASK_FILES[k] != EMPTY
                ortho_mask |= MASK_FILES[k]
                break
            end
        end
        ortho_masks[ui] = ortho_mask
    end
    return ortho_masks
end
const ORTHO_MASKS = gen_all_orthogonal_masks()
