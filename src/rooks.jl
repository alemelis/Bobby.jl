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


function get_sliding_pieces_moves!(sliding_moves::Array{Move,1}, ui::UInt64,
    friends::UInt64, enemy::Bitboard, taken::UInt64, piece_type::String)
    if piece_type == "queen"
        attack_fun = star_attack
    elseif piece_type == "rook"
        attack_fun = orthogonal_attack
    elseif piece_type == "bishop"
        attack_fun = cross_attack
    end

    moves = Array{UInt64,1}()
    edges = Array{UInt64,1}()
    moves, edges = attack_fun(moves, edges, taken, ui)
    while length(moves) > 0
        push!(sliding_moves, Move(ui, pop!(moves), piece_type,
            "none", "none", EMPTY, "-"))
    end
    while length(edges) > 0
        edge = pop!(edges)
        if edge & friends == EMPTY && edge & enemy.pieces == EMPTY
            push!(sliding_moves, Move(ui, edge, piece_type, "none", "none",
                EMPTY, "-"))
        elseif edge & friends == EMPTY && edge & enemy.pieces != EMPTY
            push!(sliding_moves, Move(ui, edge, piece_type,
                get_piece_type(enemy, edge), "none", EMPTY, "-"))
        end
    end
end

