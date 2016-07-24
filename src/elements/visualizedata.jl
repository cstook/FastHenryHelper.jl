using GLVisualize: GLNormalMesh
using GeometryTypes: HyperRectangle, HyperSphere, HomogenousMesh
using GLAbstraction: rotationmatrix_x, rotationmatrix_y, rotationmatrix_z,
      translationmatrix, Point3f0, Vec3f0
using Colors: Colorant, RGBA, red, green, blue

export mesh, mesharray

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
  height = isnan(segment.wh.h) ? state.height : tometers[state.unit]*segment.wh.h
  width = isnan(segment.wh.w) ? state.width : tometers[state.unit]*segment.wh.w
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
type PlaneData <: VisualizeElement
  plane :: UniformPlane
  c1    :: Array{Float64,1}
  c2    :: Array{Float64,1}
  c3    :: Array{Float64,1}
  thick :: Float64
  node_xyz :: Array{Float64,2}
end
function PlaneData(state::VisualizeState, up::UniformPlane)
  c1 = tometers[state.unit].*up.corner1[1:3]
  c2 = tometers[state.unit].*up.corner2[1:3]
  c3 = tometers[state.unit].*up.corner3[1:3]
  thick = tometers[state.unit].*up.thick
  node_xyz = Array(Float64,3,length(up.nodes))
  for i in eachindex(up.nodes)
    node_xyz[:,i] = tometers[state.unit].*up.nodes[i].xyz[1:3]
  end
  PlaneData(up, c1, c2, c3, thick, node_xyz)
end
c1(x::PlaneData) = x.c1
c2(x::PlaneData) = x.c2
c3(x::PlaneData) = x.c3
lxyz(x::PlaneData) = x.c1[1:3] - x.c2[1:3]
wxyz(x::PlaneData) = x.c3[1:3] - x.c2[1:3]
function center(x::PlaneData)
  center = Array(Float64,3)
  for i in 1:3
    center[i] = (x.c1[i] + x.c3[i])/2.0
  end
  return center
end
plane_thick(x::PlaneData) = x.thick
plane_width(x::PlaneData) = norm(wxyz(x))
plane_length(x::PlaneData) = norm(lxyz(x))
node_xyz(x::PlaneData) = x.node_xyz
# vector perpendicular to plane, length 1/2 thickness
function halfthickperp(x::PlaneData)
  perp = cross(wxyz(x),lxyz(x))
  return perp * (0.5*plane_thick(x)/norm(perp))
end

type VisualizeData
  nodedataarray :: Array{NodeData,1}
  segmentdataarray :: Array{SegmentData,1}
  planedataarray :: Array{PlaneData,1}
  displayunit :: ASCIIString
  title       :: AbstractString
  ismeters    :: Bool # true if elements are in meters, false if in displayunit
  state       :: VisualizeState
  VisualizeData() = new([], [], [], "", "", true, VisualizeState())
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
function visualizedata!(vd::VisualizeData, e::UniformPlane)
  push!(vd.planedataarray, PlaneData(vd.state,e))
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
  e.height = scale * e.height
  e.width = scale * e.width
  return nothing
end
function todisplayunit!(e::NodeData, scale)
  for i in 1:3
    e.xyz[i] = scale * e.xyz[i]
  end
  return nothing
end
function todisplayunit!(e::PlaneData, scale)
  e.c1 = scale .* e.c1
  e.c2 = scale .* e.c2
  e.c3 = scale .* e.c3
  e.thick = scale .* e.thick
  for i in 1:size(e.node_xyz)[2]
    e.node_xyz[:,i] = scale .* e.node_xyz[:,i]
  end
end
function todisplayunit!(vd::VisualizeData)
  if vd.ismeters && vd.displayunit != "m"
    scale = 1.0/tometers[vd.displayunit]
    arraylist = (vd.nodedataarray, vd.segmentdataarray, vd.planedataarray)
    for a in arraylist
      for data in a
        todisplayunit!(data, scale)
      end
    end
    vd.ismeters = false
  end
  return nothing
end

elementcolor(::SegmentData) = RGBA(0.2f0, 0.2f0, 1.0f0, 0.5f0)
elementcolor(::NodeData)    = RGBA(1.0f0, 0.0f0, 0.0f0, 0.5f0)
elementcolor(::PlaneData)   = RGBA(0.0f0, 1.0f0, 0.0f0, 0.2f0)

