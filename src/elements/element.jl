export transform, transform!, Element
"""
Subtypes of `Element` `show` FastHenry commands.

Geometric transformations can be preformed on elements with `transform`.
Elements which require a name will automatically generate unique names if
no name is provided.  Groups of elements are elements.
"""
abstract Element

function transform{T<:Number}(x::Element, tm::Array{T,2})
  newx = deepcopy(x)
  transform!(newx,tm)
  return newx
end

transform!{T<:Number}(::Element, ::Array{T,2}) = nothing
function transform!{T<:Element}(x::Array{T,1}, tm::Array{Float64,2})
  for i in eachindex(x)
    transform!(x[i],tm)
  end
  return nothing
end
"""
    transform{T<Number}(x::Element, tm::Array{T,2})
    transform!{T<Number}(::Element, tm::Array{T,2})

Transform (rotate, translate, scale, etc...) a element by 4x4
[transform matrix](# http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html)
 `tm`.

Transform will modify the coordinates of `Element`s and the `wx`, `wy`, and `wz`
parameters of `Segment`.  `transform` of a `Segment` will not modify its `Node`s.
`transform` a `Group` containing the `Node`s and `Segment` instead.

Typically `transform` would only be applied to `Group` objects.
"""
transform, transform!

include("title.jl")
include("node.jl")
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

include("traversetree.jl")
include("showelement.jl")
include("visualizedata.jl")
include("plotdata.jl")
