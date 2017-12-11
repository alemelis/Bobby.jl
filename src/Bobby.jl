module Bobby

export hello

function hello(name :: String)
    return "Hello $name"
end

include("xskak.jl")

end
