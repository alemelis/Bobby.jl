"""
    Bitboard

Data structure for the chess board.
"""
mutable struct Bitboard
    white :: UInt64 # all white pieces
    P :: Array{UInt64,1}
    R :: Array{UInt64,1}
    N :: Array{UInt64,1}
    B :: Array{UInt64,1}
    Q :: Array{UInt64,1}
    K :: UInt64

    black :: UInt64 # all black pieces
    p :: Array{UInt64,1}
    r :: Array{UInt64,1}
    n :: Array{UInt64,1}
    b :: Array{UInt64,1}
    q :: Array{UInt64,1}
    k :: UInt64

    free :: UInt64  # all free squares
    taken :: UInt64 # all pieces

    white_attacks :: UInt64 # attacked squares
    black_attacks :: UInt64

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

    white_in_check :: Bool
    black_in_check :: Bool
end


"""
    set_board()

Set board in starting position.
"""
function set_board()
    return fen_to_bitboard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
end