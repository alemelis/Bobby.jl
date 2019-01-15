l = Bobby.buildLookUpTables()

@testset "king" begin
    # test white king on the middle
    b = Bobby.buildBoard()
    b.K = falses(64)
    b.K[35] = true
    b.white[35] = true
    b.white[61] = false
    king35 = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,1,1,0,0,0,0,
    0,1,0,1,0,0,0,0,
    0,1,1,1,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    kv = Bobby.getKingValid(b, l)
    @test all(Int.(kv) .== king35)

    # test white king on upper left corner (A file tested as well)
    b = Bobby.buildBoard()
    b.K = falses(64)
    b.K[1] = true
    b.white[1] = true
    b.white[61] = false
    king1 = [0,1,0,0,0,0,0,0,
    1,1,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    kv = Bobby.getKingValid(b, l)
    @test all(Int.(kv) .== king1)

    # test black king on lower right corner (H file tested as well)
    b = Bobby.buildBoard()
    b.k = falses(64)
    b.k[64] = true
    b.black[64] = true
    b.black[5] = false
    king8 = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,1,1,
    0,0,0,0,0,0,1,0]
    kv = Bobby.getKingValid(b, l, "black")
    @test all(Int.(kv) .== king8)
end

@testset "knights" begin
    # test white knigth
    b = Bobby.buildBoard()
    b.N = falses(64)
    b.N[34] = true
    b.black = falses(64)
    b.white = Bool.([0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,0,1,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    0,0,0,1,0,0,0,0])
    n33 = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,0,1,0,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,1,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    n = Bobby.getNightsValid(b, l)
    @test all(Int.(n) .== n33)

    # test black knight
    b = Bobby.buildBoard()
    b.n = falses(64)
    b.n[36] = true
    b.white = falses(64)
    b.black = Bool.([0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,1,0,0,0,0,0,
    0,0,1,0,1,1,0,0,
    0,0,0,1,0,1,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0])
    n36 = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,1,0,0,0,
    0,1,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,0,0,0,1,0,0,
    0,0,1,0,1,0,0,0,
    0,0,0,0,0,0,0,0]
    n = Bobby.getNightsValid(b, l, "black")
    @test all(Int.(n) .== n36)
end

@testset "rooks" begin
    b = Bobby.buildBoard()
    R = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Rv = Bobby.getRooksValid(b)
    @test all(Int.(Rv) .== R)

    rv = Bobby.getRooksValid(b, "black")
    @test all(Int.(rv) .== R)

    b.white[36] = true
    b.R[36] = true
    R = [0,0,0,0,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,0,1,0,0,0,0,
    1,1,1,0,1,1,1,1,
    0,0,0,1,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Rv = Bobby.getRooksValid(b)
    @test all(Int.(Rv) .== R)

    b.white[37] = true
    b.R[37] = true
    R = [0,0,0,0,0,0,0,0,
    0,0,0,1,1,0,0,0,
    0,0,0,1,1,0,0,0,
    0,0,0,1,1,0,0,0,
    1,1,1,0,0,1,1,1,
    0,0,0,1,1,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Rv = Bobby.getRooksValid(b)
    @test all(Int.(Rv) .== R)

    b.white[37] = false
    b.R[37] = false
    b.white[46] = true
    b.R[46] = true
    R = [0,0,0,0,0,0,0,0,
    0,0,0,1,0,1,0,0,
    0,0,0,1,0,1,0,0,
    0,0,0,1,0,1,0,0,
    1,1,1,0,1,1,1,1,
    1,1,1,1,1,0,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Rv = Bobby.getRooksValid(b)
    @test all(Int.(Rv) .== R)

    # black rooks
    b = Bobby.buildBoard()
    b.black[36] = true
    b.r[36] = true
    r = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,0,1,0,0,0,0,
    1,1,1,0,1,1,1,1,
    0,0,0,1,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,0,0,0,0,0,0]
    rv = Bobby.getRooksValid(b, "black")
    @test all(Int.(rv) .== r)

    b.black[37] = true
    b.r[37] = true
    r = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,1,0,0,0,
    0,0,0,1,1,0,0,0,
    1,1,1,0,0,1,1,1,
    0,0,0,1,1,0,0,0,
    0,0,0,1,1,0,0,0,
    0,0,0,0,0,0,0,0]
    rv = Bobby.getRooksValid(b, "black")
    @test all(Int.(rv) .== r)

    b.black[37] = false
    b.r[37] = false
    b.black[46] = true
    b.r[46] = true
    r = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,0,1,0,0,
    0,0,0,1,0,1,0,0,
    1,1,1,0,1,1,1,1,
    1,1,1,1,1,0,1,1,
    0,0,0,1,0,1,0,0,
    0,0,0,0,0,0,0,0]
    rv = Bobby.getRooksValid(b, "black")
    @test all(Int.(rv) .== r)
end


