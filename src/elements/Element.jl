export transform, transform!

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
  usednames :: Set{String}
  function PrintFH(e::Element)
    resetiname!(e)
    new(1,Set{String}())
  end
end

checkduplicatename(pfh::PrintFH, name::String) = nothing

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
transform(x::Element, ::Any) = x
transform!(::Element, ::Any) = nothing
function transform!{T<:Element}(x::Array{T,1}, tm::Array{Float64,2})
  for i in eachindex(x)
    transform!(x[i],tm)
  end
  return nothing
end
resetiname!(::Element) = nothing
resetist!(n::Element) = nothing


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
