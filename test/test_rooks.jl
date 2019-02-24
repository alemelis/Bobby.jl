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

    bb = Bobby.fen_to_bitboard("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8")
    rv = [0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          1,0,1,1,1,1,0,0,
          0,1,0,0,0,0,0,0,
          0,1,0,0,0,0,0,0,
          0,1,0,0,0,0,0,0]
    rvw = Bobby.get_rooks_valid(bb)
    @test all(Int.(Bobby.cvt_to_bitarray(rvw)) .== rv)

    rv = [0,0,0,0,0,0,0,1,
          0,0,0,0,0,0,0,1,
          0,0,0,0,0,0,0,1,
          0,1,1,1,1,1,1,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0]
    rvb = Bobby.get_rooks_valid(bb, "black")
    @test all(Int.(Bobby.cvt_to_bitarray(rvb)) .== rv)
end