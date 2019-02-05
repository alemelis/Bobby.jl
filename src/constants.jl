const EMPTY = 0x0000000000000000
const FULL = 0xffffffffffffffff

const NIGHT_CLEAR_FILES = [0x3f3f3f3f3f3f3f3f, 0x7f7f7f7f7f7f7f7f,
                           0xfefefefefefefefe, 0xfcfcfcfcfcfcfcfc,
                           0xfcfcfcfcfcfcfcfc, 0xfefefefefefefefe,
                           0x7f7f7f7f7f7f7f7f, 0x3f3f3f3f3f3f3f3f]

const NIGHT_JUMPS = [-10, -17, -15, -6, 10, 17, 15, 6]

const MASK_FILE_A = 0x8080808080808080
const MASK_FILE_H = 0x0101010101010101
const CLEAR_FILE_A = 0x7f7f7f7f7f7f7f7f
const CLEAR_FILE_H = 0xfefefefefefefefe
const KING_SHIFTS = [9, 8, 7, -1, -9, -8, -7, 1]
const KING_CLEAR_FILES = [0x7f7f7f7f7f7f7f7f, 0xffffffffffffffff,
						  0xfefefefefefefefe, 0xfefefefefefefefe,
						  0xfefefefefefefefe, 0xffffffffffffffff,
						  0x7f7f7f7f7f7f7f7f, 0x7f7f7f7f7f7f7f7f]
const KING_MASK_FILES = [0x8080808080808080, 0xffffffffffffffff,
						 0x0101010101010101, 0x0101010101010101,
						 0x0101010101010101, 0xffffffffffffffff,
						 0x8080808080808080, 0x8080808080808080]

const PAWN_SQUARES = 0x00ffffffffffff00