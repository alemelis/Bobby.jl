@testset "bishops" begin
    # bb = Bobby.set_board()
    
    # bv = [0,0,0,0,0,0,0,0,
    #       0,0,0,0,0,0,0,0,
    #       1,0,0,0,0,0,0,1,
    #       0,1,0,0,0,0,1,0,
    #       0,0,1,0,0,1,0,0,
    #       0,0,0,1,1,0,0,0,
    #       0,0,0,0,0,0,0,0,
    #       0,0,1,1,0,1,0,0]
    # bvw = Bobby.get_bishops_valid(bb)
    # @test all(Int.(Bobby.cvt_to_bitarray(bvw)) .== bv)
    # qvl = Bobby.get_sliding_pieces_valid_list(bb, "bishop")
    # @test length(qvl) == 11

    # bv = [0,0,1,0,0,1,0,0,
    #       0,1,0,0,0,0,0,0,
    #       0,0,0,0,0,0,0,1,
    #       0,1,0,0,0,0,0,0,
    #       0,0,1,0,0,0,0,0,
    #       0,0,0,1,0,0,0,0,
    #       0,0,0,0,1,0,0,0,
    #       0,0,0,0,0,0,0,0]
    # bvb = Bobby.get_bishops_valid(bb, "black")
    # @test all(Int.(Bobby.cvt_to_bitarray(bvb)) .== bv)
    # qvl = Bobby.get_sliding_pieces_valid_list(bb, "bishop", "black")
    # @test length(qvl) == 8
end