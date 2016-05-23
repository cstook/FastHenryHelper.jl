
type Segment <: element
  name :: Symbol
  node1 :: Node 
  node2 :: Node 
  sp :: SegmentParameters
end

function printfh(io,::IO, s::Segment)
  print(io,"S",string(name)," ",string(s.node1.name)," ",string(s.node2.name)," ")
  printfh(io,s.sp)
  return nothing
end


