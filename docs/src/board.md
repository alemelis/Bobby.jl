# Board representation

## bitboard

In the _bitboard_ approach, the board is represented by a binary number of 64 digits with `1` indicating the presence of a piece and `0` an empty square. For example, the board starting position in [FEN](https://en.wikipedia.org/wiki/Forsyth–Edwards_Notation) notation looks like

```
rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
```

which, in binary notation reads

```
1111111111111111000000000000000000000000000000001111111111111111
```

this 64-bit number reports the location of empty/occupied squares. Similarly, we can have bitboards referring to white/black pawns, knights, bishops, queens, and kings

```
White pieces
0000000000000000000000000000000000000000000000001111111111111111

White pawns
0000000000000000000000000000000000000000000000001111111100000000

White rooks
0000000000000000000000000000000000000000000000000000000010000001

...
```

We may want to have a bitboard for all the white pieces, all the black pieces, and individual bitboards for each different color/piece combination. Hence, (at least) _6*2+2=14_ bitboards in total.

The reason why bitboards are so popular is because you can operate on them with logical operators (1-cycle operations!). For instance, given the two bitboards `white_only` and `black_only`, all the free squares are given by `free_squares = .~(white_only .| black_only)`