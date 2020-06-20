mutable struct PerftTree
    tot::Threads.Atomic{Int64}
    nodes::Array{Int64,1}
    div::Dict{AbstractString,Array{Int64,1}}
end

function perft(b::Board, max_depth::Int64)
    pt = PerftTree(Threads.Atomic{Int64}(0), zeros(max_depth), Dict{UInt64,Int64}())
    explore(pt, b, max_depth, 1)
    return pt
end

function explore(pt::PerftTree, b::Board, max_depth::Int64,
                 depth::Int64, root_move::AbstractString="")

    
    moves = getMoves(b, b.active)
    Threads.atomic_add!(pt.tot, length(moves.moves))
    pt.nodes[depth] += length(moves.moves)

    if root_move != ""
        pt.div[root_move][depth-1] += length(moves.moves)
    end
  
    if length(moves.moves) == 0 || depth == max_depth
        return pt
    end

    for m in moves.moves
        if m.type == :none; break end
        if depth == 1
            root_move = UINT2PGN[m.from]*UINT2PGN[m.to]
            if m.promotion != :none
                if m.promotion == :queen
                    root_move *= "q"
                elseif m.promotion == :rook
                    root_move *= "r"
                elseif m.promotion == :bishop
                    root_move *= "b"
                elseif m.promotion == :knight
                    root_move *= "n"
                end
            end
            pt.div[root_move] = zeros(max_depth)
        end
        explore(pt, makeMove(b, m), max_depth, depth+1, root_move)
    end
end
