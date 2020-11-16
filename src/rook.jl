function orthoSlide(square::UInt64)
    visited = EMPTY

    #vertical
    for shift = 8:8:48
        (square << shift) & INSIDE == EMPTY ? continue : visit = square << shift
        visit & MASK_RANKS[8] == EMPTY ? visited |= visit : break
    end
    for shift = 8:8:48
        (square >> shift) & INSIDE == EMPTY ? continue : visit = square >> shift
        visit & MASK_RANKS[1] == EMPTY ? visited |= visit : break
    end
    #horizontal
    for shift = 1:6
        square & MASK_FILES[1] != EMPTY ? break : visit = square << shift
        visit & MASK_FILES[1] != EMPTY ? break : visited |= visit
    end
    for shift = 1:6
        square & MASK_FILES[8] != EMPTY ? break : visit = square >> shift
        visit & MASK_FILES[8] != EMPTY ? break : visited |= visit
    end

    return visited
end

function rookMasksGen()
    masks = Dict{UInt64,UInt64}()
    [push!(masks, s=>orthoSlide(s)) for s in values(PGN2UINT)]
    return masks
end
#orthogonal masks
const ROOK_MASKS = rookMasksGen()

function orthoAttack(square::UInt64, occupancy::UInt64)
    visited = EMPTY

    #vertical
    for shift = 8:8:56
        (square << shift) & INSIDE == EMPTY ? break : visit = square << shift
        visited |= visit
        if visit & MASK_RANKS[8] != EMPTY || visit & occupancy != EMPTY; break end
    end
    for shift = 8:8:56
        (square >> shift) & INSIDE == EMPTY ? break : visit = square >> shift
        visited |= visit
        if visit & MASK_RANKS[1] != EMPTY || visit & occupancy != EMPTY; break end
    end
    #horizontal
    for shift = 1:7
        square & MASK_FILES[8] != EMPTY ? break : visit = square >> shift
        visited |= visit
        if visit & MASK_FILES[8] != EMPTY || visit & occupancy != EMPTY; break end
    end
    for shift = 1:7
        square & MASK_FILES[1] != EMPTY ? break : visit = square << shift
        visited |= visit
        if visit & MASK_FILES[1] != EMPTY || visit & occupancy != EMPTY; break end
    end
    return visited
end
