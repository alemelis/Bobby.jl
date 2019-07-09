struct Move
    source :: UInt64
    target :: UInt64
    piece_type :: String
    capture_type :: String
    promotion_type :: String
    enpassant_square :: UInt64
    castling_type :: String
end


mutable struct Bitboard
    pieces :: UInt64
    P :: UInt64
    R :: UInt64
    N :: UInt64
    B :: UInt64
    Q :: UInt64
    K :: UInt64
    A :: Array{UInt64,1}
    color :: String

    home_rank :: UInt64
    promotion_rank :: UInt64
    one_step :: Dict{UInt64,UInt64}
    two_steps :: Dict{UInt64,UInt64}
    attacks :: Dict{UInt64,Array{UInt64,1}}
    enpassant_rank :: UInt64

    king_home_sq :: UInt64
    king_side_1st_sq :: UInt64
    king_side_castling_sq :: UInt64
    queen_side_1st_sq :: UInt64
    queen_side_castling_sq :: UInt64
    king_side_rook_sq :: UInt64
    queen_side_rook_sq :: UInt64

    king_moved :: Bool
    can_castle_kingside  :: Bool
    can_castle_queenside :: Bool
end


mutable struct Chessboard
    white :: Bitboard
    black :: Bitboard
    
    free :: UInt64
    taken :: UInt64

    white_attacks :: UInt64 # attacked squares
    black_attacks :: UInt64

    player_color :: String

    enpassant_square :: UInt64
    enpassant_done :: Bool

    halfmove_clock :: Int64
    fullmove_clock :: Int64 # start at 1, increment for each black move

    fen :: String
    game :: Array{String,1}
end


function set_board()
    return fen_to_chessboard(
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
end
