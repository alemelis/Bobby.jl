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
end
