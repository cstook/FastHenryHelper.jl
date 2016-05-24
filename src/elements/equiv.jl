immutable Equiv <: Element
  nodes :: Array{Node,1}
end

function fhprint!(io::IO, pfh::PrintFH, x::Equiv)
  print(io,".equiv")
  for node in x.nodes
    println(io," ",autoname!(pfh, node.name))
  end
  return nothing
end