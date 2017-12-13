skak_file = "skak_test"
game_moves = "1. e4 d5"

Bobby.writeGameTeX(skak_file, game_moves)
@test isfile(skak_file*".tex")

Bobby.compileGameTeX(skak_file)
@test isfile(skak_file*".png")

Bobby.rmGameTeX(skak_file)
@test isfile(skak_file*".tex") == false
rm("skak_test.png")
