function gen_night_valid(source_square::UInt64)
    target_squares = zeros(UInt64, 0)
    for cj in zip(NIGHT_CLEAR_FILES, NIGHT_JUMPS)
        candidate_square = (source_square & cj[1]) >> cj[2]
        if candidate_square != EMPTY
            push!(target_squares, candidate_square)
        end
    end
    return target_squares
end


function gen_all_night_valid_moves()
    night_moves = Dict{UInt64, Array{UInt64,1}}()
    for i in 1:64
        night_moves[INT2UINT[i]] = gen_night_valid(INT2UINT[i])
    end
    return night_moves
end
const NIGHT_MOVES = gen_all_night_valid_moves()


function get_night_moves!(night_moves::Array{Move,1}, ui::UInt64,
    friends::UInt64, enemy::Bitboard)
    for jump in NIGHT_MOVES[ui]
        if jump & friends == EMPTY && jump & enemy.pieces == EMPTY
            push!(night_moves, Move(
                ui, jump, "night", "none", "none", EMPTY, "-", EMPTY))
        elseif jump & friends == EMPTY && jump & enemy.pieces != EMPTY
            push!(night_moves, Move(ui, jump, "night",
                get_piece_type(enemy, jump), "none", EMPTY, "-", EMPTY))
        end
    end
end
