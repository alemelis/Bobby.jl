# Bobby.jl
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
8 | r n b q k b n r |
7 | p p p p p p p p |
6 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ |
5 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ |
4 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ |
3 | ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ ⋅ |
2 | P P P P P P P P |
1 | R N B Q K B N R |
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
