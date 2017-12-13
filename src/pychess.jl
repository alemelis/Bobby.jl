@pyimport chess

function buildBoard()
    board = chess.Board()
    # PyObject Board('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')

    return board
end

function makeMove(board :: PyCall.PyObject, move)
    board[:push_san](move)

    return board
end

function makeMoves(board :: PyCall.PyObject, moves)
    for move in moves
        board = makeMove(board, move)
    end

    return board
end

function boardToStrings(board :: PyCall.PyObject)
    bs = string(board)
    # "PyObject Board('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')"

    bs_notype = split(bs, '\'')[2]
    # "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    bs_game = split(bs_notype, ' ')[1]
    # "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

    bs_rows = split(bs_game, '/')
    #=
    "rnbqkbnr"
    "pppppppp"
    "8"
    "8"
    "8"
    "8"
    "PPPPPPPP"
    "RNBQKBNR"
    =#

    return bs_rows
end

"Convert empty cells from number to zeros"
function cleanRows(bs_rows)
    rows = []
    for i in 1:8
        row = bs_rows[i]

        new_row = ""
        for j in 1:length(row)
            c = row[j]
            if Int(c) - 48 <= 9 && Int(c) - 48 >= 1
                v = Int(c) - 48
                new_row *= "0"^v
            else
                new_row *= string(c)
            end
        end

        push!(rows, new_row)
    end
    return rows
end
