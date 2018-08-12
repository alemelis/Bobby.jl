using Base.Test
using Bobby

# Run tests
@time @test hello("Bobby") == "Hello Bobby!"