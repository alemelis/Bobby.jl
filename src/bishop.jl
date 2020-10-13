function diagoSlide(square::UInt64)
    visited = EMPTY

    #NW
    for shift = 9:9:54
        square & (MASK_FILES[1] | MASK_RANKS[8]) != EMPTY ? break : visit = square << shift
        visit & (MASK_FILES[1] | MASK_RANKS[8]) != EMPTY ? break : visited |= visit
    end 
    #SE
    for shift = 9:9:54
        square & (MASK_FILES[8] | MASK_RANKS[1]) != EMPTY ? break : visit = square >> shift
        visit & (MASK_FILES[8] | MASK_RANKS[1]) != EMPTY ? break : visited |= visit
    end
    #NE
    for shift = 7:7:42
        square & (MASK_FILES[8] | MASK_RANKS[8]) != EMPTY ? break : visit = square << shift
        visit & (MASK_FILES[8] | MASK_RANKS[8]) != EMPTY ? break : visited |= visit
    end 
    #SW
    for shift = 7:7:42
        square & (MASK_FILES[1] | MASK_RANKS[1]) != EMPTY ? break : visit = square >> shift
        visit & (MASK_FILES[1] | MASK_RANKS[1]) != EMPTY ? break : visited |= visit
    end

    return visited
end

function bishopMasksGen()
    masks = Dict{UInt64,UInt64}()
    [push!(masks, s=>diagoSlide(s)) for s in values(PGN2UINT)]
    return masks
end
#diagonal masks
const BISHOP_MASKS = bishopMasksGen()

function diagoAttack(square::UInt64, occupancy::UInt64)
    visited = EMPTY

    #NW
    for shift = 9:9:63
        square & (MASK_FILES[1] | MASK_RANKS[8]) != EMPTY ? break : visit = square << shift
        visited |= visit
        if visit & (MASK_FILES[1] | MASK_RANKS[8]) != EMPTY || visit & occupancy != EMPTY; break end
    end 
    #SE
    for shift = 9:9:63
        square & (MASK_FILES[8] | MASK_RANKS[1]) != EMPTY ? break : visit = square >> shift
        visited |= visit
        if visit & (MASK_FILES[8] | MASK_RANKS[1]) != EMPTY || visit & occupancy != EMPTY; break end
    end
    #NE
    for shift = 7:7:63
        square & (MASK_FILES[8] | MASK_RANKS[8]) != EMPTY ? break : visit = square << shift
        visited |= visit
        if visit & (MASK_FILES[8] | MASK_RANKS[8]) != EMPTY || visit & occupancy != EMPTY; break end
    end 
    #SW
    for shift = 7:7:63
        square & (MASK_FILES[1] | MASK_RANKS[1]) != EMPTY ? break : visit = square >> shift
        visited |= visit
        if visit & (MASK_FILES[1] | MASK_RANKS[1]) != EMPTY || visit & occupancy != EMPTY; break end
    end

    return visited
end
