using Bobby
using Base.Test

skak_file = "skak_test"
game_moves = "1. e4 d5"

Bobby.writeGame(skak_file, game_moves)
@test isfile(skak_file*".tex")

Bobby.compileGame(skak_file)
@test isfile(skak_file*".png")

Bobby.rmLaTeXcompilationFiles(skak_file)
@test isfile(skak_file*".tex") == false
