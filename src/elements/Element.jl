abstract Element

type AutoName
  counter :: Int
end

function autoname(a::AutoName,n::Symbol)
  if n == :null
    a.counter += 1
    return string("_",a.counter)
  else
    return string(n)
  end
end

printfh(::IO, ::Element, ::AutoName) = nothing
printfh(io::IO, e::Element) = printfh(io, e, AutoName(0))
printfh(io::Element) = printfh(STDOUT,io)
transform(::Element) = nothing
transform!(::Element) = nothing

include("title.jl")
include("node.jl")
include("segmentparameters.jl")
include("segment.jl")
include("units.jl")
include("default.jl")
include("external.jl")
include("freq.jl")
include("equiv.jl")
include("end.jl")
include("uniformdiscretizedplanes.jl")
include("comment.jl")
include("group.jl")
