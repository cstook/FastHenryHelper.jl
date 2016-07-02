using GLVisualize, GeometryTypes, GLAbstraction, Colors

export mesh

abstract VisualizeElement
type SegmentData <: VisualizeElement
  segment :: Segment
  n1xyz   :: Array{Float64,1}
  n2xyz   :: Array{Float64,1}
  wxyz    :: Array{Float64,1}
  height  :: Float64
  width   :: Float64
  function SegmentData(state::VisualizeData, segment::Segment)
    n1xyz = state.nodedict[segment.node1]
    n2xyz = state.nodedict[segment.node2]
    wxyz = segment.wxwywz.xyz
    height = tometers[state.unit]* isnan(segment.wh.h)?state.height:segment.wh.h
    width = tometers[state.unit]* isnan(segment.wh.w)?state.width:segment.wh.w
    new(segment, n1xyz, n2xyz, wxyz, height, width)
  end
end
type NodeData <: VisualizeElement
  node  :: Node
  xyz   :: Array{Float64,1}
  function NodeData!(state::VisualizeData, node::Node)
    xyz = tometers[state.unit].*node.xyz[1:3]
    state.nodedict[node] = xyz
    new(node,xyz)
  end
end
type VisualizeData
  # data
  elements    :: Array{VisualizeElement,1}
  displayunit :: ASCIIString
  title       :: AbstractString
  # state
  nodedict    :: Dict{Node,Array{Float64,1}}
  unit        :: ASCIIString
  height      :: Float64
  width       :: Float64
  ismeters    :: Boolean # true if elements are in meters, false if in displayunit
  VisualizeData() = new([], "", "", Dict(), "m", 0.0, 0.0, true)
end

visualizedata!(vd::VisualizeData, e::Element) = nothing
function visualizedata!(vd::VisualizeData, e::Units)
  if vd.displayunit == ""
    vd.displayunit = e.unitname
  end
  vd.unit = e.unitname
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Default)
  height = tometers[state.unit]*e.wh.h
  width = tometers[state.unit]*e.wh.w
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Segment)
  push!(vd.elements, SegmentData(vd,e))
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Node)
  push!(vd.elements, NodeData!(vd,e))
  return nothing
end
function visualizedata!(vd::VisualizeData, e::Title)
  vd.title = e.text
  return nothing
end
const tometers = Dict("km"  =>1e3,
                      "m"   =>1.0,
                      "cm"  =>1e-2,
                      "mm"  =>1e-3,
                      "um"  =>1e-6,
                      "in"  =>2.54e-2,
                      "mils"=>2.54e-5)

function todisplayunit!(e::SegmentData, scale)
  for i in 1:3
    e.n1xyz[i] = scale*e.n1xyz[i]
    e.nxyz[i] = scale*e.nxyz[i]
    e.height[i] = scale*e.height[i]
    e.width[i] = scale*e.width[i]
  end
  return nothing
end
function todisplayunit!(e::NodeData, scale)
  for i in 1:3
    e.xyz[i] = scale*e.xyz[i]
  end
  return nothing
end
function todisplayunit!(vd::VisualizeData)
  if vd.ismeters && displayunit!="m"
    scale = 1.0/tometers[vd.displayunit]
    for e in vd.elements
      todisplayunit!(e::VisualizeElement, scale)
    end
    vd.ismeters = false
  end
  return nothing
end

function GeometryTypes.GLNormalMesh(args::Tuple{Segment,Colorant})
  (segment,color) = args
  n1 = segment.node1.xyz[1:3]
  n2 = segment.node2.xyz[1:3]
  height = segment.wh.h
  width = segment.wh.w
  wxyz = vcat(segment.wxwywz.xyz,1)
  v1 = (n2-n1)
  length = norm(v1)
  zangle = atan2(v1[2],v1[1])
  rot_rz = rotationmatrix_z(zangle)
  nrot_rz = rotationmatrix_z(-zangle)
  yangle = π/2+acos(v1[3]/length)
  rot_ry = rotationmatrix_y(yangle)
  nrot_ry = rotationmatrix_y(yangle)
  rot_wxyz = nrot_ry * nrot_rz * wxyz
  xangle = atan2(rot_wxyz[3],rot_wxyz[2])
  rot_rx = rotationmatrix_x(xangle)
  mesh = GLNormalMesh((HyperRectangle(Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),Vec3f0(length,width,height)),color))
  c = n1 + v1./2
  segmentcorrection = translationmatrix(Vec3f0(c...)) * rot_rz * rot_ry * rot_rx
  segmentcorrection * mesh
end
function GeometryTypes.GLNormalMesh(args::Tuple{Node,Colorant})
  (n,color) = args
  GLNormalMesh((HyperSphere(Point3f0(n.xyz[1],n.xyz[2],n.xyz[3]),0.1f0), color))
end

elementcolor(::SegmentData) = RGBA(0.2f0,0.2f0,1f0,0.5f0)
elementcolor(::NodeData) = RGBA(1f0,0f0,0f0,0.5f0)

function mesh(element::SegmentData, color::Colorant, ::Float64)
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
  xangle = atan2(rot_wxyz[3],rot_wxyz[2])
  rot_rx = rotationmatrix_x(xangle)
  mesh = GLNormalMesh((HyperRectangle(Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),Vec3f0(length,width,height)),color))
  c = n1 + v1./2
  segmentcorrection = translationmatrix(Vec3f0(c...)) * rot_rz * rot_ry * rot_rx
  segmentcorrection * mesh
end
function mesh(n::NodeData, color::Colorant, size::Float64)
  GLNormalMesh((HyperSphere(Point3f0(n.xyz[1],n.xyz[2],n.xyz[3]), size), color))
end

update_min_hw!(::VisualizeElement, ::Float64, ::Float64) = nothing
function update_min_hw!(e::SegmentData,  minheight::Float64, minwidth::Float64)
  if e.height < minheight
    minheight = e.height
  end
  if e.width < minwidth
    minwidth = e.width
  end
  return nothing
end
function nodesize(vd::VisualizeData)
  minheight = 0.0
  minwidth = 0.0
  for e in vd.elements
    update_min_hw!(e, minheight, minwidth)
  end
  min_hw = min(minheight,minwidth)
  return min_hw/3.0
end

function mesh(element::Element)
  # collect data for visualization
  vd = VisualizeData()
  for e in element
    visualizedata!(vd,e)
  end
  if length(vd.elements)<1
    throw(ArgumentError("No visualization for arguments.  Try passing Node's and Segment's"))
  end
  todisplayunit!(vd) # convert to display units
  # collect
  allmesh = Array(HomogenousMesh,0)
  ns = nodesize(vd)
  for e in vd.elements
    push!(allmesh,mesh(e, elementcolor(s), ns))
  end
  return merge(allmesh)
end
