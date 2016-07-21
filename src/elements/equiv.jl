export Equiv

"""
    Equiv(nodes::Array{Node,1})

`Equiv` objects `show` a FastHenry .equiv command
"""
immutable Equiv <: Element
  nodes :: Array{Node,1}
end

function Base.show(io::IO, x::Equiv; autoname = AutoName())
  print(io,".equiv")
  for node in x.nodes
    update!(autoname, node)
    print(io," N",autoname.namedict[node])
  end
  println(io)
  return nothing
end
