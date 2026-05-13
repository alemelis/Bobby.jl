const HAS_BMI2 = try
    Sys.islinux() ? occursin("bmi2", read("/proc/cpuinfo", String)) :
    Sys.isapple() ? occursin("BMI2", read(`sysctl -n machdep.cpu.features`, String)) :
    false
catch; false end

# "target-features"="+bmi2" is required — LLVM won't emit the BMI2 instruction without it.
@inline function pext(src::UInt64, mask::UInt64)::UInt64
    Base.llvmcall(
        ("""
        declare i64 @llvm.x86.bmi.pext.64(i64, i64)
        define i64 @entry(i64 %src, i64 %mask) #0 {
            %r = call i64 @llvm.x86.bmi.pext.64(i64 %src, i64 %mask)
            ret i64 %r
        }
        attributes #0 = { "target-features"="+bmi2" }
        """, "entry"),
        UInt64, Tuple{UInt64, UInt64}, src, mask
    )
end

# Flat (fancy-PEXT) layout: one contiguous Vector{UInt64} per piece type with per-square
# base offsets. One indirection per lookup instead of two, and entries are cache-contiguous.
function buildFlatPextTable(rook::Bool)
    masks   = rook ? ROOK_MASKS : BISHOP_MASKS
    slider  = rook ? orthoAttack : diagoAttack
    offsets = Vector{UInt32}(undef, 64)
    total = 0
    for idx in 1:64
        offsets[idx] = UInt32(total)
        total += 1 << count_ones(masks[idx])
    end
    table = Vector{UInt64}(undef, total)
    for s in values(PGN2UINT)
        idx  = sq2idx(s)
        mask = masks[idx]
        base = offsets[idx]
        subset = UInt64(0)
        while true
            table[base + pext(subset, mask) + 1] = slider(s, subset)
            subset = (subset - mask) & mask
            subset == EMPTY && break
        end
    end
    return table, offsets
end

const ROOK_PEXT_TABLE,   ROOK_PEXT_OFFSETS   = HAS_BMI2 ? buildFlatPextTable(true)  : (UInt64[], UInt32[])
const BISHOP_PEXT_TABLE, BISHOP_PEXT_OFFSETS = HAS_BMI2 ? buildFlatPextTable(false) : (UInt64[], UInt32[])

@inline function getPextAttack(square::UInt64, blockers::UInt64, rook::Bool)::UInt64
    idx = sq2idx(square)
    if rook
        @inbounds return ROOK_PEXT_TABLE[ROOK_PEXT_OFFSETS[idx] + pext(blockers, ROOK_MASKS[idx]) + 1]
    else
        @inbounds return BISHOP_PEXT_TABLE[BISHOP_PEXT_OFFSETS[idx] + pext(blockers, BISHOP_MASKS[idx]) + 1]
    end
end

# HAS_BMI2 is const Bool — Julia's JIT eliminates the dead branch at compile time.
@inline function getSliderAttack(square::UInt64, blockers::UInt64, rook::Bool)::UInt64
    HAS_BMI2 ? getPextAttack(square, blockers, rook) : getMagicAttack(square, blockers, rook)
end
