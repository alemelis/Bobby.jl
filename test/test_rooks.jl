@testset "rooks" begin    
    mr = Bobby.gen_rook_mask(1)
    mask = [0,1,1,1,1,1,1,0,
            1,0,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,
            1,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(mr)) .== mask)

    mr = Bobby.gen_rook_mask(2)
    mask = [0,0,1,1,1,1,1,0,
            0,1,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
            0,1,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(mr)) .== mask)

    mr = Bobby.gen_rook_mask(3)
    mask = [0,1,0,1,1,1,1,0,
            0,0,1,0,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,1,0,0,0,0,0,
            0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(mr)) .== mask)

    mr = Bobby.gen_rook_mask(45)
    mask = [0,0,0,0,0,0,0,0,
            0,0,0,0,1,0,0,0,
            0,0,0,0,1,0,0,0,
            0,0,0,0,1,0,0,0,
            0,0,0,0,1,0,0,0,
            0,1,1,1,0,1,1,0,
            0,0,0,0,1,0,0,0,
            0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(mr)) .== mask)

    rook_mask_dict = Bobby.gen_rook_masks()
    @test mr == rook_mask_dict[Bobby.INT2UINT[45]]

    bb = Bobby.fen_to_bitboard("r1r4k/5ppp/p7/3p4/P1pN1Nb1/2R2nPP/1PP5/4QK2")
    rook_occupancy = Bobby.ROOK_MASKS[Bobby.INT2UINT[43]] & bb.taken
    ro = [0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,1,0,0,0,0,0,
          0,0,0,0,0,1,1,0,
          0,0,1,0,0,0,0,0,
          0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(rook_occupancy)) .== ro)
end