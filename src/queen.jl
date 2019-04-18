function star_attack(board::UInt64, ui::UInt64)
    free_squares, edge_squares = orthogonal_attack(board, ui)
    free_squares, edge_squares  = cross_attack(free_squares, edge_squares,
        board, ui)

    return free_squares, edge_squares
end

function star_attack(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)
    free_squares, edge_squares = orthogonal_attack(free_squares, edge_squares,
        occ, ui)
    free_squares, edge_squares = cross_attack(free_squares, edge_squares, occ,
        ui)

    return free_squares, edge_squares
end


# function get_queen_valid(board::Bitboard, color::String="white")
#     if color == "white"
#         queens = board.Q
#         same = board.white
#         other = board.black
#     elseif color == "black"
#         queens = board.q
#         same = board.black
#         other = board.white
#     end

#     queen_moves = zeros(UInt64, 0)
#     queen_edges = zeros(UInt64, 0)
#     for queen in queens
#         moves, edges = star_attack(board.taken, queen)
#         append!(queen_moves, moves)
#         for edge in edges
#             if edge & same == EMPTY
#                 append!(queen_moves, edge)
#             end
#         end
#     end
#     return queen_moves
# end
