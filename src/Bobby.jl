module Bobby

export hello, writeGame, compileGame, rmLaTeXcompilationFiles

function hello(name :: String)
    return "Hello $name\!"
end

include("xskak.jl")

end
