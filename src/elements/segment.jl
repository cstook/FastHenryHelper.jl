
immutable Segment <: Element
  name :: Symbol
  node1 :: Node 
  node2 :: Node 
  sp :: SegmentParameters
end
Segment(name, node1::Node, node2::Node, sp::SegmentParameters) =
    Segment(Symbol(name), node1, node2, sp)
Segment(node1::Node, node2::Node, sp::SegmentParameters) =
  Segment(:null, node1, node2, sp)

function printfh(io::IO, s::Segment)
  print(io,"E",string(s.name)," ",string(s.node1.name)," ",string(s.node2.name)," ")
  printfh(io,s.sp)
  return nothing
end
