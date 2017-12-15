using Bobby
using FileIO

# create empty chessboard if not in the current path
if isfile("chessboard.png") == false
    Bobby.drawEmptyBoard()
end
board = load("chessboard.png")

# load pieces
pieces = Bobby.loadPieces()

# set up pieces on board
b = Bobby.buildBoard()

#-----------------------------------------------------------------------------------------

# load games
games_list = Bobby.openGamesFile("games.csv")
filter_games = Bobby.filterGames(games_list)

labels = []
i = 1
for k = 1:length(filter_games)
    game = filter_games[k]

    moves = Bobby.parseGame(game)

    for j = 1:length(moves)

        b = Bobby.buildBoard()
        p_board = copy(board)

        if j == 1
            pgn_list = b
            label = moves[1]

        elseif iseven(j)
            partial_moves = moves[1:j]
            pgn_list = Bobby.makeMoves(b, partial_moves)
            label = moves[j+1]

        else
            continue
        end

        push!(labels, label)


        # convert moves
        fen_string = Bobby.boardToStrings(pgn_list)

        # save png image
        scheme = Bobby.cleanRows(fen_string)
        img_board = Bobby.drawScheme(p_board, scheme, pieces)
        save("schemes/$i-$label.png", img_board)
        i += 1
    end
end

labels_file = open("moves.txt", "w")
for l in labels
    write(labels_file, "$l\n")
end
close(labels_file)
