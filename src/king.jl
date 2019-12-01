function gen_king_valid(source_square::UInt64)
    target_squares = zeros(UInt64, 0)

    for cms in zip(KING_MASK_FILES, KING_CLEAR_FILES, KING_SHIFTS)
        if source_square & cms[1] != EMPTY
            candidate_square = (source_square & cms[2]) << cms[3]
        else
            candidate_square = source_square << cms[3]
        end

        if candidate_square != EMPTY
            push!(target_squares, candidate_square)
        end
    end
    return target_squares
end


function gen_all_king_valid_moves()
    king_moves = Dict{UInt64, Array{UInt64,1}}()
    for i in 1:64
        king_moves[INT2UINT[i]] = gen_king_valid(INT2UINT[i])
    end
    return king_moves
end
const KING_MOVES = gen_all_king_valid_moves()
const WHITE_KING_HOME = PGN2UINT["e1"]
const BLACK_KING_HOME = PGN2UINT["e8"]


function get_king_moves!(king_moves::Array{Move,1}, ui::UInt64,
    friends::Bitboard, enemy::Bitboard, player_color::String,
    chessboard::Chessboard, rooks::UInt64)

    if ui == friends.king_home_sq
        if ~friends.king_moved
            if friends.can_castle_kingside == true
                if chessboard.free & friends.king_side_1st_sq != EMPTY &&
                    chessboard.free & friends.king_side_castling_sq != EMPTY &&
                    rooks & friends.king_side_rook_sq != EMPTY
                    if ~is_in_check(
                        chessboard, friends.king_home_sq, player_color) && #!!!
                        ~is_in_check(
                            chessboard, friends.king_side_1st_sq,
                            player_color) &&
                        ~is_in_check(
                            chessboard, friends.king_side_castling_sq,
                            player_color)
                        push!(king_moves, Move(
                            ui, friends.king_side_castling_sq, "king", "none",
                            "none", EMPTY, "K", EMPTY))
                    end
                end
            end
            if friends.can_castle_queenside == true
                if chessboard.free & friends.queen_side_1st_sq != EMPTY &&
                    chessboard.free & friends.queen_side_castling_sq != EMPTY &&
                    chessboard.free & 
                    friends.queen_side_rook_sq >> 1 != EMPTY &&
                    rooks & friends.queen_side_rook_sq != EMPTY
                    if ~is_in_check(
                        chessboard, friends.king_home_sq, player_color) &&
                        ~is_in_check(
                            chessboard, friends.queen_side_1st_sq,
                            player_color) &&
                        ~is_in_check(
                            chessboard, friends.queen_side_castling_sq,
                            player_color)
                        push!(king_moves, Move(
                            ui, friends.queen_side_castling_sq, "king", "none",
                            "none", EMPTY, "Q", EMPTY))
                    end
                end
            end
        end 
    end

    for move in KING_MOVES[ui]
        if move & friends.pieces == EMPTY && move & enemy.pieces == EMPTY
            push!(king_moves, Move(ui, move,
                "king", "none", "none", EMPTY, "-", EMPTY))
        elseif move & friends.pieces == EMPTY && move & enemy.pieces != EMPTY
            push!(king_moves, Move(ui, move,
                "king", get_piece_type(enemy, move), "none", EMPTY, "-", EMPTY))
        end
    end
end
