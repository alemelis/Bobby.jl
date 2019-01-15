@testset "bitboard" begin
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

    white = Bobby.setSide(white_pawns, white_rooks,
        white_knights, white_bishops, white_queen, white_king)
    @test all(white[49:end] .== true)

    black = Bobby.setSide(black_pawns, black_rooks,
        black_knights, black_bishops, black_queen, black_king)
    @test all(black[1:16] .== true)

    free = Bobby.setFree(white, black)
    @test all(free[.~white .& .~black] .== true)

    taken = Bobby.setTaken(free)
    @test all(taken[.~free] .== true)
    @test all(taken[free] .== false)

    board = Bobby.buildBoard()
    @test all(board.P .== white_pawns)
    @test all(board.R .== white_rooks)
    @test all(board.N .== white_knights)
    @test all(board.B .== white_bishops)
    @test all(board.K .== white_king)
    @test all(board.Q .== white_queen)
    @test all(board.white .== white)

    @test all(board.p .== black_pawns)
    @test all(board.r .== black_rooks)
    @test all(board.n .== black_knights)
    @test all(board.b .== black_bishops)
    @test all(board.k .== black_king)
    @test all(board.q .== black_queen)
    @test all(board.black .== black)

    @test all(board.free[board.white] .== false)
    @test all(board.free[board.black] .== false)
    @test all(board.free .== free)
    @test all(board.taken .== taken)

    @test all(board.white_attacks[41:48] .== true)
    @test all(board.black_attacks[17:24] .== true)
    @test all(board.white_attacks[17:24] .== false)
    @test all(board.black_attacks[41:48] .== false)
end

@testset "look up tables" begin
    clear_rank = Bobby.setClearRank()
    clear_rank1 = [1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0]
    clear_rank8 = [0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1]
    @test clear_rank[:,1] != clear_rank[:,end]
    @test Int.(clear_rank[:,1]) == clear_rank1
    @test Int.(clear_rank[:,8]) == clear_rank8

    clear_file = Bobby.setClearFile()
    clear_fileA = [0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1]
    clear_fileH = [1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0,
    1,1,1,1,1,1,1,0]
    @test clear_file[:,1] != clear_file[:,end]
    @test Int.(clear_file[:,1]) == clear_fileA
    @test Int.(clear_file[:,8]) == clear_fileH

    mask_rank = Bobby.setMaskRank()
    mask_rank1 = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1]
    mask_rank8 = [1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    @test mask_rank[:,1] != mask_rank[:,end]
    @test Int.(mask_rank[:,1]) == mask_rank1
    @test Int.(mask_rank[:,8]) == mask_rank8

    mask_file = Bobby.setMaskFile()
    mask_fileA = [1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0]
    mask_fileH = [0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,0,1]
    @test mask_file[:,1] != mask_file[:,end]
    @test Int.(mask_file[:,1]) == mask_fileA
    @test Int.(mask_file[:,8]) == mask_fileH

    lookUpTables = Bobby.buildLookUpTables()
    @test Int.(lookUpTables.clear_rank[:,1]) == clear_rank1
    @test Int.(lookUpTables.clear_rank[:,8]) == clear_rank8
    @test Int.(lookUpTables.clear_file[:,1]) == clear_fileA
    @test Int.(lookUpTables.clear_file[:,8]) == clear_fileH
    @test Int.(lookUpTables.mask_rank[:,1]) == mask_rank1
    @test Int.(lookUpTables.mask_rank[:,8]) == mask_rank8
    @test Int.(lookUpTables.mask_file[:,1]) == mask_fileA
    @test Int.(lookUpTables.mask_file[:,8]) == mask_fileH
end