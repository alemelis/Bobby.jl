function move(source::String, target::String, color::String)
	# convert pgn to integer
end

function pgn2int(square)
	if length(square) != 2
		throw(DomainError("name must be long 2"))
	end

	file = square[1]
	if !( file in "abcdefgh")
		throw(DomainError("the file character should be in {a, h}"))
	end

	try
		rank = parse(Int, square[2])
	catch e
		throw(ArgumentError("the rank character should be an Int"))
	end
end