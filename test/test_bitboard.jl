white_pawns = Bobby.setPawns()
@test white_pawns[57:end] .== false
@test white_pawns[49:56] .== true

# A = zeros(Int8, 64)
# B = zeros(Int8, 64)
# A[49:56] .= 1

# function intest(A, B)
# 	C = zeros(Int8, 64)
# 	for i=1:64
# 		if A[i] != B[i]
# 			C[i] = 1
# 		end
# 	end
# 	return C
# end

# @benchmark intest(A, B)

# a = falses(64)
# b = falses(64)
# a[49:56] .= true

# @benchmark .~(a.|b)


# function bitest(a, b)
# 	c = falses(64)
# 	for i=1:64
# 		if a[i] != b[i]
# 			c[i] = true
# 		end
# 	end
# 	return c
# end

# @benchmark bitest(a, b)

# function and(a, b)
# 	c = falses(length(a))
# 	for i=1:length(a)
# 		if a[i] == b[i] & a[i] == true
# 			c[i] = true
# 		end
# 	end
# 	return c
# end

# function or(a, b)
# 	c = falses(length(a))
# 	for i=1:length(a)
# 		if a[i] | b[i]
# 			c[i] = true
# 		end
# 	end
# 	return c
# end

# transpose(reshape(a, 8, :))