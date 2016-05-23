abstract Element

printfh(::IO, ::Element) = nothing
printfh(x::Element) = printfh(STDOUT,x)
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
