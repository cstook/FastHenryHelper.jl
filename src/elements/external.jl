export External

"""
    External(n1::Node, n2::Node, [portname::AbstractString])

`External` objects `show` a FastHenry .external command.
"""
immutable External <: Element
  node1 :: Node
  node2 :: Node
  portname :: AbstractString
  External(n1::Node, n2::Node, portname::AbstractString = "") =
      new(n1,n2,portname)
end

function Base.show(io::IO, x::External, autoname = AutoName())
  update!(autoname, x.node1)
  update!(autoname, x.node2)
  print(io, ".external N")
  print(io, autoname.namedict[x.node1])
  print(io," N")
  print(io, autoname.namedict[x.node2])
  println(io," ",x.portname)
  return nothing
end
