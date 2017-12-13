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
