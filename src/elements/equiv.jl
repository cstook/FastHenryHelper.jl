immutable Equiv <: Element
  nodes :: Array{Node,1}
end
Equiv(args...) = Equiv([args])

function fhprint(io::IO, x::Equiv, ::AutoName)
  print(io,".equiv")
  for node in x.nodes
    println(io," ",string(node.name))
  end
  return nothing
end