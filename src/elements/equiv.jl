immutable Equiv <: Element
  nodes :: Array{Node,1}
end
Equiv(args...) = Equiv([args])

function fhprint(io::IO, x::Equiv)
  print(io,".equiv")
  for node in x.nodes
    print(io," ",string(node.name))
  end
  return nothing
end