"""
	Bitboard

Bitboard mutable structure.
"""
mutable struct Bitboard
	white :: BitArray{1} # all white pieces
	P :: BitArray{1}
	R :: BitArray{1}
	N :: BitArray{1}
	B :: BitArray{1}
	Q :: BitArray{1}
	K :: BitArray{1}

	black :: BitArray{1} # all black pieces
	p :: BitArray{1}
	r :: BitArray{1}
	n :: BitArray{1}
	b :: BitArray{1}
	q :: BitArray{1}
	k :: BitArray{1}

	free :: BitArray{1}  # all free squares
	taken :: BitArray{1} # all pieces
end


"""
	buildBoard()

Bitboard structure constructor.
"""
function buildBoard()
	P = setPawns()
	p = setPawns("black")

	R = setRooks()
	r = setRooks("black")

	N = setNights()
	n = setNights("black")

	B = setBishops()
	b = setBishops("black")

	K = setKing()
	k = setKing("black")

	Q = setQueen()
	q = setQueen("black")

	white = setSide(P, R, N, B, K, Q)
	black = setSide(p, r, n, b, k, q)

	free = setFree(white, black)
	taken = setTaken(free)

	return Bitboard(white, P, R, N, B, Q, K, black,
					p, r, n, b, q, k, free, taken)
end


"""
	setPawns(color::String="white")

Constructor function for pawns.
"""
function setPawns(color::String="white")
	pawns = falses(64)
	if color == "white"
		for i = 49:56
			pawns[i] = true
		end
	else
		for i = 9:16
			pawns[i] = true
		end
	end
	return pawns
end


"""
	setRooks(color::String="white")

Constructor function for rooks.
"""
function setRooks(color::String="white")
	rooks = falses(64)
	if color == "white"
		rooks[57] = true
		rooks[64] = true
	else
		rooks[1] = true
		rooks[8] = true
	end
	return rooks
end


"""
	setNights(color::String="white")

Constructor function for (k)nights.
"""
function setNights(color::String="white")
	knights = falses(64)
	if color == "white"
		knights[58] = true
		knights[63] = true
	else
		knights[2] = true
		knights[7] = true
	end
	return knights
end


"""
	setBishops(color::String="white")

Constructor function for bishops.
"""
function setBishops(color::String="white")
	bishops = falses(64)
	if color == "white"
		bishops[59] = true
		bishops[62] = true
	else
		bishops[3] = true
		bishops[6] = true
	end
	return bishops
end


"""
	setKing(color::String="white")

Constructor function for king.
"""
function setKing(color::String="white")
	king = falses(64)
	if color == "white"
		king[61] = true
	else
		king[5] = true
	end
	return king
end


"""
	setQueen(color::String="white")

Constructor function for queen.
"""
function setQueen(color::String="white")
	queen = falses(64)
	if color == "white"
		queen[60] = true
	else
		queen[4] = true
	end
	return queen
end


"""
	setSide(p::BitArray{1}, r::BitArray{1}, n::BitArray{1},
			b::BitArray{1}, q::BitArray{1}, k::BitArray{1})

Build white-only and black-only boards.
"""
function setSide(p::BitArray{1}, r::BitArray{1}, n::BitArray{1},
				 b::BitArray{1}, q::BitArray{1}, k::BitArray{1})
	side = falses(64)
	for i = 1:64
		if  p[i] | r[i] | n[i] | b[i] | k[i] | q[i]
			side[i] = true
		end
	end
	return side
end


"""
	setFree(white::BitArray{1}, black::BitArray{1})

Allocate free squares board.
"""
function setFree(white::BitArray{1}, black::BitArray{1})
	free = trues(64)
	for i = 1:64
		if white[i] | black[i]
			free[i] = false
		end
	end
	return free
end


"""
	setTaken(free::BitArray{1})

Allocate taken squares board.
"""
function setTaken(free::BitArray{1})
	taken = trues(64)
	for i = 1:64
		if free[i]
			taken[i] = false
		end
	end
	return taken
end


struct LookUpTables

	clear_rank :: BitArray{2}
	mask_rank  :: BitArray{2}

	clear_file :: BitArray{2}
	mask_file  :: BitArray{2}

	clear_night_files :: BitArray{2}

end


function buildLookUpTables()

	clear_rank = setClearRank()
	clear_file = setClearFile()

	mask_rank = setMaskRank()
	mask_file = setMaskFile()

	clear_night_files = setNightFiles(clear_file)

	return LookUpTables(clear_rank, mask_rank,
						clear_file, mask_file,
						clear_night_files)
end


function setClearRank()
	clear_rank = trues(64, 8)

	r = 8
	for j = 1:8
		cr = transpose(reshape(trues(64), 8, :))
		cr[r,:] .= false
		clear_rank[:,j] = reshape(transpose(cr), 64)
		r -= 1
	end

	return clear_rank
end


function setClearFile()
	clear_file = trues(64, 8)

	for j = 1:8
		cf = transpose(reshape(trues(64), 8, :))
		cf[:,j] .= false
		clear_file[:,j] = reshape(transpose(cf), 64)
	end

	return clear_file
end


function setMaskRank()
	mask_rank = falses(64, 8)

	r = 8
	for j = 1:8
		mr = transpose(reshape(falses(64), 8, :))
		mr[r,:] .= true
		mask_rank[:,j] = reshape(transpose(mr), 64)
		r -= 1
	end

	return mask_rank
end


function setMaskFile()
	mask_file = falses(64, 8)

	for j = 1:8
		mf = transpose(reshape(falses(64), 8, :))
		mf[:,j] .= true
		mask_file[:,j] = reshape(transpose(mf), 64)
	end

	return mask_file
end


function setNightFiles(clear_file::BitArray{2})
	clear_night_files = falses(64, 8)

	clear_night_files[:,1] = clear_file[:,1] .& clear_file[:,2]
	clear_night_files[:,2] = clear_file[:,1]
	clear_night_files[:,3] = clear_file[:,8]
	clear_night_files[:,4] = clear_file[:,8] .& clear_file[:,7]

	clear_night_files[:,5] = clear_file[:,8] .& clear_file[:,7]
	clear_night_files[:,6] = clear_file[:,8]
	clear_night_files[:,7] = clear_file[:,1]
	clear_night_files[:,8] = clear_file[:,1] .& clear_file[:,2]

	return clear_night_files
end
