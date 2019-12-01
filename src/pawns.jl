function gen_pawn_one_step_valid(source_square::UInt64,
    color::String="white")

    if color == "white"
        return source_square << 8
    else
        return source_square >> 8
    end
end


function gen_all_pawns_one_step_valid_moves(color::String="white")
    pawn_moves = Dict{UInt64, UInt64}()

    for i in 1:8
        pawn_moves[INT2UINT[i]] = EMPTY
    end

    for i in 9:56
        pawn_moves[INT2UINT[i]] = gen_pawn_one_step_valid(INT2UINT[i],
            color)
    end

    for i in 57:64
        pawn_moves[INT2UINT[i]] = EMPTY
    end

    return pawn_moves
end
const WHITE_PAWN_ONESTEP_MOVES = gen_all_pawns_one_step_valid_moves()
const BLACK_PAWN_ONESTEP_MOVES = gen_all_pawns_one_step_valid_moves("black")


function gen_pawn_two_steps_valid(source_square::UInt64,
    color::String="white")

    if color == "white"
        return source_square << 16
    else
        return source_square >> 16
    end
end


function gen_all_pawns_two_steps_valid_moves(color::String="white")
    pawn_moves = Dict{UInt64,UInt64}()

    if color == "white"
        for i in 1:48
            pawn_moves[INT2UINT[i]] = EMPTY
        end

        for i in 49:56
            pawn_moves[INT2UINT[i]] = gen_pawn_two_steps_valid(
                INT2UINT[i])
        end

        for i in 57:64
            pawn_moves[INT2UINT[i]] = EMPTY
        end
    else
        for i in 1:8
            pawn_moves[INT2UINT[i]] = EMPTY
        end

        for i in 9:16
            pawn_moves[INT2UINT[i]] = gen_pawn_two_steps_valid(
                INT2UINT[i], color)
        end

        for i in 17:64
            pawn_moves[INT2UINT[i]] = EMPTY
        end
    end

    return pawn_moves
end
const WHITE_PAWN_TWOSTEPS_MOVES = gen_all_pawns_two_steps_valid_moves()
const BLACK_PAWN_TWOSTEPS_MOVES = gen_all_pawns_two_steps_valid_moves("black")


function gen_pawn_attacked_valid(source_square::UInt64,
    color::String="white")

    target_squares = zeros(UInt64, 0)

    if color == "white"
        if source_square & CLEAR_FILE_A != EMPTY
            push!(target_squares, source_square << 9)
        end
        if source_square & CLEAR_FILE_H != EMPTY
            push!(target_squares, source_square << 7)
        end
    else
        if source_square & CLEAR_FILE_H != EMPTY
            push!(target_squares, source_square >> 9)
        end
        if source_square & CLEAR_FILE_A != EMPTY
            push!(target_squares, source_square >> 7)
        end
    end

    return target_squares
end


function gen_all_pawns_valid_attack(color::String="white")
    pawn_moves = Dict{UInt64, Array{UInt64,1}}()
    for i in 1:64
        pawn_moves[INT2UINT[i]] = gen_pawn_attacked_valid(INT2UINT[i], color)
    end
    return pawn_moves
end
const WHITE_PAWN_ATTACK = gen_all_pawns_valid_attack()
const BLACK_PAWN_ATTACK = gen_all_pawns_valid_attack("black")


function add_promotions!(pawn_moves::Array{Move,1}, source::UInt64,
    target::UInt64, taken_piece::String="none")

    for promotion_type in ["queen", "rook", "night", "bishop"]
        push!(pawn_moves, Move(source, target, "pawn", taken_piece,
            promotion_type, EMPTY, "-", EMPTY))
    end
end


function get_pawn_moves!(pawn_moves::Array{Move,1}, ui::UInt64,
    friends::Bitboard, enemy::Bitboard, taken::UInt64, color::String,
    enpassant_square::UInt64)

    # move once
    if friends.one_step[ui] & taken == EMPTY # check front square
        if ui & friends.promotion_rank != EMPTY
            add_promotions!(pawn_moves, ui, friends.one_step[ui], "none")
        else
            # move once
            push!(pawn_moves, Move(ui, friends.one_step[ui], "pawn", "none",
                "none", EMPTY, "-", EMPTY))

            # move twice and take note of the en-passant square
            if ui & friends.home_rank != EMPTY
                if friends.two_steps[ui] & taken == EMPTY
                    push!(pawn_moves, Move(ui, friends.two_steps[ui], "pawn",
                        "none", "none", friends.one_step[ui], "-", EMPTY))
                end
            end
        end
    end

    # attack squares
    pawn_attacks = friends.attacks[ui]
    for attack in pawn_attacks
        if attack & enemy.pieces != EMPTY
            if ui & friends.promotion_rank != EMPTY
                add_promotions!(pawn_moves, ui, attack,
                    get_piece_type(enemy, attack))
            else
                push!(pawn_moves, Move(ui, attack, "pawn",
                    get_piece_type(enemy, attack), "none", EMPTY, "-", EMPTY))
            end
        elseif attack == enpassant_square
         # &&
            # attack & friends.enpassant_rank != EMPTY
            push!(pawn_moves, Move(ui, attack, "pawn", "none", "none",
                EMPTY, "-", enemy.one_step[attack]))
        end
    end
end
