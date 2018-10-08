l = Bobby.buildLookUpTables()

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
@test all(Int.(kv) .== n33)