using Base.Test
using Bobby

# Run tests
@time @test include("hello_test.jl")

# @time include("skak_test.jl")

@time include("renderer_test.jl")

@time include("preprocess_test.jl")
