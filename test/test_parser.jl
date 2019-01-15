@testset "bitboard" begin
	i = Bobby.binary_string_to_int(
		"0000000000000000000000000000000000000000000000000000000000000001")
	@test i == 0x0000000000000001

	s = Bobby.uint_to_binary_string(0x0000000000000001)
	@test s == "0000000000000000000000000000000000000000000000000000000000000001"

	s = Bobby.int_to_binary_string(1)
	@test s == "0000000000000000000000000000000000000000000000000000000000000001"

	b = Bobby.fen_to_bitboard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    @test b.free == ~b.taken

    @test_throws ArgumentError Bobby.fen_to_bitboard(
    	"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN")
end