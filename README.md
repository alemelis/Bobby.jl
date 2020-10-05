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

You can't really play against Bobby yet, if you want to play a proper game try [Chess.jl](https://github.com/abahm/Chess.jl). However, you can compute the [perft](https://www.chessprogramming.org/Perft_Results) from any valid position. In the case of the starting position

```
julia> using Bobby

julia> b = Bobby.setBoard();

julia> pt = Bobby.perft(b, 5);

julia> pt.nodes

5-element Array{Int64,1}:
      20
     400
    8902
  197281
 4865609
```

You can also import the position from its FEN

```
julia> b = Bobby.loadFen("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0");

julia> Bobby.plainPrint(b)

   ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 8 █Π ⋅ ⋅ ⋅ + ⋅ ⋅ Π █
 7 █o ⋅ o o Ψ o Δ ⋅ █
 6 █Δ ζ ⋅ ⋅ o ζ o ⋅ █
 5 █⋅ ⋅ ⋅ o ζ ⋅ ⋅ ⋅ █
 4 █⋅ o ⋅ ⋅ o ⋅ ⋅ ⋅ █
 3 █⋅ ⋅ ζ ⋅ ⋅ Ψ ⋅ o █
 2 █o o o Δ Δ o o o █
 1 █Π ⋅ ⋅ ⋅ + ⋅ ⋅ Π █
   ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
    a b c d e f g h 

julia> pt = Bobby.perft(b, 4).nodes

4-element Array{Int64,1}:
      48
    2039
   97862
 4085603
```
