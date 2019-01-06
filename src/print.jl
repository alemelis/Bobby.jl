"""
	uglyPrint(b::BitArray)

Print any bitboard in shape 8x8 (transposed) to REPL for debuggin purposes.
"""
function uglyPrint(b::BitArray)

	r_b = Int.(transpose(reshape(b, 8, :)))
	ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]

	@printf("\n  o-----------------o\n")
	for i = 1:8
		@printf("%s | ", ranks[i])
		for j = 1:8
			@printf("%d ", r_b[i,j])
		end
		@printf("|\n")
	end
	@printf("  o-----------------o\n")
	@printf("    a b c d e f g h\n")
end


"""
	prettyPrint(board::Bitboard)

Print a colorful board with pieces in algebraic notation
(capitalised for white and lower cased for black).
"""
function prettyPrint(board::Bitboard)
	
	ranks = ["8", "7", "6", "5", "4", "3", "2", "1"]
	
	free = transpose(reshape(board.free, 8, :))
	taken = transpose(reshape(board.taken, 8, :))
	p = transpose(reshape(board.p, 8, :))
	r = transpose(reshape(board.r, 8, :))
	n = transpose(reshape(board.n, 8, :))
	b = transpose(reshape(board.b, 8, :))
	q = transpose(reshape(board.q, 8, :))
	k = transpose(reshape(board.k, 8, :))
	P = transpose(reshape(board.P, 8, :))
	R = transpose(reshape(board.R, 8, :))
	N = transpose(reshape(board.N, 8, :))
	B = transpose(reshape(board.B, 8, :))
	Q = transpose(reshape(board.Q, 8, :))
	K = transpose(reshape(board.K, 8, :))
	white = transpose(reshape(board.white, 8, :))
	black = transpose(reshape(board.black, 8, :))

	@printf("\n  o-----------------o\n")
	for i = 1:8
		@printf(Crayon(reset=true), "%s | ", ranks[i])
		for j = 1:8
			if free[i,j]
				@printf(Crayon(reset=true), "⋅ ") # \cdot chatacter
			else
				if black[i,j]
					if p[i,j]
						c = "p"
					elseif r[i,j]
						c = "r"
					elseif n[i,j]
						c = "n"
					elseif b[i,j]
						c = "b"
					elseif q[i,j]
						c = "q"
					elseif k[i,j]
						c = "k"
					else
						error("Black piece not found")
					end
					color = :cyan
				else
					if P[i,j]
						c = "P"
					elseif R[i,j]
						c = "R"
					elseif N[i,j]
						c = "N"
					elseif B[i,j]
						c = "B"
					elseif Q[i,j]
						c = "Q"
					elseif K[i,j]
						c = "K"
					else
						error("White piece not found")
					end
					color = :light_gray
				end
				@printf(Crayon(bold=true, foreground=color), "%s ", c)
			end
		end
		@printf(Crayon(reset=true), "|\n")
	end
	@printf(Crayon(reset=true), "  o-----------------o\n")
	@printf("    a b c d e f g h\n")
end