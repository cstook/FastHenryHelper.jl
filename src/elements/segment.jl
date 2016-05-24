
immutable Segment <: Element
  name :: AutoName
  node1 :: Node 
  node2 :: Node 
  sp :: SegmentParameters
  Segment(n, n1::Node, n2::Node, sp::SegmentParameters) = new(AutoName(n),n1,n2,sp)
end
Segment(node1::Node, node2::Node, sp::SegmentParameters) =
  Segment(:null, node1, node2, sp)

function printfh!(io::IO, pfh::PrintFH, s::Segment)
  print(io,"E",autoname!(pfh,s.name)," N",autoname!(pfh,s.node1.name)," N",autoname!(pfh,s.node2.name)," ")
  printfh!(io,pfh,s.sp)
  return nothing
end

resetiname!(x::Segment) = reset!(x.name)
