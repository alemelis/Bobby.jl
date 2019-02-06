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
end