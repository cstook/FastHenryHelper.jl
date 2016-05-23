abstract Element

printfh(::IO, ::Element) = nothing
transform(::Element) = nothing
transform!(::Element) = nothing


include("node.jl")
include("segmentparameters.jl")
include("segment.jl")
