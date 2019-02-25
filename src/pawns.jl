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
const BLACK_PAWN_TWOSTEPS_MOVES = gen_all_pawns_two_steps_valid_moves(
    "black")


function gen_pawn_attacked_valid(source_square::UInt64,
    color::String="white")

    target_squares = zeros(UInt64, 0)

    if color == "white"
        push!(target_squares, (source_square & CLEAR_FILE_A) << 9)
        push!(target_squares, (source_square & CLEAR_FILE_H) << 7)
    else
        push!(target_squares, (source_square & CLEAR_FILE_A) >> 9)
        push!(target_squares, (source_square & CLEAR_FILE_H) >> 7)
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


function get_pawns_valid_list(board::Bitboard, color::String="white")
    if color == "white"
        same = board.white
        other = board.black
        pieces = board.P
        one_step = WHITE_PAWN_ONESTEP_MOVES
        two_step = WHITE_PAWN_TWOSTEPS_MOVES
        attacks = WHITE_PAWN_ATTACK
    else
        same = board.black
        other = board.white
        pieces = board.p
        one_step = BLACK_PAWN_ONESTEP_MOVES
        two_step = BLACK_PAWN_TWOSTEPS_MOVES
        attacks = BLACK_PAWN_ATTACK
    end

    piece_moves = Set()

    for piece in pieces
        move = one_step[piece]
        if move & same == EMPTY && move & other == EMPTY && move != EMPTY
            if ~will_be_in_check(board, piece, move, color)
                push!(piece_moves, (piece, move))
            end
            if (two_step[piece] & same == EMPTY && 
                two_step[piece] & other == EMPTY && 
                two_step[piece] != EMPTY)
                if ~will_be_in_check(board, piece, two_step[piece], color)
                    push!(piece_moves, (piece, two_step[piece]))
                end
            end
            for attack in attacks[piece]
                if other & attack != EMPTY
                    if ~will_be_in_check(board, piece, attack, color)
                        push!(piece_moves, (piece, attack))
                    end
                end
            end
        end
    end
    return piece_moves
end


# function get_current_pawns_valid(board::Bitboard, color::String="white")
#     if color == "white"
#         pawns = board.P
#         same_color = board.white
#     else
#         pawns = board.p
#         same_color = board.black
#     end

#     if isempty(pawns)
#         return Set()
#     end

#     for source in pawns
#         one_step = 
#         for target in targets
#             if target & same_color == EMPTY # do not take same color pieces

#                 #TODO: check check, pin, etc...

#                 push!(pawns_valid, (source, target))
#             end
#         end
#     end
#     return pawns_valid
# end

# # function get_current_nights_valid(nights::Array{UInt64,1}, same_color::UInt64)
#     nights_valid = Set()
#     for source in nights
#         targets = NIGHT_MOVES[source]
#         for target in targets
#             if target & same_color == EMPTY # do not take same color pieces

#                 #TODO: check check, pin, etc...

#                 push!(nights_valid, (source, target))
#             end
#         end
#     end
#     return nights_valid
# end

# # check attacking squares
# if increment == -8
#     pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
#     pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
# elseif increment == 8
#     pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 9
#     pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 7
# end
# pawns_attack = pawns_lx_atk .& other
# pawns_attack .|= pawns_rx_atk .& other

# return pawns_attack


#-----

