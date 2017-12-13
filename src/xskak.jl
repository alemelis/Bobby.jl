#=
xskak LaTeX package wrapper
https://ctan.org/pkg/xskak?lang=en
=#

function writeGameTeX(skak_file :: String, game_moves :: SubString{String})
    skak = open("$skak_file.tex", "w")
    write(skak, "\\documentclass{standalone}\n")
    write(skak, "\\usepackage{xskak}\n")
    write(skak, "\\begin{document}\n")
    write(skak, "\\newchessgame\n")
    write(skak, "\\hidemoves{$game_moves}\n")
    write(skak, "\\chessboard\n")
    write(skak, "\\end{document}")
    close(skak)
end

function compileGameTeX(skak_file :: String)
    run(`pdflatex --interaction=batchmode $skak_file.tex`)
    run(`convert -density 300 $skak_file.pdf -quality 90 -flatten $skak_file.png`)
    run(`convert $skak_file.png -crop 670x670+94+80 $skak_file.png`)
end

function rmGameTeX(skak_file :: String)
    for extension in [".tex", ".pdf", ".log", ".aux"]
        rm("$skak_file$extension")
    end
end
