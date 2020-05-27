# Bobby.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/alemelis/Bobby.jl.svg?branch=master)](https://travis-ci.org/alemelis/Bobby.jl)
[![codecov](https://codecov.io/gh/alemelis/Bobby.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/alemelis/Bobby.jl)

Bobby is a chess move validator, i.e. given a position and a candidate move, Bobby tells you whether the move is legal or not. He can also look for check/mates and stalemates.

## Features
- 64-bit [magic](https://www.chessprogramming.org/Magic_Bitboards) [bitboards](https://www.chessprogramming.org/Bitboards)
- [perft and divide](http://www.rocechess.ch/perft.html) calculation
- check check
- castling
- en-passant
- promotion

## Install

```
julia> ]add Bobby
```

## Play

You can't really play against Bobby yet, if you want to play a proper game try [Chess.jl](https://github.com/abahm/Chess.jl).
