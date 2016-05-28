export External

"""
    External(n1::Node, n2::Node, [portname::String])

`External` objects `show` a FastHenry .external command.
"""
immutable External <: Element
  node1 :: Node
  node2 :: Node 
  portname :: String
  External(n1::Node, n2::Node, portname::String = "") = new(n1,n2,portname)
end

function printfh!(io::IO, pfh::PrintFH, x::External)
  println(io, ".external N",autoname!(pfh,x.node1.name)," N",autoname!(pfh,x.node2.name)," ",x.portname)
  return nothing
end