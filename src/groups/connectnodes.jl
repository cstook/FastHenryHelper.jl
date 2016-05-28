export connectnodes

"""
    connectnodes(nodes::Array{Node,1}, [parameters::SegmentParameters])

Returns an array of `Segment`s connecting `nodes`.
"""
function connectnodes(nodes::Array{Node,1},sp::SegmentParameters = SegmentParameters())
  segments = Array(Segment,length(nodes)-1)
  for i in eachindex(segments)
    segments[i] = Segment(nodes[i],nodes[i+1],sp)
  end
  return segments
end