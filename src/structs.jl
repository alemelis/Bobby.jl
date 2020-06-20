const EMPTY = UInt64(0)

struct ChessSet
    P::UInt64
    N::UInt64
    B::UInt64
    R::UInt64
    Q::UInt64
    K::UInt64
    friends::UInt64
end

function Base.show(io::IO, b::ChessSet)
end

struct Board
    white::ChessSet
    black::ChessSet

    taken::UInt64

    active::Bool
    castling::UInt8
    enpassant::UInt64
    halfmove::Int64
    fullmove::Int64
end

struct Piece
    type::Symbol
    square::UInt64
end
const NONE = Piece(:none, EMPTY)

mutable struct Move
    type::Symbol
    from::UInt64
    to::UInt64
    take::Piece
    enpassant::UInt64
    promotion::Symbol
    castling::UInt8
end
const CK = UInt8(8)
const CQ = UInt8(4)
const Ck = UInt8(2)
const Cq = UInt8(1)
const NOCASTLING = UInt8(0)
const NOTAMOVE = Move(:none, EMPTY, EMPTY, NONE,
                      EMPTY, :none, NOCASTLING)

mutable struct Moves
    moves::Array{Move,1}
end

function Moves()
    return Moves(Array{Move,1}())
end

import Base.push!
function push!(list::Moves, move::Move)
    push!(list.moves, move)
end
