immutable External <: Element
  node1 :: Node
  node2 :: Node 
  portname :: String
end

function printfh(io::IO, x::External)
  println(io, ".External ",string(x.node1.name)," ",string(x.node2.name)," ",x.portname)
  return nothing
end