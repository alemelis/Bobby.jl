"Draw an empty chessboard with Compose.jl and save it in `.png` format as `./chessboard.png`.

Optional arguments:
-------------------
- `board_name :: String` filename.
- `fmt :: String` file format; either `PNG` (default) or vectorial `SVG`.
- `b_clr :: String` color for dark tiles.
- `w_clr :: String` color for light tiles."
function drawEmptyBoard(;board_name :: String = "chessboard", fmt :: String = "PNG",
                   b_clr :: String = "black", w_clr :: String = "white")

    composition = compose(context(),
        (context(units=UnitBox(0, 0, 64, 64)), rectangle(0, 0, 8, 8), fill(b_clr)),
        (context(), rectangle([1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [0], [1/8], [1/8]),
            fill([w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [1/8], [1/8], [1/8]),
            fill([w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [1/4], [1/8], [1/8]),
            fill([b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [3/8], [1/8], [1/8]),
            fill([w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [1/2], [1/8], [1/8]),
            fill([b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [5/8], [1/8], [1/8]),
            fill([w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [3/4], [1/8], [1/8]),
            fill([b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr])),
        (context(), rectangle([0, 1/8, 1/4, 3/8, 1/2, 5/8, 3/4, 7/8], [7/8], [1/8], [1/8]),
            fill([w_clr, b_clr, w_clr, b_clr, w_clr, b_clr, w_clr, b_clr])),
        )

    if fmt == "SVG"
        composition |> SVG("$board_name.svg", 8cm, 8cm)
    elseif fmt == "PNG"
        composition |> PNG("$board_name.png", 640px, 640px)
    end

end

function loadPieces()
    r = load("pieces/r.png")
    wr = load("pieces/wR.png")

    b = load("pieces/b.png")
    wb = load("pieces/wB.png")

    n = load("pieces/n.png")
    wn = load("pieces/wN.png")

    k = load("pieces/k.png")
    wk = load("pieces/wK.png")

    q = load("pieces/q.png")
    wq = load("pieces/wQ.png")

    p = load("pieces/p.png")
    wp = load("pieces/wP.png")

    pieces = Dict('r' => r, 'R' => wr, 'n' => n, 'N' => wn, 'b' => b, 'B' => wb,
                    'q' => q, 'Q' => wq, 'k' => k, 'K' => wk, 'p' => p, 'P' => wp)
    return pieces
end

"Draw pieces scheme on the empty board"
function drawScheme(board, scheme, pieces)

    t = Int(size(board)[1]/8)

    for i = 1:8
        row = scheme[i]

        for j = 1:8
            c = row[j]

            if c == '0'
                continue
            end

            p = pieces[c]
            h = size(p)[2] - 1
            w = size(p)[1] - 1

            h_pad = Int(t/2) - Int(floor(w/2))
            v_pad = Int(t/2) - Int(floor(h/2))

            x0 = (i-1)*80 + h_pad
            y0 = (j-1)*80 + v_pad

            board[x0:x0 + w, y0:y0 + h] = p
        end
    end

    return board
end
