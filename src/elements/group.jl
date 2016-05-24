immutable Group <: Element
  elements :: Array{Element,1}
  ports :: Dict{Symbol,Node}
end
Group() = Group([],Dict{Symbol,Node}())
Group(e) = Group(e,Dict{Symbol,Node}())
elements(g::Group) = g.elements
elements!(g::Group, e::Element) = g.elements = e
ports(g::Group) = g.ports
ports!(g::Group, p::Dict{Symbol,Node}) = g.ports = p

Base.push!(group::Group, element::Element) = push!(group.elements, element)

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

function transform!(group::Group, tm::Array{Float64,4})
  for element in group 
    transform!(element,tm)
  end
  return nothing
end

function transform(group::Group, tm::Array{Float64,4})
  result = Group([])
  for element in group 
    push!(group,transform(element,tm))
  end
  return result
end