@testset "bishops" begin
    b = Bobby.buildBoard()
    B = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l)
    @test all(Int.(Bv) .== B)

    Bv = Bobby.getBishopsValid(b, l, "black")
    @test all(Int.(Bv) .== B)

    i = 37
    b.white[i] = true
    b.B[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,1,0,0,0,0,0,1,
    0,0,1,0,0,0,1,0,
    0,0,0,1,0,1,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,0,1,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l)
    @test all(Int.(Bv) .== B)

    i = 38
    b.white[i] = true
    b.B[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,1,1,0,0,0,0,1,
    0,0,1,1,0,0,1,1,
    0,0,0,1,1,1,1,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,1,1,1,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l)
    @test all(Int.(Bv) .== B)

    i = 44
    b.white[i] = true
    b.B[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,1,1,0,0,0,0,1,
    1,0,1,1,0,0,1,1,
    0,1,0,1,1,1,1,0,
    0,0,1,0,0,0,0,0,
    0,0,0,0,1,1,1,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l)
    @test all(Int.(Bv) .== B)

    b = Bobby.buildBoard()
    i = 41
    b.black[i] = true
    b.b[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,0,0,0,0,
    0,0,1,0,0,0,0,0,
    0,1,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l, "black")
    @test all(Int.(Bv) .== B)

    i = 42
    b.black[i] = true
    b.b[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,1,0,0,0,
    0,0,1,1,0,0,0,0,
    1,1,1,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l, "black")
    @test all(Int.(Bv) .== B)

    i = 32
    b.black[i] = true
    b.b[i] = true
    B = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,1,1,0,1,0,
    0,0,1,1,0,0,0,0,
    1,1,1,0,0,0,1,0,
    0,0,0,0,0,1,0,0,
    1,1,1,0,1,0,0,0,
    0,0,0,0,0,0,0,0]
    Bv = Bobby.getBishopsValid(b, l, "black")
    @test all(Int.(Bv) .== B)
end

@testset "queen" begin
    b = Bobby.buildBoard()
    Q = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Qv = Bobby.getQueenValid(b, l)
    @test all(Int.(Qv) .== Q)

    Qv = Bobby.getQueenValid(b, l, "black")
    @test all(Int.(Qv) .== Q)

    i = 37
    b.white[i] = true
    b.Q[i] = true
    Q = [0,0,0,0,0,0,0,0,
    0,1,0,0,1,0,0,1,
    0,0,1,0,1,0,1,0,
    0,0,0,1,1,1,0,0,
    1,1,1,1,0,1,1,1,
    0,0,0,1,1,1,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Qv = Bobby.getQueenValid(b, l)
    @test all(Int.(Qv) .== Q)

    i = 35
    b.white[i] = true
    b.Q[i] = true
    Q = [0,0,0,0,0,0,0,0,
    0,1,1,0,1,1,0,1,
    1,0,1,0,1,0,1,0,
    0,1,1,1,1,1,0,0,
    1,1,0,1,0,1,1,1,
    0,1,1,1,1,1,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Qv = Bobby.getQueenValid(b, l)
    @test all(Int.(Qv) .== Q)

    b = Bobby.buildBoard()
    Q = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,1,
    0,0,0,0,0,0,1,0,
    0,0,0,0,0,1,0,0,
    0,0,0,0,1,0,0,0,
    0,0,0,0,0,0,0,0]
    b.P[45] = true
    b.taken[45] = true
    b.free[45] = false
    b.taken[53] = false
    b.free[53] = true
    b.white[53] = false
    b.white[45] = true
    Qv = Bobby.getQueenValid(b, l)
    @test all(Int.(Qv) .== Q)

    b = Bobby.buildBoard()
    Q = [0,0,0,0,0,0,0,0,
    0,0,1,0,0,0,0,0,
    0,1,0,0,0,0,0,0,
    1,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    b.p[11] = false
    b.p[19] = true
    b.taken[19] = true
    b.free[19] = false
    b.taken[11] = false
    b.free[11] = true
    b.black[11] = false
    b.black[19] = true
    Qv = Bobby.getQueenValid(b, l, "black")
    @test all(Int.(Qv) .== Q)
end

@testset "pawns" begin
    b = Bobby.buildBoard()
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l)
    @test all(Int.(Pv) .== P)

    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l, "black")
    @test all(Int.(Pv) .== P)

    i = 41
    b.taken[i] = true
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l)
    @test all(Int.(Pv) .== P)

    i = 34
    b.taken[i] = true
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,1,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l)
    @test all(Int.(Pv) .== P)

    i = 35
    b.P[i] = true
    b.taken[i] = true
    b.white[i] = true
    j = 26
    b.taken[j] = true
    b.black[j] = true
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,1,1,0,0,0,0,0,
    0,0,0,1,1,1,1,1,
    0,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l)
    @test all(Int.(Pv) .== P)

    b = Bobby.buildBoard()
    i = 20
    b.black[i] = true
    b.taken[i] = true
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,0,1,1,1,1,
    1,1,1,0,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l, "black")
    @test all(Int.(Pv) .== P)

    i = 21
    b.white[i] = true
    b.taken[i] = true
    P = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,0,1,1,1,1,
    1,1,1,0,0,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    Pv = Bobby.getPawnsValid(b, l, "black")
    @test all(Int.(Pv) .== P)

end

@testset "attacked squares" begin
    b = Bobby.buildBoard()

    A = Bobby.getAttacked(b, l)
    a = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    @test all(Int.(A) .== a)

    Aa = Bobby.getAttacked(b, l, "black")
    aa = [0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0]
    @test all(Int.(Aa) .== aa)
end