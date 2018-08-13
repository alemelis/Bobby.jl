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

	P = setPawns()
	p = setPawns("black")

	R = setRooks()
	r = setRooks("black")

	N = setNights()
	n = setNights("black")
end


```
	setPawns(color="white")

Constructor function for pawns.
```
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


```
	setRooks(color="white")

Constructor function for rooks.
```
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


```
	setNights(color="white")

Constructor function for (k)nights.
```
function setNights(color="white")
	nights = falses(64)
	if color == "white"
		nights[58] = true
		nights[63] = true
	else
		nights[2] = true
		nights[7] = true
	end
	return nights
end


```
	setBishops(color="white")

Constructor function for bishops.
```
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