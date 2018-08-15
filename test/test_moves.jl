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

# test white king on A file
b = Bobby.buildBoard()
b.K = falses(64)
b.K[33] = true
b.white[33] = true
b.white[61] = false
king33 = [0,0,0,0,0,0,0,0,
		  0,0,0,0,0,0,0,0,
		  0,0,0,0,0,0,0,0,
		  1,1,0,0,0,0,0,0,
		  0,1,0,0,0,0,0,0,
		  1,1,0,0,0,0,0,0,
		  0,0,0,0,0,0,0,0,
		  0,0,0,0,0,0,0,0]
kv = Bobby.getKingValid(b, l)
@test all(Int.(kv) .== king33)

# test white king on upper left corner
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

# test black king on upper right corner (H file as well)
b = Bobby.buildBoard()
b.k = falses(64)
b.k[8] = true
b.black[8] = true
b.black[5] = false
king8 = [0,0,0,0,0,0,1,0,
		 0,0,0,0,0,0,1,1,
		 0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0,
		 0,0,0,0,0,0,0,0]
kv = Bobby.getKingValid(b, l, "black")
@test all(Int.(kv) .== king8)