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

    player_color :: String

    white_can_castle_queenside :: Bool
    white_can_castle_kingside  :: Bool
    black_can_castle_queenside :: Bool
    black_can_castle_kingside  :: Bool

    enpassant_square :: UInt64
    enpassant_done :: Bool

    halfmove_clock :: Int64
    fullmove_clock :: Int64 # start at 1, increment for each black move

    fen :: String
end


function set_board()
    return fen_to_bitboard(
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
end


function bitboard_to_fen(b::Bitboard)
    fen = ""
    i = 1
    rank_counter = 1
    empty_counter = 0
    for i = 1:64
        c = ""
        if INT2UINT[i] & b.taken != EMPTY
            if INT2UINT[i] & b.white != EMPTY
                if INT2UINT[i] in b.P
                    c = "P"
                elseif INT2UINT[i] in b.R
                    c = "R"
                elseif INT2UINT[i] in b.N
                    c = "N"
                elseif INT2UINT[i] in b.B
                    c = "B"
                elseif INT2UINT[i] in b.Q
                    c = "Q"
                elseif INT2UINT[i] == b.K
                    c = "K"
                end
            elseif INT2UINT[i] & b.black != EMPTY
                if INT2UINT[i] in b.p
                    c = "p"
                elseif INT2UINT[i] in b.r
                    c = "r"
                elseif INT2UINT[i] in b.n
                    c = "n"
                elseif INT2UINT[i] in b.b
                    c = "b"
                elseif INT2UINT[i] in b.q
                    c = "q"
                elseif INT2UINT[i] == b.k
                    c = "k"
                end
            end
        else
            c = ""
            empty_counter += 1
        end
        if (c != "" && empty_counter != 0) || empty_counter == 8
            fen *= string(empty_counter)
            empty_counter = 0
        end
        fen *= c
        rank_counter += 1
        if rank_counter > 8 && i != 64
            fen *= "/"
            rank_counter = 1
        end
    end

    if b.player_color == "white"
        fen *= " w "
    else
        fen *= " b "
    end

    no_castling = true
    if b.white_can_castle_kingside
        fen *= "K"
        no_castling = false
    end
    if b.white_can_castle_queenside
        fen *= "Q"
        no_castling = false
    end
    if b.black_can_castle_kingside
        fen *= "k"
        no_castling = false
    end
    if b.black_can_castle_queenside
        fen *= "q"
        no_castling = false
    end
    if no_castling
        fen *= " - "
    end

    if b.enpassant_square != EMPTY
        fen *= UINT2PGN[b.enpassant_square]*" "
    else
        fen *= " - "
    end

    fen *= string(b.halfmove_clock)*" "
    fen *= string(b.fullmove_clock)

    return fen
end