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

function parseLabels(labels)
    new_labels = []

    files = Dict('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6, 'g' => 7, 'h' => 8)
    ranks = Dict('1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8)
    pieces_labels = Dict('P' => 1, 'R' => 2, 'N' => 3, 'B' => 4, 'Q' => 5, 'K' => 6)

    for label in labels
        move = zeros(Int64, 6)
        try

            move = parseLabel(label, pieces_labels, ranks, files, move)
            push!(new_labels, move)
        catch
            println(label)
        end
        #
        #     error(e)
        # end

    end

    return new_labels
end

function parseLabel(label, pieces_labels, ranks, files, move)

    # don't care about checks
    if '+' in label
        label = label[1:end-1]
    end

    l = length(label)

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
        move[4] = pieces_labels[label[end]]

        if l == 6
            move[2] = files[label[1]]
            move[5] = files[label[3]]
            move[6] = ranks[label[4]]
            return move

        else
            move[5] = files[label[1]]
            move[6] = ranks[label[2]]
            return move
        end
    end



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
            move[4] = ranks[label[2]]
            move[5] = files[label[3]]
            move[6] = ranks[label[4]]
            return move
        end
    end
end
