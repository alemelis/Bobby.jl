## Idea

Bobby is a chess engine written in Julia

**Hasn't already been done?** sort of...

[Chess.jl](https://github.com/abahm/Chess.jl) is another Julia chess engine. However, Bobby is also my way of staying fluent in Julia.

---

The documentation is generated with [Documenter.jl](https://juliadocs.github.io/Documenter.jl/stable/index.html)

```bash
$ julia make.jl
```

## References

### Repos

- [chess-position-evaluation](https://github.com/int8/chess-position-evaluation) with machine learning (Julia)
- [tensorflow_chessbot](https://github.com/Elucidation/tensorflow_chessbot) predicts FEN layouts from images (Python)
- [Chess.jl](https://github.com/abahm/Chess.jl) (Julia)

### Papers

- Silver et al. (2017) [
Mastering Chess and Shogi by Self-Play with a General Reinforcement Learning Algorithm](https://arxiv.org/abs/1712.01815)

### Tutorials

- [Tom Kerrigan's Simple Chess Program (TSCP)](https://sites.google.com/site/tscpchess/home) is a tutorial engine (C)
- Francois Dominic Laramee Chess Programming series (Java):
	- [Introduction](https://www.gamedev.net/articles/programming/artificial-intelligence/chess-programming-part-i-getting-started-r1014)
	- [Data Structures](https://www.gamedev.net/articles/programming/artificial-intelligence/chess-programming-part-ii-data-structures-r1046)
	- [Move Generation](https://www.gamedev.net/articles/programming/artificial-intelligence/chess-programming-part-iii-move-generation-r1126)
	- [Evaluation Function](https://www.gamedev.net/articles/programming/artificial-intelligence/chess-programming-part-vi-evaluation-functions-r1208)
	- [Advanced Search](https://www.gamedev.net/articles/programming/artificial-intelligence/chess-programming-part-v-advanced-search-r1197)
- Bruce Moreland [Gerbil](https://web.archive.org/web/20071026090003/http://www.brucemo.com/compchess/programming/index.htm) (C)