@testset "pgn parser" begin

    @test_throws DomainError Bobby.pgn2int("e")
    @test_throws DomainError Bobby.pgn2int("e11")
    @test_throws ArgumentError Bobby.pgn2int("ee")
    @test_throws DomainError Bobby.pgn2int("11")
    @test_throws DomainError Bobby.pgn2int("k1")

    @test Bobby.pgn2int("a8") == 1
    @test Bobby.pgn2int("h1") == 64
    @test Bobby.pgn2int("h8") == 8
    @test Bobby.pgn2int("a1") == 57

    b = Bobby.buildBoard()
    l = Bobby.buildLookUpTables()
    @test Bobby.int2piece(b, 1) == 'r'
    @test Bobby.int2piece(b, 2) == 'n'
    @test Bobby.int2piece(b, 3) == 'b'
    @test Bobby.int2piece(b, 4) == 'q'
    @test Bobby.int2piece(b, 5) == 'k'
    @test Bobby.int2piece(b, 9) == 'p'
    @test Bobby.int2piece(b, 17) == ' '
    @test Bobby.int2piece(b, 64) == 'R'
    @test Bobby.int2piece(b, 63) == 'N'
    @test Bobby.int2piece(b, 62) == 'B'
    @test Bobby.int2piece(b, 61) == 'K'
    @test Bobby.int2piece(b, 60) == 'Q'
    @test Bobby.int2piece(b, 56) == 'P'

    @test_throws ErrorException Bobby.checkColor('P', "black")
    @test_throws ErrorException Bobby.checkColor('p', "white")

    valid_moves = Bobby.getPawnsValid(b, l)
    @test_throws DomainError Bobby.checkTarget(1, valid_moves)
    valid_moves = Bobby.getPawnsValid(b, l, "black")
    @test_throws DomainError Bobby.checkTarget(64, valid_moves)

    @test_throws DomainError Bobby.checkSource(35, b)

    color = "white"
    opponent_color = "black"
    c, oc = Bobby.changeColor(color, opponent_color)
    @test color == oc
    @test opponent_color == c
end

@testset "game" begin
    b = Bobby.buildBoard()
    l = Bobby.buildLookUpTables()

    # move pawn
    b, e = Bobby.move(b, l, "e2", "e4")
    @test e == ""

    # move knight
    b, e = Bobby.move(b, l, "b8", "c6", "black")
    @test e == ""

    # move king
    b, e = Bobby.move(b, l, "e1", "e2")
    @test e == ""
    @test b.white_king_moved

    # move rook
    b, e = Bobby.move(b, l, "a8", "b8", "black")
    @test e == ""
    @test b.a8_rook_moved

    # move queen
    b, e = Bobby.move(b, l, "d1", "e1")
    @test e == ""

    #move bishop
    b, e = Bobby.move(b, l, "g2", "g3")
    b, e = Bobby.move(b, l, "f1", "g2")
    @test e == ""
end