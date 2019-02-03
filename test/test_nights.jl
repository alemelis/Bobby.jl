@testset "knights" begin
    b = Bobby.set_board()
    
    nv = Bobby.gen_night_valid(Bobby.INT2UINT[58])
    @test length(nv) == 3
    nvw = [0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           1,0,1,0,0,0,0,0,
           0,0,0,1,0,0,0,0,
           0,0,0,0,0,0,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(nv)) .== nvw)

    
    anv = Bobby.gen_all_night_valid_moves()
    @test all(Int.(Bobby.cvt_to_bitarray(anv[Bobby.INT2UINT[58]])) .== nvw)

    nvw = [0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           1,0,1,0,0,1,0,1,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0]
    cnv = Bobby.get_current_nights_valid(b)
    @test length(cnv) == 4
    n = Bobby.EMPTY
    for m in cnv
        n |= m[2]
    end
    @test all(Int.(Bobby.cvt_to_bitarray(n)) .== nvw)
end