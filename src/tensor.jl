# ---------------------------------------------------------------------------
# Neural-network input encoding
#
# board_to_tensor!(buf, b) writes a board position into a caller-owned Float32
# array of shape (8, 8, N_PLANES).  Zero heap allocations.
#
# Plane layout (1-based index):
#    1– 6  white pieces  P N B R Q K
#    7–12  black pieces  p n b r q k
#   13     white castles kingside  (CK)
#   14     white castles queenside (CQ)
#   15     black castles kingside  (Ck)
#   16     black castles queenside (Cq)
#   17     en-passant column (entire column = 1.0 when available)
#   18     side to move: 1.0 = black to move, 0.0 = white
#   19     halfmove clock / 100  (scalar broadcast to 8×8)
#   20     fullmove number / 512 (scalar broadcast to 8×8)
#
# Buffer convention: buf[rank, file, plane]
#   rank 1 = White's back rank (rank 1 in algebraic notation)
#   file 1 = a-file, file 8 = h-file
#
# Square ↔ index:  trailing_zeros(sq) = tz
#   rank (1-based) = (tz >> 3) + 1     (tz 0..7 → rank 1, tz 56..63 → rank 8)
#   file (1-based) = 8 - (tz & 7)      (tz%8==0 → file h=8, tz%8==7 → file a=1)
# ---------------------------------------------------------------------------

const N_PLANES = 20

function board_to_tensor!(buf::Array{Float32,3}, b::Board)
    fill!(buf, 0f0)

    # Set every occupied square of bitboard `bb` to 1.0 in plane `p`.
    @inline function set_pieces!(p::Int, bb::UInt64)
        while bb != EMPTY
            sq = lsb(bb); bb = popbit(bb)
            tz = Int(trailing_zeros(sq))
            @inbounds buf[(tz >> 3) + 1, 8 - (tz & 7), p] = 1f0
        end
    end

    # --- piece planes ---
    set_pieces!( 1, b.white.P); set_pieces!( 2, b.white.N)
    set_pieces!( 3, b.white.B); set_pieces!( 4, b.white.R)
    set_pieces!( 5, b.white.Q); set_pieces!( 6, b.white.K)
    set_pieces!( 7, b.black.P); set_pieces!( 8, b.black.N)
    set_pieces!( 9, b.black.B); set_pieces!(10, b.black.R)
    set_pieces!(11, b.black.Q); set_pieces!(12, b.black.K)

    # --- castling rights (scalar → full 8×8 plane) ---
    b.castling & CK != NOCASTLING && fill!(view(buf, :, :, 13), 1f0)
    b.castling & CQ != NOCASTLING && fill!(view(buf, :, :, 14), 1f0)
    b.castling & Ck != NOCASTLING && fill!(view(buf, :, :, 15), 1f0)
    b.castling & Cq != NOCASTLING && fill!(view(buf, :, :, 16), 1f0)

    # --- en passant: mark the whole column ---
    if b.enpassant != EMPTY
        col = 8 - (Int(trailing_zeros(b.enpassant)) & 7)
        for rank = 1:8
            @inbounds buf[rank, col, 17] = 1f0
        end
    end

    # --- side to move ---
    !b.active && fill!(view(buf, :, :, 18), 1f0)

    # --- clocks (normalised scalars → full planes) ---
    fill!(view(buf, :, :, 19), Float32(b.halfmove) / 100f0)
    fill!(view(buf, :, :, 20), Float32(b.fullmove) / 512f0)

    return buf
end
