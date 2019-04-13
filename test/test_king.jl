@testset "king" begin
    b = Bobby.set_board()
    
    kv = Bobby.gen_king_valid(Bobby.INT2UINT[61])
    @test length(kv) == 5
    kvw = [0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,1,1,1,0,0,
           0,0,0,1,0,1,0,0]
    @test all(Int.(Bobby.cvt_to_bitarray(kv)) .== kvw)

    
    akv = Bobby.gen_all_king_valid_moves()
    @test all(Int.(Bobby.cvt_to_bitarray(akv[Bobby.INT2UINT[61]])) .== kvw)
end
