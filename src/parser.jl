function openGamesFile(games_file_name)
    games = readdlm(games_file_name, ',')
    return games
end

function filterGames(games_list)
    games = []
    for i = 2:size(games_list)[1]
        winner = games_list[i, 7]
        victory = games_list[i, 6]

        if winner == "white" && victory == "mate"
            push!(games, games_list[i, 13])
        end
    end

    return games
end

function parseGame(game)
    moves = split(game, ' ')

    return moves
end

function encodeToLabels(labels)
    new_labels = []

    files = Dict('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8)
    ranks = Dict('1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8)
    pieces_labels = Dict('P' => 1, 'R' => 2, 'N' => 3, 'B' => 4, 'Q' => 5, 'K' => 6)

    for label in labels
        move = zeros(Int64, 8)
        move = encodeToLabel(label, files, ranks, pieces_labels, move)
        push!(new_labels, move)
    end

    return new_labels
end

"Parse a PGN move (label) and encode in 8 digit number

P f1 #1 x f2 #2 + =

P: piece can be pawn, rook, knight, bishop, queen, king = {1, ..., 6}
f1: starting file = {a, ..., h}
#1: starting rank = {1, ..., 8}. These two are used only to handle ambiguity
x: take or not = {1, 0}
f2: landing file
#2: landing rank
+: check or not = {1, 0}
=: promote pawn to rook, knight, bishop, queen = {2, 5}
"
function encodeToLabel(label, files, ranks, pieces_labels, move)
    # handle checks
    if '+' in label
        move[7] = 1
        label = label[1:end-1]
    end

    # first, handle castling and pawn promotion
    if label == "O-O"
        move[1] = pieces_labels['K']
        move[2] = files['e']
        move[3] = ranks['1']
        move[5] = files['g']
        move[6] = ranks['1']
        return move

    elseif label == "O-O-O"
        move[1] = pieces_labels['K']
        move[2] = files['e']
        move[3] = ranks['1']
        move[5] = files['c']
        move[6] = ranks['1']
        return move

    elseif '=' in label
        move[1] = 1
        move[8] = pieces_labels[label[end]]
        label = label[1:end-2]
    end

    l = length(label)

    if l == 2 # move pawn
        move[1] = 1
        move[5] = files[label[1]]
        move[6] = ranks[label[2]]
        return move

    elseif l == 3 # move other piece
        move[1] = pieces_labels[label[1]]
        move[5] = files[label[2]]
        move[6] = ranks[label[3]]
        return move

    elseif l >= 4 && 'x' in label # taking move
        move[4] = 1

        if label[1] in files.keys # pawn takes
            move[1] = 1
            move[2] = files[label[1]]

            if label[2] == 'x'
                move[5] = files[label[3]]
                move[6] = ranks[label[4]]
                return move

            else
                move[3] = ranks[label[2]]
                move[5] = files[label[4]]
                move[6] = ranks[label[5]]
                return move
            end

        else # other piece takes
            move[1] = pieces_labels[label[1]]

            if label[2] == 'x'
                move[5] = files[label[3]]
                move[6] = ranks[label[4]]
                return move

            else
                if label[2] in files.keys
                    move[2] = files[label[2]]

                    if label[3] in ranks.keys
                        move[3] = ranks[label[3]]
                        move[5] = files[label[5]]
                        move[6] = ranks[label[6]]
                        return move

                    else # label[3] ==  'x'
                        move[5] = files[label[4]]
                        move[6] = ranks[label[5]]
                        return move
                    end

                else
                    move[3] = ranks[label[2]]
                    move[5] = files[label[4]]
                    move[6] = ranks[label[5]]
                    return move
                end
            end
        end

    elseif l == 4 && ('x' in label) == false # move other piece ambiguity
        move[1] = pieces_labels[label[1]]

        if label[2] in files.keys
            move[2] = files[label[2]]
            move[5] = files[label[3]]
            move[6] = ranks[label[4]]
            return move

        elseif label[2] in ranks.keys
            move[3] = ranks[label[2]]
            move[5] = files[label[3]]
            move[6] = ranks[label[4]]
            return move
        end

    # super ambiguity, both starting rank and file are specified
    elseif l > 4 && ('x' in label) == false
        move[1] = pieces_labels[label[1]]
        move[2] = files[label[2]]
        move[3] = ranks[label[3]]
        move[5] = files[label[4]]
        move[6] = ranks[label[5]]
        return move
    end
end

function decodeToMoves(moves)
    new_labels = []
    files_inv = Dict(0 => "", 1 => "a", 2 => "b", 3 => "c", 4 => "d", 5 => "e", 6 => "f", 7 => "g", 8 => "h")
    ranks_inv = Dict(0 => "", 1 => "1", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7", 8 => "8")
    pieces_labels_inv = Dict(1 => "", 2 => "R", 3 => "N", 4 => "B", 5 => "Q", 6 => "K")

    for move in moves
        label = ""
        label = decodeToMove(move, files_inv, ranks_inv, pieces_labels_inv, label)
        push!(new_labels, label)
    end

    return new_labels
end

function decodeToMove(move, files_inv, ranks_inv, pieces_labels_inv, label)
    P  = move[1]
    f1 = move[2]
    r1 = move[3]
    x  = move[4]
    f2 = move[5]
    r2 = move[6]
    c  = move[7]
    p  = move[8]

    label *= pieces_labels_inv[P] # piece
    label *= files_inv[f1] # starting file (ambiguity)
    label *= ranks_inv[r1] # starting rank

    # take piece?
    if x == 1
        label *= "x"
    end

    # landing file and rank
    label *= files_inv[f2]
    label *= ranks_inv[r2]

    # promotion?
    if p != 0
        label *= "="
        label *= pieces_labels_inv[p]
    end

    # castling?
    if label == "Ke1g1"
        label = "O-O"

    elseif label == "Ke1c1"
        label = "O-O-O"
    end

    # check?
    if c == 1
        label *= "+"
    end

    return label
end
