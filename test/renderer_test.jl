Bobby.drawBoard();
@test isfile("chessboard.png")
rm("chessboard.png")

Bobby.drawBoard(board_name = "chessb");
@test isfile("chessb.png")
rm("chessb.png")

Bobby.drawBoard(board_name = "chessb", fmt = "SVG");
@test isfile("chessb.svg")
rm("chessb.svg")

Bobby.drawBoard(board_name = "chessb", fmt = "SVG", b_clr = "tomato", w_clr = "bisque");
@test isfile("chessb.svg")
rm("chessb.svg")
