# Bobby.jl
A mediocre chess engine written in Julia

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/alemelis/Bobby.jl.svg?branch=master)](https://travis-ci.org/alemelis/Bobby.jl)
[![codecov](https://codecov.io/gh/alemelis/Bobby.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/alemelis/Bobby.jl)

## Install

In Julia REPL

```
(v1.1) pkg> add https://github.com/alemelis/Bobby.jl
```

## Play
```
(v1.1) pkg> activate .
```

```
julia> using Bobby
julia> Bobby.play()

  o-------------------------o
8 |  Π  ζ  Δ  Ψ  +  Δ  ζ  Π |
7 |  o  o  o  o  o  o  o  o |  o pawn
6 |                         |  ζ knight
5 |                         |  Δ bishop
4 |                         |  Π rook
3 |                         |  Ψ queen
2 |  o  o  o  o  o  o  o  o |  + king
1 |  Π  ζ  Δ  Ψ  +  Δ  ζ  Π |
  o-------------------------o
   a  b  c  d  e  f  g  h
white to move
Enter move:

```

## Contributing

Very simple:

1. Pick an issue/new feature
2. Solve/implement it
3. Add unit tests
4. Update docs
5. Make a pull request
