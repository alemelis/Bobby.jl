# Streaming PGN reader.
# Parses SAN movetext into UCI strings by replaying moves through Bobby's own
# move generator — disambiguation is resolved for free.
#
# Public API:
#   read_pgn(io::IO)  → Channel{Tuple{Dict{String,String}, Vector{String}}}
#   san_to_uci(board, san) → String (UCI move)
#   move_to_uci(m::Move)   → String

# ── Move → UCI ────────────────────────────────────────────────────────────────

function move_to_uci(m::Move)::String
    promo = m.promotion == PIECE_NONE ? "" :
            m.promotion == PIECE_QUEEN  ? "q" :
            m.promotion == PIECE_ROOK   ? "r" :
            m.promotion == PIECE_BISHOP ? "b" : "n"
    sq2pgn(m.from) * sq2pgn(m.to) * promo
end

# ── SAN → UCI (single move) ───────────────────────────────────────────────────

const _SAN_PIECE = Dict{Char,UInt8}(
    'N' => PIECE_KNIGHT, 'B' => PIECE_BISHOP, 'R' => PIECE_ROOK,
    'Q' => PIECE_QUEEN,  'K' => PIECE_KING,
)

function san_to_uci(board::Board, san::AbstractString)::String
    s = strip(san)
    # Strip check/checkmate suffix and annotation glyphs
    s = rstrip(s, ('+', '#', '!', '?'))
    isempty(s) && error("Empty SAN token")

    # Castling
    if s == "O-O-O" || s == "0-0-0"
        return board.active ? "e1c1" : "e8c8"
    elseif s == "O-O" || s == "0-0"
        return board.active ? "e1g1" : "e8g8"
    end

    legal = getMoves(board, board.active)

    # Parse promotion (e.g. "e8=Q" or "e8Q")
    promo = PIECE_NONE
    if length(s) >= 2
        c = s[end]
        if c in ('Q','R','B','N')
            promo = _SAN_PIECE[c]
            s = s[1:end-1]
            startswith(s, "=") && (s = s[2:end]; s = san[1:end-1])  # handle "=Q" suffix
        elseif length(s) >= 3 && s[end-1] == '='
            promo = _SAN_PIECE[s[end]]
            s = s[1:end-2]
        end
    end

    # Is it a pawn or piece move?
    piece_type::UInt8 = PIECE_PAWN
    if !isempty(s) && haskey(_SAN_PIECE, s[1])
        piece_type = _SAN_PIECE[s[1]]
        s = s[2:end]
    end

    # Strip 'x' (capture indicator — doesn't change move identity)
    s = replace(s, 'x' => "")

    # Now s is [disambig][dest], e.g. "e4", "de4", "d4e5", "df3"
    length(s) < 2 && error("Cannot parse destination from SAN: $san")

    dest_str = s[end-1:end]
    haskey(PGN2UINT, dest_str) || error("Bad destination square '$dest_str' in SAN: $san")
    dest_sq = PGN2UINT[dest_str]

    disambig = s[1:end-2]  # may be "" / file-char / rank-char / full-square

    # Filter legal moves
    candidates = filter(legal.moves) do m
        m.to != dest_sq && return false
        m.type != piece_type && return false
        m.promotion != promo && return false
        if !isempty(disambig)
            from_name = sq2pgn(m.from)
            if length(disambig) == 2
                from_name != disambig && return false
            elseif disambig[1] in ('a':'h')
                from_name[1] != disambig[1] && return false
            else  # rank digit
                from_name[2] != disambig[1] && return false
            end
        end
        true
    end

    length(candidates) == 1 || error("SAN '$san' matches $(length(candidates)) legal moves (board: $(board.active ? "white" : "black") to move)")

    move_to_uci(candidates[1])
end

# ── PGN streaming reader ──────────────────────────────────────────────────────

# Yield (headers::Dict{String,String}, uci_moves::Vector{String}) for each game.
# Silently skips games that produce parse errors so a malformed game doesn't
# abort the whole file.
function read_pgn(io::IO)::Channel{Tuple{Dict{String,String},Vector{String}}}
    Channel{Tuple{Dict{String,String},Vector{String}}}(; ctype=Tuple{Dict{String,String},Vector{String}}, csize=0) do ch
        headers   = Dict{String,String}()
        movetext  = IOBuffer()
        in_header = false

        flush_game = function()
            isempty(headers) && seekstart(movetext) == nothing && return
            mt = String(take!(copy(movetext)))
            uci_moves = try
                _parse_movetext(mt, get(headers, "FEN", nothing))
            catch e
                String[]
            end
            if !isempty(uci_moves)
                put!(ch, (copy(headers), uci_moves))
            end
            empty!(headers)
            take!(movetext)  # reset buffer
        end

        for raw_line in eachline(io)
            line = strip(raw_line)

            if startswith(line, "[")
                # Entering header section
                m = match(r"^\[(\w+)\s+\"(.*)\"\]$", line)
                if m !== nothing
                    # If we had movetext buffered, flush the previous game
                    if position(movetext) > 0
                        flush_game()
                    end
                    headers[m.captures[1]] = m.captures[2]
                end

            elseif isempty(line)
                # Blank line ends movetext block
                if position(movetext) > 0
                    flush_game()
                end

            else
                # Movetext line
                print(movetext, " ", line)
            end
        end

        # Flush last game
        if position(movetext) > 0
            flush_game()
        end
    end
end

# Parse a PGN movetext string into a vector of UCI move strings.
function _parse_movetext(movetext::AbstractString, start_fen::Union{Nothing,String})::Vector{String}
    board = start_fen === nothing ? setBoard() : loadFen(start_fen)
    uci_moves = String[]

    # Strip comments ({...} and ;...) and variation parentheses
    text = replace(movetext, r"\{[^}]*\}" => " ")
    text = replace(text, r";[^\n]*"        => " ")
    text = replace(text, r"\([^)]*\)"      => " ")

    # Tokenise: skip move numbers (digit...'.') and result tokens
    skip = Set(["1-0", "0-1", "1/2-1/2", "*"])
    for tok in split(text)
        isempty(tok) && continue
        tok in skip && break
        # Move-number tokens: "1." "12." "1..." "12..."
        all(c -> isdigit(c) || c == '.', tok) && continue

        uci = san_to_uci(board, tok)
        push!(uci_moves, uci)

        m = uciMoveToMove(board, uci)
        board = makeMove(board, m)
    end
    uci_moves
end
