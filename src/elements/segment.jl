export Segment

immutable Segment <: Element
  name :: AutoName
  node1 :: Node 
  node2 :: Node 
  sp :: SegmentParameters
  Segment(n, n1::Node, n2::Node, sp::SegmentParameters) = new(AutoName(n),n1,n2,deepcopy(sp))
end
Segment(n1::Node, n2::Node, sp::SegmentParameters=SegmentParameters()) = 
  Segment(:null, n1, n2, sp)

function printfh!(io::IO, pfh::PrintFH, s::Segment)
  print(io,"E",autoname!(pfh,s.name)," N",autoname!(pfh,s.node1.name)," N",autoname!(pfh,s.node2.name)," ")
  printfh!(io,pfh,s.sp)
  return nothing
end

resetiname!(x::Segment) = reset!(x.name)

function preparesegment!(s::Segment)
  if isnan(s.sp.wx) && isnan(s.sp.wy) && isnan(s.sp.wz)
    n1 = s.node1.xyz[1:3]
    n2 = s.node2.xyz[1:3]
    v1 = n2-n1
    v2 = [0,0,1]
    w = cross(v1,v2/norm(v2,3))
    if norm(w) < 1e-10  # close to 0
      v2 = [0,1,0]
      w = cross(v1,v2/norm(v2,3))
    end
    s.sp.wx = w[1]
    s.sp.wy = w[2]
    s.sp.wz = w[3]
  end
  return nothing
end

function transform!(s::Segment, tm::Array{Float64,2})
  preparesegment!(s)
  transform!(node1,tm)
  transform!(node2,tm)
  wx = s.sp.wx
  wy = s.sp.wy
  wz = s.sp.wz
  x = tm*[wx, wy, wz, 1.0]
  wx = x[1]
  wy = x[2]
  wz = x[3]
  return nothing
end

function transform(s::Segment, tm::Array{Float64,2})
  news = deepcopy(s)
  transform!(news)
end