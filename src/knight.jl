const N_CLEAR_FILES = (0x3f3f3f3f3f3f3f3f, 0x7f7f7f7f7f7f7f7f,
                       0xfefefefefefefefe, 0xfcfcfcfcfcfcfcfc,
                       0xfcfcfcfcfcfcfcfc, 0xfefefefefefefefe,
                       0x7f7f7f7f7f7f7f7f, 0x3f3f3f3f3f3f3f3f)
const N_SHIFTS = (-10, -17, -15, -6, 10, 17, 15, 6)

function knightMovesGen()
    knight_moves = Vector{UInt64}(undef, 64)

    for square in values(PGN2UINT)
        targets = EMPTY
        for (clear, shift) in zip(N_CLEAR_FILES, N_SHIFTS)
            if (square & clear) >> shift != EMPTY
                targets |= (square & clear) >> shift
            end
        end
        knight_moves[sq2idx(square)] = targets
    end
    return knight_moves
end
const KNIGHT = knightMovesGen()

