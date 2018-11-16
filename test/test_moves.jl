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
	r = [0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0]
	rv = Bobby.getRooksValid(b, "black")
	@test all(Int.(rv) .== r)

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