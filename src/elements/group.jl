immutable Group <: Element
  elements :: Array{Element,1}
end

Base.push!(group::Group, element::Element) = push!(group.elements, element)

function printfh(io::IO, group::Group)
  for element in group 
    printfh(io, element)
  end
  return nothing
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