function test_fen(fen, result)
	b = Bobby.fen_to_bitboard(fen)
    pt = Bobby.perft(b, 1, b.player_color)
    if pt == result
    	return true
    else
    	return false
    end
end

@testset "check" begin
    b = Bobby.set_board()

    @test !Bobby.king_in_check(b)
    @test !Bobby.king_in_check(b, "black")

    @test test_fen("k7/8/8/8/8/8/5PPP/r6K w KQkq - 0 1", [0])
    @test test_fen("k7/8/8/8/8/8/5PPP/rq5K w KQkq - 0 1", [0])
    @test test_fen("k7/8/8/8/8/8/5PPP/rq5K w KQkq - 0 1", [0])
    @test test_fen("k7/8/8/8/8/6Pb/5PqP/5rRK w KQkq - 0 1", [0])
end