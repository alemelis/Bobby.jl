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

	white_attacks :: BitArray{1} # attacked squares
	black_attacks :: BitArray{1}

	white_castled :: Bool
	black_castled :: Bool
	white_king_moved :: Bool
	black_king_moved :: Bool
	a1_rook_moved :: Bool
	h1_rook_moved :: Bool
	a8_rook_moved :: Bool
	h8_rook_moved :: Bool
	white_OO :: Bool
	white_OOO :: Bool
	black_OO :: Bool
	black_OOO :: Bool
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
	white_attacks = setAttacked()
	black_attacks = setAttacked("black")

	white_castled = false
	black_castled = false
	white_king_moved = false
	black_king_moved = false
	a1_rook_moved = false
	h1_rook_moved = false
	a8_rook_moved = false
	h8_rook_moved = false
	white_OO = false
	white_OOO = false
	black_OO = false
	black_OOO = false

	return Bitboard(white, P, R, N, B, Q, K, black,
		p, r, n, b, q, k, free, taken,
		white_attacks, black_attacks,
		white_castled, black_castled,
		white_king_moved, black_king_moved,
		a1_rook_moved, h1_rook_moved,
		a8_rook_moved, h8_rook_moved,
		white_OO, white_OOO, black_OO, black_OOO)
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

function setAttacked(color::String="white")
	attacked = falses(64)
	if color == "white"
		for i = 41:48
			attacked[i] = true
		end
	else
		for i = 17:24
			attacked[i] = true
		end
	end
	return attacked
end

struct LookUpTables
	clear_rank :: BitArray{2}
	mask_rank  :: BitArray{2}

	clear_file :: BitArray{2}
	mask_file  :: BitArray{2}

	clear_night_files :: BitArray{2}

	# diagonals
	starts :: Array{Int64,1}
	steps  :: Array{Int64,1}
	ends  :: Array{Int64,1}
end


function buildLookUpTables()
	clear_rank = setClearRank()
	clear_file = setClearFile()

	mask_rank = setMaskRank()
	mask_file = setMaskFile()

	clear_night_files = getNightClearFiles(clear_file)

	starts, steps, ends = setDiagonals()

	return LookUpTables(clear_rank, mask_rank,
		clear_file, mask_file,
		clear_night_files,
		starts, steps, ends)
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


function getNightClearFiles(clear_file::BitArray{2})
	
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


function setDiagonals()
	# white squares
	starts = [1,  7,  16, 17, 3,  5,  32, 33, 5,  49, 7,  3,  48]
	steps =  [9,  7,  7,  9,  9,  7,  7,  9,  9,  9,  9,  7,  7]
	ends =   [64, 49, 58, 62, 48, 33, 60, 60, 32, 58, 16, 17, 62]

	# black squares
	append!(starts, [8,  2,  9,  6,  24, 4,  25, 4,  40, 6,  2, 56, 41])
	append!(steps,  [7,  9,  9,  7,  7,  9,  9,  7,  7,  9,  7, 7,  9])
	append!(ends,   [57, 56, 63, 41, 59, 40, 61, 25, 61, 24, 9, 63, 59])

	return starts, steps, ends
end
