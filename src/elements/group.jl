export Group

immutable Group <: Element
  elements :: Array{Element,1}
  terms :: Dict{Symbol,Node}
end
Group() = Group([],Dict{Symbol,Node}())
Group(e) = Group(e,Dict{Symbol,Node}())
elements(g::Group) = g.elements
elements!(g::Group, e::Element) = g.elements = e
terms(g::Group) = g.terms
terms!(g::Group, p::Dict{Symbol,Node}) = g.terms = p

Base.getindex(g::Group, key::Symbol) = g.terms[key]
function Base.setindex!(g::Group, n::Node, key::Symbol)
  g.terms[key] = n
  return nothing
end

function printfh!(io::IO, pfh::PrintFH, group::Group)
  for element in group.elements 
    printfh!(io, pfh, element)
  end
  return nothing
end

function resetiname!(group::Group)
  for element in group.elements 
    resetiname!(element)
  end
end

function transform!(group::Group, tm::Array{Float64,2})
  for element in group.elements 
    transform!(element,tm)
  end
  return nothing
end

function transform(group::Group, tm::Array{Float64,2})
  newgroup = deepcopy(group)
  transform!(newgroup,tm)
  return newgroup
end

