function move(source::String, target::String, color::String)
	# convert pgn to integer
end

function pgn2int(square::String)

	if length(square) != 2
		throw(DomainError("square name must be long 2"))
	end

	file = square[1]
	if !( file in "abcdefgh")
		throw(DomainError("the file should be in {a, ..., h}"))
	end
	f = Int(file) - 96

	rank = square[2]
	try
		rank = parse(Int, rank)
	catch err
		throw(ArgumentError("the rank should be an Int"))
	end

	if !( rank >= 1 && rank <= 8)
		throw(DomainError("the rank shoudl be in {1, ..., 8}"))
	end

	return f + (8 - rank)*8
end