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
	setPawns(color="white")

Constructor function for pawns.
"""
function setPawns(color="white")
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
	setRooks(color="white")

Constructor function for rooks.
"""
function setRooks(color="white")
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
	setNights(color="white")

Constructor function for (k)nights.
"""
function setNights(color="white")
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
	setBishops(color="white")

Constructor function for bishops.
"""
function setBishops(color="white")
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
	setKing(color="white")

Constructor function for king.
"""
function setKing(color="white")
	king = falses(64)
	if color == "white"
		king[61] = true
	else
		king[5] = true
	end
	return king
end


"""
	setQueen(color="white")

Constructor function for queen.
"""
function setQueen(color="white")
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

struct lookUpTables

	clearRank :: BitArray{2}
	maskRank  :: BitArray{2}

	clearFile :: BitArray{2}
	maskFile  :: BitArray{2}

end

function buildLookUpTables()

	clearRank = setClearRank()
	clearFile = 0

	maskRank = setMaskRank()
	maskFile = falses(64, 8)

end

function setClearRank()
	clearRank = trues(64, 8)

	r = 8
	for j = 1:8
		cr = transpose(reshape(trues(64), 8, :))
		cr[r,:] .= false
		clearRank[:,j] = reshape(transpose(cr), 64)
		r -= 1
	end

	return clearRank
end

function setMaskRank()
	maskRank = falses(64, 8)

	r = 8
	for j = 1:8
		mr = transpose(reshape(falses(64), 8, :))
		mr[r,:] .= true
		maskRank[:,j] = reshape(transpose(mr), 64)
		r -= 1
	end

	return maskRank
end