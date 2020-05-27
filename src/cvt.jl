function toInt(i::String)
    return parse(UInt64, i; base=2)
end

function pgn2uintGen()
    pgn =  Dict{String,UInt64}()
    uint = Dict{UInt64,String}()
    i = 0
    for rank in 8:-1:1
        for file in 1:8
            square = "0"^i * "1" * "0"^(63 - i)
            square_int = toInt(square)
            coord = string(Char(Int('a')+(file - 1)))*string(rank)
            push!(pgn, coord=>square_int)
            push!(uint, square_int=>coord)
            i += 1
        end
    end
    return pgn, uint
end
const PGN2UINT, UINT2PGN = pgn2uintGen()
const A1 = PGN2UINT["a1"]
const B1 = PGN2UINT["b1"]
const C1 = PGN2UINT["c1"]
const D1 = PGN2UINT["d1"]
const E1 = PGN2UINT["e1"]
const F1 = PGN2UINT["f1"]
const G1 = PGN2UINT["g1"]
const H1 = PGN2UINT["h1"]
const B1C1D1 = B1|C1|D1
const F1G1 = F1|G1
const A8 = PGN2UINT["a8"]
const B8 = PGN2UINT["b8"]
const C8 = PGN2UINT["c8"]
const D8 = PGN2UINT["d8"]
const E8 = PGN2UINT["e8"]
const F8 = PGN2UINT["f8"]
const G8 = PGN2UINT["g8"]
const H8 = PGN2UINT["h8"]
const B8C8D8 = B8|C8|D8
const F8G8 = F8|G8

function pgn2intGen()
    pgn = Dict{String,Int64}()
    int = Dict{Int64,String}()

    i = 1
    for rank in 8:-1:1
        for file in 1:8
            coord = string(Char(Int('a') + (file - 1)))*string(rank)
            push!(pgn, coord=>i)
            push!(int, i=>coord)
            i += 1
        end
    end
    return pgn, int
end
const PGN2INT, INT2PGN = pgn2intGen()

function int2uintGen()
    int = Dict{Int64,UInt64}()
    uint = Dict{UInt64,Int64}()

    for i = 1:64
        pgn = INT2PGN[i]
        pgnuint = PGN2UINT[pgn]
        push!(int, i=>pgnuint)
        push!(uint, pgnuint=>i) 
    end
    return int, uint
end
const INT2UINT, UINT2INT = int2uintGen()
