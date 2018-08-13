white_pawns = Bobby.setPawns()
@test all(white_pawns[57:end] .== false)
@test all(white_pawns[49:56] .== true)

black_pawns = Bobby.setPawns("black")
@test all(black_pawns[1:8] .== false)
@test all(black_pawns[9:16] .== true)

white_rooks = Bobby.setRooks()
@test white_rooks[57] == true
@test white_rooks[64] == true

black_rooks = Bobby.setRooks("black")
@test black_rooks[1] == true
@test black_rooks[8] == true

white_knights = Bobby.setNights()
@test white_knights[58] == true
@test white_knights[63] == true

black_knights = Bobby.setNights("black")
@test black_knights[7] == true
@test black_knights[2] == true

white_bishops = Bobby.setBishops()
@test white_bishops[59] == true
@test white_bishops[62] == true

black_bishops = Bobby.setBishops("black")
@test black_bishops[6] == true
@test black_bishops[3] == true

white_king = Bobby.setKing()
@test white_king[61] == true

black_king = Bobby.setKing("black")
@test black_king[5] == true

white_queen = Bobby.setQueen()
@test white_queen[60] == true

black_queen = Bobby.setQueen("black")
@test black_queen[4] == true

board = Bobby.buildBoard()
@test all(board.P .== white_pawns)
@test all(board.R .== white_rooks)
@test all(board.N .== white_knights)
@test all(board.B .== white_bishops)
@test all(board.K .== white_king)
@test all(board.Q .== white_queen)
@test all(board.white[49:end] .== true)

@test all(board.p .== black_pawns)
@test all(board.r .== black_rooks)
@test all(board.n .== black_knights)
@test all(board.b .== black_bishops)
@test all(board.k .== black_king)
@test all(board.q .== black_queen)
@test all(board.black[1:16] .== true)