export External

immutable External <: Element
  node1 :: Node
  node2 :: Node 
  portname :: String
end

External(n1,n2) = External(n1,n2,"")

function printfh!(io::IO, pfh::PrintFH, x::External)
  println(io, ".External ",autoname!(pfh,x.node1.name)," ",autoname!(pfh,x.node2.name)," ",x.portname)
  return nothing
end