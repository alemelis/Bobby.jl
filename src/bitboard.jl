mutable struct Bitboard
	white :: BitArray{1}
	P :: BitArray{1}
	R :: BitArray{1}
	N :: BitArray{1}
	B :: BitArray{1}
	Q :: BitArray{1}
	K :: BitArray{1}

	black :: BitArray{1}
	p :: BitArray{1}
	r :: BitArray{1}
	n :: BitArray{1}
	b :: BitArray{1}
	q :: BitArray{1}
	k :: BitArray{1}
end

function buildBoard()
	white = falses(64)
	black = falses(64)

	P = placePawns()
	p = placePawns("black")
end

function placePawns(color="white")
	pawns = falses(64)
	if color == "white"
		for i = 49:64
			pawns[i] = true
		end
	else
		for i = 1:16
			pawns[i] = true
		end
	end
	return pawns
end