mutable struct PerftTree
    tot::Int64
    nodes::Array{Int64,1}
    div::Dict{AbstractString,Array{Int64,1}}
end

function perft(b::Board, max_depth::Int64)
    pt = PerftTree(0, zeros(max_depth),
                   Dict{AbstractString,Array{Int64,1}}())

    board_stack    = Vector{Board}(undef, max_depth + 2)
    board_stack[1] = b
    raw_stack      = [Moves(320) for _ in 1:max_depth + 1]
    filtered_stack = [Moves(320) for _ in 1:max_depth + 1]
    pin_ray_stack  = [zeros(UInt64, 64) for _ in 1:max_depth + 1]

    explore!(pt, board_stack, raw_stack, filtered_stack, pin_ray_stack, max_depth, 1)
    return pt
end

function explore!(pt::PerftTree,
                  board_stack::Vector{Board},
                  raw_stack::Vector{Moves},
                  filtered_stack::Vector{Moves},
                  pin_ray_stack::Vector{Vector{UInt64}},
                  max_depth::Int64,
                  depth::Int64,
                  root_move::AbstractString = "")

    b = board_stack[depth]

    # --- generate pseudo-legal moves ---
    white = b.active
    if white
        friends = b.white.friends; enemy = b.black; cs = b.white
    else
        friends = b.black.friends; enemy = b.white; cs = b.black
    end
    raw = raw_stack[depth]
    empty!(raw)
    king_in_check = inCheck(b, !b.active)
    for (bitboard, s) in ((cs.P, PIECE_PAWN),   (cs.N, PIECE_KNIGHT),
                           (cs.B, PIECE_BISHOP), (cs.R, PIECE_ROOK),
                           (cs.Q, PIECE_QUEEN),  (cs.K, PIECE_KING))
        getPieceMoves!(raw, bitboard, s, friends, enemy, white, b, king_in_check)
    end

    # --- compute pin data once for this position ---
    pin_ray = pin_ray_stack[depth]
    pinned, check_mask, n_checkers = computePinData!(pin_ray, b, white)

    # --- filter: use pin data to skip makeMove+inCheck for most moves ---
    filtered = filtered_stack[depth]
    empty!(filtered)
    for m in raw.moves
        if m.type == PIECE_NONE || m.take.type == PIECE_KING; continue end

        if m.type == PIECE_KING
            # King moves always need full check (x-ray attacks)
            @inbounds board_stack[depth + 1] = makeMove(b, m)
            if !inCheck(board_stack[depth + 1], b.active)
                push!(filtered, m)
            end
            continue
        end

        if n_checkers >= 2
            continue  # double check: only king can resolve it
        end

        # En passant: always full check (horizontal pin edge case)
        if m.type == PIECE_PAWN && m.take != NONE && m.take.square != m.to
            @inbounds board_stack[depth + 1] = makeMove(b, m)
            if !inCheck(board_stack[depth + 1], b.active)
                push!(filtered, m)
            end
            continue
        end

        # Single check: move must block or capture the checker
        if (m.to & check_mask) == EMPTY; continue end

        # Pinned piece: move must stay on the pin ray
        if (m.from & pinned) != EMPTY
            @inbounds if (m.to & pin_ray[sq2idx(m.from)]) == EMPTY; continue end
        end

        push!(filtered, m)
    end

    n = length(filtered.moves)
    pt.tot += n
    @inbounds pt.nodes[depth] += n
    if root_move != ""
        @inbounds pt.div[root_move][depth - 1] += n
    end

    if n == 0 || depth == max_depth
        return
    end

    for i in 1:n
        @inbounds m = filtered.moves[i]

        if depth == 1
            root_move = UINT2PGN[m.from] * UINT2PGN[m.to]
            if m.promotion != PIECE_NONE
                root_move *= m.promotion == PIECE_QUEEN  ? "q" :
                             m.promotion == PIECE_ROOK   ? "r" :
                             m.promotion == PIECE_BISHOP ? "b" : "n"
            end
            pt.div[root_move] = zeros(max_depth)
        end

        @inbounds board_stack[depth + 1] = makeMove(b, m)
        explore!(pt, board_stack, raw_stack, filtered_stack, pin_ray_stack,
                 max_depth, depth + 1, root_move)
    end
end
