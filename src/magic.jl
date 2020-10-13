function getOccupancyString(n::Int64)
    return Tuple([bitstring(i)[end-n+1:end] for i = 0:2^n-1])
end

const ROOK_SHIFTS = (8, -8, -1, 1) #N, S, W, E
const BISHOP_SHIFTS = (9, 7, -7, -9) #NE, NW, SE, SW
function getNumberOfSquares(square::UInt64, rook::Bool, d::Int64)
    rook ? mask = ROOK_MASKS[square] : mask = BISHOP_MASKS[square]
    rook ? shifts = ROOK_SHIFTS : shifts = BISHOP_SHIFTS
    c = 0
    while true
        (square << (shifts[d]*(c+1)) & mask) == EMPTY ? break : c+=1
    end
    return c
end

function getNumberOfBits(square::UInt64, rook::Bool)
    return reduce(+, [getNumberOfSquares(square, rook, d) for d=1:4])
end

function bitsGen(rook::Bool)
    bits = Dict{UInt64,Int64}()
    [push!(bits, sq=>getNumberOfBits(sq, rook)) for sq in values(PGN2UINT)]
    return bits
end
const ROOK_BITS = bitsGen(true)
const BISHOP_BITS = bitsGen(false)

function occupancyGen(rook::Bool)
    occupancies = Dict{UInt64, Tuple{Vararg{UInt64}}}()
    rook ? shifts = ROOK_SHIFTS : shifts = BISHOP_SHIFTS
    for sq in values(PGN2UINT)
        square_occs = []
        occs = [getOccupancyString(getNumberOfSquares(sq, rook, i)) for i=1:4]
        for ds in Iterators.product(occs...)
            occ = EMPTY
            [[if ds[j][i] == '1'; occ |= (sq<<(shifts[j]*i)) end for i=1:length(ds[j])] for j=1:4]
            push!(square_occs, occ) 
        end
        push!(occupancies, sq=>tuple(square_occs...))
    end
    return occupancies
end
const ORTHO_OCCS = occupancyGen(true)
const DIAGO_OCCS = occupancyGen(false)

function randomMagic()
    return rand(UInt64) & rand(UInt64) & rand(UInt64)
end

function magicSquareGen(square::UInt64, rook::Bool, bits::Int64)
    rook ? occupancies = ORTHO_OCCS : occupancies = DIAGO_OCCS
    rook ? slider = orthoAttack : slider = diagoAttack
    attacks = [slider(square, var) for var in values(occupancies[square])]
    while true
        magic = randomMagic()
        targets = zeros(UInt64, 2^bits)
        collision = false
        for j=1:length(attacks)
            i = ((occupancies[square][j]*magic) >> (64-bits)) + 1
            if targets[i] == EMPTY
                targets[i] = attacks[j]
            elseif targets[i] == attacks[j]
                continue
            else
                collision = true
                break
            end
        end
        collision ? continue : return magic, tuple(targets...)
    end
end

function magicTableGen(rook::Bool)
    rook ? bits = ROOK_BITS : bits = BISHOP_BITS
    magic_table = Dict{UInt64, UInt64}()
    attacks = Dict{UInt64, Tuple{Vararg{UInt64}}}()
    for s in values(PGN2UINT)
        magic, attack = magicSquareGen(s, rook, bits[s])
        push!(magic_table, s=>magic)
        push!(attacks, s=>attack)
    end
    return magic_table, attacks
end
const ROOK_MAGICS, ROOK_X = magicTableGen(true)
const BISHOP_MAGICS, BISHOP_X = magicTableGen(false)

function getMagicAttack(square::UInt64, blockers::UInt64, rook::Bool)
    rook ? magic = ROOK_MAGICS[square] : magic = BISHOP_MAGICS[square]
    rook ? bits = ROOK_BITS[square] : bits = BISHOP_BITS[square]
    rook ? attacks = ROOK_X[square] : attacks = BISHOP_X[square]
    rook ? mask = ROOK_MASKS[square] : mask = BISHOP_MASKS[square]
    i = ((blockers&mask)*magic) >> (64-bits)
    return attacks[i+1]
end
