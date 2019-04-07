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


# function get_pawns_list(board::Bitboard, color::String="white")
#     if color == "white"
#         same = board.white
#         other = board.black
#         other_king = board.k
#         pieces = board.P
#         one_step = WHITE_PAWN_ONESTEP_MOVES
#         two_steps = WHITE_PAWN_TWOSTEPS_MOVES
#         attacks = WHITE_PAWN_ATTACK
#         opponent_color = "black"
#         promotion_rank = MASK_RANK_8
#     else
#         same = board.black
#         other = board.white
#         other_king = board.K
#         pieces = board.p
#         one_step = BLACK_PAWN_ONESTEP_MOVES
#         two_steps = BLACK_PAWN_TWOSTEPS_MOVES
#         attacks = BLACK_PAWN_ATTACK
#         opponent_color = "white"
#         promotion_rank = MASK_RANK_1
#     end

#     piece_moves = Array{Move,1}()
#     for piece in pieces
#         move = one_step[piece]
#         if move & same == EMPTY && move & other == EMPTY && move != EMPTY
#             if move & promotion_rank == EMPTY
#                 push!(piece_moves, Move(piece, move,
#                                         "pawn", "none", "none", EMPTY, "-"))
#             else
#                 for new_piece in ["queen", "rook", "night", "bishop"]
#                     push!(piece_moves, Move(piece, move, "pawn",
#                                             "none", new_piece, EMPTY, "-"))
#                 end
#             end
#             if (two_steps[piece] & same == EMPTY && 
#                 two_steps[piece] & other == EMPTY && 
#                 two_steps[piece] != EMPTY)
#                 push!(piece_moves, Move(piece, two_steps[piece],
#                                         "pawn", "none", "none", piece, "-"))
#             end
#             for attack in attacks[piece]
#                 if attack & same == EMPTY &&
#                    attack & other != EMPTY && 
#                    attack != EMPTY

#                     taken_piece = find_piece_type(board, attack, opponent_color)
#                     if move & promotion_rank == EMPTY
#                         push!(piece_moves, Move(piece, attack,
#                                                 "pawn", taken_piece, "none",
#                                                 EMPTY, "-"))
#                     else
#                         for new_piece in ["queen", "rook", "night", "bishop"]
#                             push!(piece_moves, Move(piece, attack,
#                                                     "pawn", taken_piece,
#                                                     new_piece, EMPTY, "-"))
#                         end
#                     end
#                 elseif board.enpassant_square != EMPTY &&
#                        attack == board.enpassant_square
#                     push!(piece_moves, Move(piece, attack, "pawn", "none",
#                                             "none", EMPTY, "-"))
#                 end
#             end
#         end
#     end
#     return piece_moves
# end


function add_promotions(pawns_moves::Array{Move,1}, source::UInt64,
    target::UInt64, taken_piece::String="none")

    for promotion_type in ["queen", "rook", "night", "bishop"]
        push!(pawns_moves, Move(source, target, "pawn", taken_piece,
            promotion_type, EMPTY, "-"))
    end

    return pawns_moves
end


function find_pawn_pseudo!(pawns_moves::Array{Move,1}, board::Bitboard,
    pawn::UInt64, color::String="white")

    if color == "white"
        home_rank = MASK_RANK_2
        promotion_rank = MASK_RANK_7
        one_step = WHITE_PAWN_ONESTEP_MOVES
        two_steps = WHITE_PAWN_TWOSTEPS_MOVES
        attacks = WHITE_PAWN_ATTACK
        others = board.black
        enpassant_rank = MASK_RANK_6
        opponent_color = "black"
    else
        home_rank = MASK_RANK_7
        promotion_rank = MASK_RANK_2
        one_step = BLACK_PAWN_ONESTEP_MOVES
        two_steps = BLACK_PAWN_TWOSTEPS_MOVES
        attacks = BLACK_PAWN_ATTACK
        others = board.white
        enpassant_rank = MASK_RANK_3
        opponent_color = "white"
    end

    # move once
    if one_step[pawn] & board.taken == EMPTY # check front square
        if pawn & promotion_rank != EMPTY
            pawns_moves = add_promotions(pawns_moves, pawn, one_step[pawn], "none")
        else
            # move once
            push!(pawns_moves, Move(pawn, one_step[pawn], "pawn", "none",
                "none", EMPTY, "-"))

            # move twice and take note of the en-passant square
            if pawn & home_rank != EMPTY
                if two_steps[pawn] & board.taken == EMPTY
                    push!(pawns_moves, Move(pawn, two_steps[pawn],
                        "pawn", "none", "none", one_step[pawn], "-"))
                end
            end
        end
    end

    # attack squares
    pawn_attacks = attacks[pawn]
    for attack in pawn_attacks
        if attack & others != EMPTY
            taken_piece = find_piece_type(board, attack, opponent_color)
            if pawn & promotion_rank != EMPTY
                pawns_moves = add_promotions(pawns_moves, pawn, attack, taken_piece)
                return
            else
                push!(pawns_moves, Move(pawn, attack, "pawn", taken_piece,
                    "none", EMPTY, "-"))
                return
            end
        elseif attack == board.enpassant_square # use enpassant square
            push!(pawns_moves, Move(pawn, attack, "pawn", "none", "none",
                EMPTY, "-"))
            return
        end
    end
end


function get_pawns_list(board::Bitboard, color::String="white")
    if color == "white"
        pawns = board.P
    else
        pawns = board.p
    end
    
    pawns_moves = Array{Move,1}()
    for pawn in pawns
        find_pawn_pseudo!(pawns_moves, board, pawn, color)
    end

    return pawns_moves
end