function getPawnsValidList(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        pawns = board.P
        other = board.black
        increment = -8 #upward
    elseif color == "black"
        pawns = board.p
        other = board.white
        increment = +8 #downward
    end

    taken = board.taken
    pawns_valid = Set()

    pawns_no = sum.(Int.(pawns))
    pawns_seen = 0

    if pawns_no == 0
        return pawns_valid
    end

    for i = 1:64
        if pawns[i]
            pawns_seen += 1
            front_square = i + increment
            if ~taken[front_square]
                if validatePawnMove(board, lu_tabs, i, front_square, color)
                    push!(pawns_valid, (i, front_square))
                end
                if (increment < 0 && pawns[i] & lu_tabs.mask_rank[i,2]) || 
                    (increment > 0 && pawns[i] .& lu_tabs.mask_rank[i,7])
                    double_square = front_square + increment
                    if ~taken[double_square]
                        if validatePawnMove(board, lu_tabs, i, double_square,
                            color)
                            push!(pawns_valid, (i, double_square))
                        end
                    end
                end
            end
        end
        if pawns_seen == pawns_no
            @goto a
        end
    end
    @label a

    pawns_attack = getPawnsAttackTakenList(board, lu_tabs, color)
    
    return union(pawns_valid, pawns_attack)
end


function validatePawnMove(board, lu_tabs, source, target, color)
    tmp_b = deepcopy(board)
    tmp_b = movePawn(tmp_b, source, target, color)

    return  ~willBeInCheck(tmp_b, lu_tabs, color)
end


function getPawnsValid(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        pawns = board.P
        other = board.black
        increment = -8 #upward
    elseif color == "black"
        pawns = board.p
        other = board.white
        increment = +8 #downward
    end

    taken = board.taken

    pawns_valid = falses(64)

    for i = 1:64
        if pawns[i]
            # check the single space infront of the pawn
            front_square = i + increment
            if taken[front_square]
                continue
            else
                pawns_valid[front_square] = true
                # check double space if on home rank
                if (increment < 0 && pawns[i] & lu_tabs.mask_rank[i,2]) || 
                    (increment > 0 && pawns[i] .& lu_tabs.mask_rank[i,7])
                    double_square = front_square + increment
                    if taken[double_square]
                        continue
                    else
                        pawns_valid[double_square] = true
                    end
                end
            end
        end
    end

    pawns_valid .|= getPawnsAttackTaken(board, lu_tabs, color)
    
    return pawns_valid
end


function getPawnsAttackTaken(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        pawns = board.P
        other = board.black
        increment = -8 #upward
    elseif color == "black"
        pawns = board.p
        other = board.white
        increment = +8 #downward
    end

    # check attacking squares
    if increment == -8
        pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
        pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
    elseif increment == 8
        pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 9
        pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 7
    end
    pawns_attack = pawns_lx_atk .& other
    pawns_attack .|= pawns_rx_atk .& other

    return pawns_attack
end


function getPawnsAttackTakenList(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        pawns = board.P
        other = board.black
        other_king = board.k
        i1 = -9 #upward
        i2 = -7
    elseif color == "black"
        pawns = board.p
        other = board.white
        other_king = board.K
        i1 = 8 #downward
        i2 = 8
    end

    pawns_attack = Set()
    for i = 1:64
        if pawns[i] && lu_tabs.clear_file[i,1] && other[i + i1] && ~other_king[i + i1]
            if validatePawnMove(board, lu_tabs, i, i + i1, color)
                push!(pawns_attack, (i, i + i1))
            end
        end
        if pawns[i] && lu_tabs.clear_file[i,8] && other[i + i2] && ~other_king[i + i2]
            if validatePawnMove(board, lu_tabs, i, i + i2, color)
                push!(pawns_attack, (i, i + i2))
            end
        end
    end

    return pawns_attack
end


function getPawnsAttackGeneric(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")
    if color == "white"
        pawns = board.P
        same = board.white
        increment = -8 #upward
    elseif color == "black"
        pawns = board.p
        same = board.black
        increment = +8 #downward
    end

    # check attacking squares
    if increment == -8
        pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,1]) << 9
        pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,8]) << 7
    elseif increment == 8
        pawns_lx_atk = (pawns .& lu_tabs.clear_file[:,8]) >> 9
        pawns_rx_atk = (pawns .& lu_tabs.clear_file[:,1]) >> 7
    end
    pawns_attack = pawns_lx_atk  .& .~same
    pawns_attack .|= pawns_rx_atk  .& .~same

    return pawns_attack
end


function movePawn(board::Bitboard, source::Int64, target::Int64,
    color::String="white", new_piece::String="Q")

    if color == "white"
        board.P[source] = false
        board.P[target] = true
        board = moveSourceTargetWhite(board, source, target)
        if target <= 8
            board = promotePawn(board, target, color, new_piece)
        end
    else
        board.p[source] = false
        board.p[target] = true
        board = moveSourceTargetBlack(board, source, target)
        if target >= 57
            board = promotePawn(b, target, color, new_piece)
        end
    end
    return board
end


function promotePawn(board::Bitboard, target::Int64, color::String="white",
    new_piece::String="Q")

    if color == "white"
        board.P[target] = false
        if new_piece == "Q"
            board.Q[target] = true
        elseif new_piece == "R"
            board.R[target] = true
        elseif new_piece == "B"
            board.B[target] = true
        elseif new_piece == "N"
            board.N[target] = true
        end
    else
        board.P[target] = false
        if new_piece == "Q"
            board.q[target] = true
        elseif new_piece == "R"
            board.r[target] = true
        elseif new_piece == "B"
            board.b[target] = true
        elseif new_piece == "N"
            board.n[target] = true
        end
    end

    return board
end