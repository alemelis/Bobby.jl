
"""
    gen_night_valid(source_square::UInt64)

Given an initial position (as UInt64), return all the squares where a knight
may land. To be used to build hash-tables.

Example:
--------

    julia> nv = Bobby.gen_night_valid(b.n[1])
    3-element Array{UInt64,1}:
     0x0010000000000000
     0x0000200000000000
     0x0000800000000000
"""
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


"""
    gen_all_night_valid_moves()

Return a dictionary with all possible moves for a knight. Keys are UInt64
representing the knight position.

Example:
--------

    julia> Bobby.gen_all_night_valid_moves()
    Dict{UInt64,Array{UInt64,1}} with 64 entries:
      0x0000002000000000 => UInt64[0x0000800000000000, 0x0040000000000000,…
      0x0040000000000000 => UInt64[0x1000000000000000, 0x0000100000000000,…
    ⋮  => ⋮
"""
function gen_all_night_valid_moves()
    night_moves = Dict{UInt64, Array{UInt64,1}}()
    for i in 1:64
        night_moves[INT2UINT[i]] = gen_night_valid(INT2UINT[i])
    end
    return night_moves
end
const NIGHT_MOVES = gen_all_night_valid_moves()


function get_current_nights_valid(board::Bitboard, color::String="white")
    if color == "white"
        nights = board.N
        same_color = board.white
    else
        nights = board.n
        same_color = board.black
    end

    if isempty(nights)
        return Set()
    end
#   return get_current_nights_valid(nights, same_color)
# end

# function get_current_nights_valid(nights::Array{UInt64,1}, same_color::UInt64)
    nights_valid = Set()
    for source in nights
        targets = NIGHT_MOVES[source]
        for target in targets
            if target & same_color != EMPTY # do not take same color pieces

                #TODO: check check, pin, etc...

                push!(nights_valid, (source, target))
            end
        end
    end
    return nights_valid
end

#----

"""
    getNightsValid(board::Bitboard, lu_tabs::LookUpTables, color="white")

Find valid squares for knights.
"""
function getNightsValid(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        nights = board.N
        pieces = board.white
    elseif color == "black"
        nights = board.n
        pieces = board.black
    end

    spot_1 = (nights .& lu_tabs.clear_night_files[:,1]) << 10
    spot_2 = (nights .& lu_tabs.clear_night_files[:,2]) << 17
    spot_3 = (nights .& lu_tabs.clear_night_files[:,3]) << 15
    spot_4 = (nights .& lu_tabs.clear_night_files[:,4]) << 6

    spot_5 = (nights .& lu_tabs.clear_night_files[:,5]) >> 10
    spot_6 = (nights .& lu_tabs.clear_night_files[:,6]) >> 17
    spot_7 = (nights .& lu_tabs.clear_night_files[:,7]) >> 15
    spot_8 = (nights .& lu_tabs.clear_night_files[:,8]) >> 6

    nights_valid = spot_1 .| spot_2 .| spot_3 .| spot_4 .|
                   spot_5 .| spot_6 .| spot_7 .| spot_8

    return nights_valid .& .~pieces
end


function validateNightMove(board, lu_tabs, source, target, color)
    tmp_b = deepcopy(board)
    tmp_b = moveNight(tmp_b, source, target, color)

    return  ~willBeInCheck(tmp_b, lu_tabs, color)
end


function getNightsValidList(board::Bitboard, lu_tabs::LookUpTables,
    color::String="white")

    if color == "white"
        nights = board.N
        pieces = board.white
    elseif color == "black"
        nights = board.n
        pieces = board.black
    end

    nights_no = sum.(Int.(nights))
    nights_seen = 0

    nights_valid = Set()

    if nights_no == 0
        return nights_valid
    end

    increments = [-10, -17, -15, -6, 10, 17, 15, 6]
    for i = 1:64
        if nights[i]
            nights_seen += 1
            for j = 1:8
                if lu_tabs.clear_night_files[i,j]
                    if i + increments[j] >= 1 && i + increments[j] <= 64
                        if ~pieces[i + increments[j]]
                            if validateNightMove(board, lu_tabs, i,
                                i + increments[j], color)
                                push!(nights_valid, (i, i + increments[j]))
                            end
                        end
                    end
                end
            end
        end
        if nights_seen == nights_no
            return nights_valid
        end
    end
    return nights_valid
end


function moveNight(board::Bitboard, source::Int64, target::Int64,
    color::String="white")

    if color == "white"
        board.N[source] = false
        board.N[target] = true
        board = moveSourceTargetWhite(board, source, target)
    else
        board.n[source] = false
        board.n[target] = true
        board = moveSourceTargetBlack(board, source, target)
    end
    return board
end

