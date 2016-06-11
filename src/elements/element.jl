export transform, transform!, Element
"""
Subtypes of `Element` `show` FastHenry commands.

Geometric transformations can be preformed on elements with `transform`.
Elements which require a name will automatically generate unique names if 
no name is provided.  Groups of elements are elements.
"""
abstract Element

type AutoName
  name :: Symbol
  iname :: Int
  AutoName(x) = new(Symbol(x),0)
end
function reset!(x::AutoName)
  x.iname =0
  return nothing
end

type PrintFH
  nextname  :: Int
  usednames :: Set{AbstractString}
  function PrintFH(e::Element)
    resetiname!(e)
    new(1,Set{AbstractString}())
  end
end

checkduplicatename(pfh::PrintFH, name::AbstractString) = nothing

function autoname!(pfh::PrintFH, an::AutoName)
  if an.iname != 0  # already got an autoname
    return string("_",an.iname)
  end
  if an.name == :null # needs an autoname
    name = string("_",pfh.nextname)
    an.iname = pfh.nextname
    pfh.nextname += 1
  else  # user specified name
    name = string(an.name)
  end
  checkduplicatename(pfh, name)
  push!(pfh.usednames, name)
  return name
end

printfh!(::IO, ::PrintFH, ::Element) = nothing
printfh(io::IO, e::Element) = printfh!(io, PrintFH(e), e)
printfh(io::Element) = printfh(STDOUT,io)
Base.show(io::IO, e::Element) = printfh(io,e)

function transform{T<:Number}(x::Element, tm::Array{T,2})
  newx = elementcopy(x)
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
resetiname!(::Element) = nothing
resetist!(n::Element) = nothing

type PlotData
  title :: AbstractString
  x :: Array{Float64,1}
  y :: Array{Float64,1}
  z :: Array{Float64,1}
  group :: Array{Int,1}
  marker :: Array{Symbol,1}
  groupcounter :: Int
  PlotData() = new("",[],[],[],[],[],0)
end

plotdata!(::PlotData, ::Element) = nothing

function pointsatlimits!(pd::PlotData)
  lims = [minimum([pd.x pd.y pd.z]),maximum([pd.x pd.y pd.z])]
  pd.groupcounter +=1
  push!(pd.group, pd.groupcounter)
  push!(pd.marker, :none)
  push!(pd.x, lims[1])
  push!(pd.y, lims[1])
  push!(pd.z, lims[1])
  pd.groupcounter +=1
  push!(pd.group, pd.groupcounter)
  push!(pd.marker, :none)
  push!(pd.x, lims[2])
  push!(pd.y, lims[2])
  push!(pd.z, lims[2])
end

function Plots.plot(e::Element)
  pd = PlotData()
  plotdata!(pd,e)
  # pointsatlimits! and match_dimentions = true are both 
  # attempts to force xlims = ylims = zlims
  # seems to work for pyplot
  pointsatlimits!(pd)
  plot(pd.x, pd.y, pd.z, group=pd.group,
    title = pd.title,
    legend = false,
    linecolor = :blue,
    marker=transpose(pd.marker),
    markercolor = :red,
    markeralpha = 0.3)
end

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
