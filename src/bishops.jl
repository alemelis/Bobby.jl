function slide_diagonal(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    for i in 1:15
        if DIAGONALS[i] & ui != EMPTY
            return slide(free_squares, edge_squares, occ,
                ui, 9, DIAGONALS[i])
        end
    end
end


function slide_antidiagonal(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    for i in 1:15
        if ANTIDIAGONALS[i] & ui != EMPTY
            return slide(free_squares, edge_squares, occ,
                ui, 7, ANTIDIAGONALS[i])
        end
    end
end


function cross_attack(occ::UInt64, ui::UInt64)
    free_squares = Array{UInt64,1}()
    edge_squares = Array{UInt64,1}()

    free_squares, edge_squares = slide_diagonal(free_squares, edge_squares,
        occ, ui)
    free_squares, edge_squares = slide_antidiagonal(free_squares, edge_squares,
        occ, ui)

    return free_squares, edge_squares
end


function cross_attack(free_squares::Array{UInt64,1},
    edge_squares::Array{UInt64,1}, occ::UInt64, ui::UInt64)

    free_squares, edge_squares = slide_diagonal(free_squares, edge_squares,
        occ, ui)
    free_squares, edge_squares = slide_antidiagonal(free_squares, edge_squares,
        occ, ui)

    return free_squares, edge_squares
end
