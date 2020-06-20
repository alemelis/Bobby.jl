const MASK_RANKS = [0x00000000000000ff,
                    0x000000000000ff00,
                    0x0000000000ff0000,
                    0x00000000ff000000,
                    0x000000ff00000000,
                    0x0000ff0000000000,
                    0x00ff000000000000,
                    0xff00000000000000]

const INSIDE = reduce(|, MASK_RANKS)

const MASK_FILES = [0x8080808080808080,
                    0x4040404040404040,
                    0x2020202020202020,
                    0x1010101010101010,
                    0x0808080808080808,
                    0x0404040404040404,
                    0x0202020202020202,
                    0x0101010101010101]

const CLEAR_FILE_A = 0x7f7f7f7f7f7f7f7f
const CLEAR_FILE_H = 0xfefefefefefefefe
