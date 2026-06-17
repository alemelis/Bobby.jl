mutable struct PerftTree
    tot::Int64
    nodes::Array{Int64,1}
    div::Dict{String,Array{Int64,1}}
end

function perft(b::Board, max_depth::Int64; divide::Bool=false)
    pt = PerftTree(0, zeros(max_depth),
                   Dict{String,Array{Int64,1}}())

    raw_stack      = [Moves(320) for _ in 1:max_depth + 1]
    filtered_stack = [Moves(320) for _ in 1:max_depth + 1]
    pin_ray_stack  = [zeros(UInt64, 64) for _ in 1:max_depth + 1]

    if divide
        explore!(pt, b, raw_stack, filtered_stack, pin_ray_stack, max_depth, 1, Val(true))
    else
        explore!(pt, b, raw_stack, filtered_stack, pin_ray_stack, max_depth, 1, Val(false))
    end
    return pt
end

# `divide::Val{Bool}` is specialized away by the compiler: with Val(false), the
# string concatenation, Dict allocation, and per-node Dict lookup are dead code
# and get eliminated. Saves ~30–40% of perft time when divide info is not wanted.
function explore!(pt::PerftTree,
                  b::Board,
                  raw_stack::Vector{Moves},
                  filtered_stack::Vector{Moves},
                  pin_ray_stack::Vector{Vector{UInt64}},
                  max_depth::Int64,
                  depth::Int64,
                  ::Val{divide},
                  root_move::String = "") where {divide}

    # --- compute pin/check data first (gives us n_checkers to skip the inCheck call) ---
    white = b.active
    pin_ray = pin_ray_stack[depth]
    pinned, check_mask, n_checkers = computePinData!(pin_ray, b, white)

    # --- generate pseudo-legal moves ---
    if white
        friends = b.white.friends; enemy = b.black; cs = b.white
    else
        friends = b.black.friends; enemy = b.white; cs = b.black
    end
    king_in_check = n_checkers > 0
    filtered = filtered_stack[depth]
    empty!(filtered)

    # --- KNBRQ legal moves go directly into `filtered`; pawn + king pseudo-legal go to `raw` ---
    raw = raw_stack[depth]
    empty!(raw)
    if n_checkers < 2
        getLegalPieceMoves!(filtered, cs.N, PIECE_KNIGHT, friends, enemy, b.taken,
                            pinned, pin_ray, check_mask)
        getLegalPieceMoves!(filtered, cs.B, PIECE_BISHOP, friends, enemy, b.taken,
                            pinned, pin_ray, check_mask)
        getLegalPieceMoves!(filtered, cs.R, PIECE_ROOK,   friends, enemy, b.taken,
                            pinned, pin_ray, check_mask)
        getLegalPieceMoves!(filtered, cs.Q, PIECE_QUEEN,  friends, enemy, b.taken,
                            pinned, pin_ray, check_mask)
        getLegalPawnMoves!(filtered, raw, cs.P, b.taken, friends, enemy, white,
                           b.enpassant, pinned, pin_ray, check_mask)
    end
    getPieceMoves!(raw, cs.K, PIECE_KING, friends, enemy, white, b, king_in_check)

    # --- filter `raw` (king moves + EP): use isAttacked for regular king moves,
    #     make/unmake only for EP and castling (rare, or have edge-case pin logic). ---
    mover = b.active
    king_sq      = white ? b.white.K : b.black.K
    occ_no_king  = b.taken ⊻ king_sq   # occupancy with the king removed (for attack checks)

    for i in 1:raw.count
        @inbounds m = raw.data[i]
        mpiece(m) == PIECE_NONE && continue
        mcapture(m) == PIECE_KING && continue

        if mis_ep(m) || mcastling_enc(m) != 0
            # EP: horizontal-pin edge case requires full make/unmake.
            # Castling: destination validity already pre-checked in getCastlingMoves!,
            #           but we do a final make/unmake for safety on the rare path.
            undo = makeMove!(b, m)
            !inCheck(b, mover) && push!(filtered, m)
            unmakeMove!(b, undo)
        else
            # Regular king move: directly check destination under the modified occupancy.
            !isAttacked(mto_sq(m), occ_no_king, enemy, white) && push!(filtered, m)
        end
    end

    n = filtered.count
    pt.tot += n
    @inbounds pt.nodes[depth] += n
    if divide && root_move != ""
        @inbounds pt.div[root_move][depth - 1] += n
    end

    if n == 0 || depth == max_depth
        return
    end

    for i in 1:n
        @inbounds m = filtered.data[i]

        if divide && depth == 1
            root_move = sq2pgn(mfrom_sq(m)) * sq2pgn(mto_sq(m))
            promo = mpromo(m)
            if promo != PIECE_NONE
                root_move *= promo == PIECE_QUEEN  ? "q" :
                             promo == PIECE_ROOK   ? "r" :
                             promo == PIECE_BISHOP ? "b" : "n"
            end
            pt.div[root_move] = zeros(max_depth)
        end

        undo = makeMove!(b, m)
        explore!(pt, b, raw_stack, filtered_stack, pin_ray_stack,
                 max_depth, depth + 1, Val(divide), root_move)
        unmakeMove!(b, undo)
    end
end
