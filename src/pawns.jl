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
const BLACK_PAWN_ONESTEP_MOVES = gen_all_pawns_one_step_valid_moves(
    "black")


function gen_pawn_two_steps_valid(source_square::UInt64,
    color::String="white")

    if color == "white"
        return source_square << 16
    else
        return source_square >> 16
    end
end


function gen_all_pawns_two_steps_valid_moves(color::String="white")
    pawn_moves = Dict{UInt64, UInt64}()

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

function get_pawns_list(board::Bitboard, color::String="white")
    if color == "white"
        same = board.white
        other = board.black
        other_king = board.k
        pieces = board.P
        one_step = WHITE_PAWN_ONESTEP_MOVES
        two_steps = WHITE_PAWN_TWOSTEPS_MOVES
        attacks = WHITE_PAWN_ATTACK
        opponent_color = "black"
    else
        same = board.black
        other = board.white
        other_king = board.K
        pieces = board.p
        one_step = BLACK_PAWN_ONESTEP_MOVES
        two_steps = BLACK_PAWN_TWOSTEPS_MOVES
        attacks = BLACK_PAWN_ATTACK
        opponent_color = "white"
    end

    piece_moves = Set{Move}()
    for piece in pieces
        move = one_step[piece]
        if move & same == EMPTY && move & other == EMPTY && move != EMPTY
            push!(piece_moves, Move(piece, move,
                                    "pawn", "none", "none"))
            if (two_steps[piece] & same == EMPTY && 
                two_steps[piece] & other == EMPTY && 
                two_steps[piece] != EMPTY)
                push!(piece_moves, Move(piece, two_steps[piece],
                                        "pawn", "none", "none"))
            end
            for attack in attacks[piece]
                if attack & same == EMPTY &&
                   attack & other != EMPTY &&
                   attack != EMPTY
                    taken_piece = find_piece_type(board, attack, opponent_color)
                    push!(piece_moves, Move(piece, attack,
                                            "pawn", taken_piece, "none"))
                end
            end
        end
    end
    return piece_moves
end
