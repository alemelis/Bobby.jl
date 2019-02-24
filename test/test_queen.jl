@testset "queen" begin
    bb = Bobby.fen_to_bitboard(
      "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R")
    
    qv = [0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,1,0,0,
          0,0,0,0,0,1,0,1,
          0,0,0,0,0,1,1,0,
          0,0,0,1,1,0,1,1,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0]
    qvw = Bobby.get_queen_valid(bb)
    @test all(Int.(Bobby.cvt_to_bitarray(qvw)) .== qv)
    qvl = Bobby.get_sliding_pieces_valid_list(bb, "queen")
    @test length(qvl) == 9

    qv = [0,0,0,1,0,1,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,1,0,0,0,0,
          0,0,1,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0]
    qvb = Bobby.get_queen_valid(bb, "black")
    @test all(Int.(Bobby.cvt_to_bitarray(qvb)) .== qv)
    qvl = Bobby.get_sliding_pieces_valid_list(bb, "queen", "black")
    @test length(qvl) == 4
end