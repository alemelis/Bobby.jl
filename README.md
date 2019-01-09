# Bobby.jl
```
______       _     _       _      _ _ 
| ___ \     | |   | |    _(_)_   (_) |
| |_/ / ___ | |__ | |__ (_) (_)   _| |
| ___ \/ _ \| '_ \| '_ \| | | |  | | |
| |_/ / (_) | |_) | |_) | |_| |  | | |
\____/ \___/|_.__/|_.__/ \__, |. | |_|
                          __/ | _/ |  
                         |___/ |__/   
```
A mediocre chess engine written in Julia

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/alemelis/Bobby.jl.svg?branch=master)](https://travis-ci.org/alemelis/Bobby.jl)
[![codecov](https://codecov.io/gh/alemelis/Bobby.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/alemelis/Bobby.jl)

## Install

In Julia REPL

```
(v1.0) pkg> add https://github.com/alemelis/Bobby.jl
```

## Play
```
(v1.0) pkg> activate .
```

```
julia> using Bobby
julia> Bobby.play()

  o-----------------o
8 | π η Δ Ψ ➕ Δ η π |
7 | o o o o o o o o | o pawn 
6 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ | η knight 
5 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ | Δ bishop 
4 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ | π rook 
3 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ | Ψ queen 
2 | o o o o o o o o | ➕ king 
1 | π η Δ Ψ ➕ Δ η π |
  o-----------------o
    a b c d e f g h
white to move, enter source square and press enter

```

## Contributing

Very simple:

1. Pick an issue/new feature
2. Solve/implement it
3. Add unit tests
4. Update docs
5. Make a pull request
