using GLVisualize, GeometryTypes, GLAbstraction, Colors

export mesh

type VisualizeState
  nodedict    :: Dict{Node,Array{Float64,1}}
  unit        :: ASCIIString
  height      :: Float64
  width       :: Float64
  VisualizeState() = new(Dict(), "", 0.0, 0.0)
end


abstract VisualizeElement
type SegmentData <: VisualizeElement
  segment :: Segment
  n1xyz   :: Array{Float64,1}
  n2xyz   :: Array{Float64,1}
  wxyz    :: Array{Float64,1}
  height  :: Float64
  width   :: Float64
end
function SegmentData(state::VisualizeState, segment::Segment)
  n1xyz = state.nodedict[segment.node1]
  n2xyz = state.nodedict[segment.node2]
  wxyz = segment.wxwywz.xyz
  height = isnan(segment.wh.h)?state.height:segment.wh.h
  width = isnan(segment.wh.w)?state.width:segment.wh.w
  SegmentData(segment, n1xyz, n2xyz, wxyz, height, width)
end
type NodeData <: VisualizeElement
  node  :: Node
  xyz   :: Array{Float64,1}
end
function NodeData!(state::VisualizeState, node::Node)
  xyz = tometers[state.unit].*node.xyz[1:3]
  state.nodedict[node] = xyz
  NodeData(node,xyz)
end


type VisualizeData
  nodedataarray :: Array{NodeData,1}
  segmentdataarray :: Array{SegmentData,1}
  displayunit :: ASCIIString
  title       :: AbstractString
  ismeters    :: Bool # true if elements are in meters, false if in displayunit
  state       :: VisualizeState
  VisualizeData() = new([], [], "", "", true, VisualizeState())
end
visualizedata!(vd::VisualizeData, e::Element) = nothing
function visualizedata!(vd::VisualizeData, e::Units)
  if vd.displayunit == ""
    vd.displayunit = e.unitname
  end
  vd.state.unit = e.unitname
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Default)
  vd.state.height = tometers[vd.state.unit]*e.wh.h
  vd.state.width = tometers[vd.state.unit]*e.wh.w
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Segment)
  push!(vd.segmentdataarray, SegmentData(vd.state,e))
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Node)
  push!(vd.nodedataarray, NodeData!(vd.state,e))
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Title)
  vd.title = e.text
  return nothing
end
function VisualizeData(element)
  vd = VisualizeData()
  for e in element
    visualizedata!(vd,e)
  end
  return vd
end

const tometers = Dict("km"  =>1e3,
                      "m"   =>1.0,
                      "cm"  =>1e-2,
                      "mm"  =>1e-3,
                      "um"  =>1e-6,
                      "in"  =>2.54e-2,
                      "mils"=>2.54e-5,
                      ""    =>1.0)

function todisplayunit!(e::SegmentData, scale)
  e.height = scale*e.height
  e.width = scale*e.width
  return nothing
end
function todisplayunit!(e::NodeData, scale)
  for i in 1:3
    e.xyz[i] = scale*e.xyz[i]
  end
  return nothing
end
function todisplayunit!(vd::VisualizeData)
  if vd.ismeters && vd.displayunit != "m"
    scale = 1.0/tometers[vd.displayunit]
    for nodedata in vd.nodedataarray
      todisplayunit!(nodedata::NodeData, scale)
    end
    for segmentdata in vd.segmentdataarray
      todisplayunit!(segmentdata::SegmentData, scale)
    end
    vd.ismeters = false
  end
  return nothing
end

elementcolor(::SegmentData) = RGBA(0.2f0,0.2f0,1f0,0.5f0)
elementcolor(::NodeData) = RGBA(1f0,0f0,0f0,0.5f0)

function mesh(element::SegmentData, color::Colorant, ::Float32)
  n1 = element.n1xyz
  n2 = element.n2xyz
  height = element.height
  width = element.width
  wxyz = vcat(element.wxyz,1)
  v1 = (n2-n1)
  length = norm(v1)
  zangle = atan2(v1[2],v1[1])
  rot_rz = rotationmatrix_z(zangle)
  nrot_rz = rotationmatrix_z(-zangle)
  yangle = π/2+acos(v1[3]/length)
  rot_ry = rotationmatrix_y(yangle)
  nrot_ry = rotationmatrix_y(yangle)
  rot_wxyz = nrot_ry * nrot_rz * wxyz
  xangle = -atan2(rot_wxyz[3],rot_wxyz[2])
  rot_rx = rotationmatrix_x(xangle)
  mesh = GLNormalMesh((HyperRectangle(Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),Vec3f0(length,width,height)),color))
  c = n1 + v1./2
  segmentcorrection = translationmatrix(Vec3f0(c...)) * rot_rz * rot_ry * rot_rx
  segmentcorrection * mesh
end
function mesh(n::NodeData, color::Colorant, size::Float32)
  GLNormalMesh((HyperSphere(Point3f0(n.xyz[1],n.xyz[2],n.xyz[3]), size), color))
end

update_min_hw!(::VisualizeElement, ::Array{Float32,1}) = nothing
function update_min_hw!(segmentdata::SegmentData,  minhw::Array{Float32,1})
  if segmentdata.height < minhw[2]
    minhw[2] = Float32(segmentdata.height)
  end
  if segmentdata.width < minhw[1]
    minhw[1] = Float32(segmentdata.width)
  end
  return nothing
end
function nodesize(vd::VisualizeData)
  minhw = [Inf32,Inf32]
  for segmentdata in vd.segmentdataarray
    update_min_hw!(segmentdata, minhw)
  end
  return  min(minhw...)/6.0f0
end

function mesh(element::Element)
  # collect data for visualization
  vd = VisualizeData(element)
  if length(vd.nodedataarray)<1 && length(vd.segmentdataarray)<1
    throw(ArgumentError("No visualization for arguments.  Try passing Node's and Segment's"))
  end
  todisplayunit!(vd) # convert to display units
  # collect
  allmesh = Array(HomogenousMesh,0)
  ns = nodesize(vd)
  for nodedata in vd.nodedataarray
    m = mesh(nodedata, elementcolor(nodedata), ns)
    push!(allmesh,m)
  end
  for segmentdata in vd.segmentdataarray
    m = mesh(segmentdata, elementcolor(segmentdata), ns)
    push!(allmesh,m)
  end
  return merge(allmesh)
end
