export Equiv

immutable Equiv <: Element
  nodes :: Array{Node,1}
end

function printfh!(io::IO, pfh::PrintFH, x::Equiv)
  print(io,".equiv")
  for node in x.nodes
    print(io," N",autoname!(pfh, node.name))
  end
  println(io)
  return nothing
end