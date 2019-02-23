# https://web.archive.org/web/20180109042730/http://www.rivalchess.com/magic-bitboards/
function gen_rook_mask(i::Int64)
    pgn = INT2PGN[i]

    file = Int(pgn[1]) - 96
    rank = parse(Int, pgn[2])

    mask = xor(MASK_FILES[file], MASK_RANKS[rank])

    if INT2UINT[i] & FRAME != EMPTY # rook on the board frame
        if INT2UINT[i] & CORNERS != EMPTY # rook on a corner
            return mask & ~CORNERS
        else
            if file == 1
                return mask & CLEAR_RANK_1 & CLEAR_RANK_8 & CLEAR_FILE_H
            elseif file == 8
                return mask & CLEAR_RANK_1 & CLEAR_RANK_8 & CLEAR_FILE_A
            elseif rank == 1
                return mask & CLEAR_FILE_A & CLEAR_FILE_H & CLEAR_RANK_8
            elseif rank == 8
                return mask & CLEAR_FILE_A & CLEAR_FILE_H & CLEAR_RANK_1
            end
        end
    else
        return mask & ~FRAME # rook in the middle of the board
    end
end


function gen_rook_masks()
    rook_masks = Dict{UInt64, UInt64}()
    for i in 1:64
        rook_masks[INT2UINT[i]] = gen_rook_mask(i)
    end
    return rook_masks
end
const ROOK_MASKS = gen_rook_masks()

function get_rooks_valid(board::Bitboard, color::String="white")

    if color == "white"
        rooks = cvt_to_bitarray(board.R)
        same = cvt_to_bitarray(board.white)
        other = cvt_to_bitarray(board.black)
    elseif color == "black"
        rooks = cvt_to_bitarray(board.r)
        same = cvt_to_bitarray(board.black)
        other = cvt_to_bitarray(board.white)
    end

    rooks_valid = falses(64)

    #files
    for j = 1:8
        rooks_arr = rooks[j:8:64]
        if any(rooks_arr)
            same_arr = same[j:8:64]
            other_arr = other[j:8:64]
            for i = 1:8
                if rooks_arr[i]
                    rooks_valid[j:8:64] .|= Bobby.slidePiece(same_arr,
                        other_arr, i)
                end
            end
        end
    end

    #ranks
    for i = 1:8:64
        rooks_arr = rooks[i:i+7]
        if any(rooks_arr)
            same_arr = same[i:i+7]
            other_arr = other[i:i+7]
            for j = 1:8
                if rooks_arr[j]
                    rooks_valid[i:i+7] .|= Bobby.slidePiece(same_arr,
                        other_arr, j)
                end
            end
        end
    end

    return rooks_valid
end


# ------

function getRooksValid(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")
    return getRooksValid(board, color)
end


"""
    getRooksValid(board::Bitboard, color::String="white")

Find valid squares for rooks.
"""
function getRooksValid(board::Bitboard, color::String="white")

    if color == "white"
        rooks = board.R
        same = board.white
        other = board.black
    elseif color == "black"
        rooks = board.r
        same = board.black
        other = board.white
    end

    rooks_valid = falses(64)

    #files
    for j = 1:8
        rooks_arr = rooks[j:8:64]
        if any(rooks_arr)
            same_arr = same[j:8:64]
            other_arr = other[j:8:64]
            for i = 1:8
                if rooks_arr[i]
                    rooks_valid[j:8:64] .|= Bobby.slidePiece(same_arr,
                        other_arr, i)
                end
            end
        end
    end

    #ranks
    for i = 1:8:64
        rooks_arr = rooks[i:i+7]
        if any(rooks_arr)
            same_arr = same[i:i+7]
            other_arr = other[i:i+7]
            for j = 1:8
                if rooks_arr[j]
                    rooks_valid[i:i+7] .|= Bobby.slidePiece(same_arr,
                        other_arr, j)
                end
            end
        end
    end

    return rooks_valid
end

function moveRook(board::Bitboard, source::Int64, target::Int64,
    color::String="white")

    if color == "white"
        board.R[source] = false
        board.R[target] = true
        board = moveSourceTargetWhite(board, source, target)

        if source == 57
            board.a1_rook_moved = true
        elseif source == 64
            board.h1_rook_moved = true
        end
    else
        board.r[source] = false
        board.r[target] = true
        board = moveSourceTargetBlack(board, source, target)

        if source == 1
            board.a8_rook_moved = true
        elseif source == 8
            board.h8_rook_moved = true
        end
    end
    return board
end


function getRooksValidList(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        rooks = board.R
        same = board.white
        other = board.black
    elseif color == "black"
        rooks = board.r
        same = board.black
        other = board.white
    end

    rook_valid = Set()

    rooks_no = sum.(Int.(rooks))
    rooks_seen = 0

    if rooks_no == 0
        return rook_valid
    end

    #files
    for j = 1:8
        for i = 1:8
            ri = (i-1)*8 + j
            if rooks[ri]
                rooks_seen += 1
                rook_valids = falses(64)
                same_arr = same[j:8:64]
                other_arr = other[j:8:64]
                rook_valids[j:8:64] .|= Bobby.slidePiece(same_arr,
                        other_arr, i)
                for k = 1:64
                    if rook_valids[k]
                        if validateRookMove(board, lu_tabs, ri, k,
                            color)
                            push!(rook_valid, (ri, k))
                        end
                    end
                end
            end
            if rooks_seen == rooks_no
                @goto a
            end
        end
    end
    @label a
    
    #ranks
    rooks_seen = 0
    for i = 1:8:64
        rook_arr = rooks[i:i+7]
        for l = 1:8
            if rook_arr[l]
                rooks_seen += 1
                same_arr = same[i:i+7]
                other_arr = other[i:i+7]
                for j = 1:8
                    ri = i + j - 1
                    if rook_arr[j]
                        rook_valids = falses(64)
                        rook_valids[i:i+7] = Bobby.slidePiece(same_arr,
                            other_arr, j)
                        for k = 1:64
                            if rook_valids[k]
                                if validateRookMove(board, lu_tabs, ri, k,
                                    color)
                                    push!(rook_valid, (ri, k))
                                end
                            end
                        end
                    end
                end
            end
            if rooks_seen == rooks_no
                return rook_valid
            end
        end
    end

    return rook_valid
end


function validateRookMove(board, lu_tabs, source, target, color)
    tmp_b = deepcopy(board)
    tmp_b = moveRook(tmp_b, source, target, color)

    return  ~willBeInCheck(tmp_b, lu_tabs, color)
end