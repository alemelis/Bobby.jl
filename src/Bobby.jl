module Bobby

using FileIO
using Compose
using PyCall

export hello, writeGame, compileGame, rmLaTeXcompilationFiles, drawBoard

function hello(name :: String)
    return "Hello $name\!"
end

include("xskak.jl")
include("renderer.jl")
include("pychess.jl")
include("parser.jl")
end