function rxyz(lengthvector::Array{Float64,1}, widthvector::Array{Float64,1})
  zangle = atan2(lengthvector[2],lengthvector[1])
  rot_rz = rotationmatrix_z(zangle)
  nrot_rz = rotationmatrix_z(-zangle)
  yangle = π/2+acos(lengthvector[3]/norm(lengthvector))
  rot_ry = rotationmatrix_y(yangle)
  nrot_ry = rotationmatrix_y(-yangle)
  rot_wxyz = nrot_ry * nrot_rz * vcat(widthvector,1.0)
  xangle = atan2(rot_wxyz[3],rot_wxyz[2])
  rot_rx = rotationmatrix_x(xangle)
  return rot_rz * rot_ry * rot_rx
end

function mesharray(element::PlaneData, color::Colorant, nodesize::Float32)
  planenodecolor = RGBA(red(color), green(color), blue(color), 0.5f0)
  length = plane_length(element)
  width = plane_width(element)
  height = plane_thick(element)
  c = center(element)
  uncorrectedplanemesh = GLNormalMesh((
    HyperRectangle(
      Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),
      Vec3f0(length,width,height)),color
  ))
  correction =
    translationmatrix(Vec3f0(c...)) *
    rxyz(lxyz(element),wxyz(element))
  planemesh = Array(HomogenousMesh,0)
  push!(planemesh, correction * uncorrectedplanemesh) # the plane
  for i in 1:size(node_xyz(element))[2] # nodes in plane
    push!(planemesh,
      GLNormalMesh((
        HyperSphere(
          Point3f0(node_xyz(element)[1,i],
            node_xyz(element)[2,i],
            node_xyz(element)[3,i]),
          nodesize),
      planenodecolor))
    )
  end
  return planemesh
end
function mesharray(element::SegmentData, color::Colorant, ::Float32)
  n1 = element.n1xyz
  n2 = element.n2xyz
  height = element.height
  width = element.width
  v1 = (n2-n1)
  length = norm(v1)
  mesh = GLNormalMesh((HyperRectangle(Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),Vec3f0(length,width,height)),color))
  c = n1 + v1./2
  returnmesh = Array(HomogenousMesh,1)
  segmentcorrection = translationmatrix(Vec3f0(c...)) * rxyz(v1, element.wxyz)
  returnmesh[1] = segmentcorrection * mesh
  return returnmesh
end
function mesharray(n::NodeData, color::Colorant, size::Float32)
  returnmesh = Array(HomogenousMesh,1)
  returnmesh[1] = GLNormalMesh((HyperSphere(Point3f0(n.xyz[1],n.xyz[2],n.xyz[3]), size), color))
  return returnmesh
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

"""
    mesharray(element)

Returns an array of `HomogenousMesh` objects for use with `GLVisualize`.

`mesharray` will accept any `Element` as it's argument, but only makes sense
 for `Group`'s.  Planes will not show their holes.
"""
function mesharray(element::Element)
  # collect data for visualization
  vd = VisualizeData(element)
  if length(vd.nodedataarray)<1 &&
     length(vd.segmentdataarray)<1 &&
     length(vd.planedataarray)<1
    throw(ArgumentError("No visualization for arguments.  Try passing Node's and Segment's"))
  end
  todisplayunit!(vd) # convert to display units
  # create meshes
  allmesh = Array(HomogenousMesh,0)
  ns = nodesize(vd)
  for nodedata in vd.nodedataarray
    m = mesharray(nodedata, elementcolor(nodedata), ns)
    append!(allmesh,m)
  end
  for segmentdata in vd.segmentdataarray
    m = mesharray(segmentdata, elementcolor(segmentdata), ns)
    append!(allmesh,m)
  end
  for planedata in vd.planedataarray
    m = mesharray(planedata, elementcolor(planedata), ns)
    append!(allmesh,m)
  end
  return allmesh
end

"""
    mesh(element)

Equivalent to `merge(mesharray(element))`.

Use the following to visualize `element`.
```
m = mesh(element)

using GLVisualize
window = glscreen()
view(visualize(m), window)
renderloop(window)
```
"""
mesh(element::Element) = merge(mesharray(element))
