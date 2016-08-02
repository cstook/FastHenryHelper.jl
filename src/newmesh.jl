using GLVisualize: GLNormalMesh
using GeometryTypes: HyperRectangle, HyperSphere, HomogenousMesh
using GLAbstraction: rotationmatrix_x, rotationmatrix_y, rotationmatrix_z,
      translationmatrix, Point3f0, Vec3f0
using Colors: Colorant, RGBA, red, green, blue

# export newmesh

immutable ColorScheme
  segment   ::Colorant
  node      ::Colorant
  plane     ::Colorant
  planenode ::Colorant
end
const colorscheme = ColorScheme(
  RGBA(0.2f0, 0.2f0, 1.0f0, 0.5f0),
  RGBA(1.0f0, 0.0f0, 0.0f0, 0.5f0),
  RGBA(0.0f0, 1.0f0, 0.0f0, 0.2f0),
  RGBA(0.0f0, 1.0f0, 0.0f0, 0.5f0)
)

immutable VisualizationParameters
  colorscheme :: colorscheme
  nodesize :: Float32
end

function nodesize(element::Element, cd::Dict{Element,Context})
  mindim = Inf32
  for e in element
    update_mindim!(mindim, e, cd)
  end
  return mindim/6.0f0
end
update_mindim!(::Float32, ::Element, ::Dict{Element,Context}) = nothing
function update_mindim!(mindim::Float32, s::Segment, cd::Dict{Element,Context})
  (w,h) = width_height(s,cd)
  mindim = mindim<w ? mindim : w
  mindim = mindim<h ? mindim : h
end

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

function nodemesh(xyz::Array{Float64,1}, size::Float32, color::Colorant)
  GLNormalMesh((HyperSphere(Point3f0(xyz[1],xyz[2],xyz[3]), size), color))
end

function appendmesh!(allmesh::HomogenousMesh,
                     node::Node,
                     cd::Dict{Element,Context},
                     vp::VisualizationParameters)
  push!(allmesh, nodemesh(xyz1(node,cd)[1:3], vp.nodesize, vp.colorscheme.node))
  return nothing
end

length(a::Array{Float64,1}, b::Array{Float64,1}) = norm(b[1:3]-a[1:3])
center(a::Array{Float64,1}, b::Array{Float64,1}) = a[1:3] + (b[1:3]-a[1:3])./2

function appendmesh!(allmesh::HomogenousMesh,
                     segment::Segment,
                     cd::Dict{Element,Context},
                     vp::VisualizationParameters)
   (n1_xyz1,n2_xyz1) = nodes_xyz1(segment, cd)
   n1 = n1_xyz1[1:3]
   n2 = n2_xyz1[1:3]
   (width,height) = width_height(segment, cd)
   lengthvector= (n2-n1)
   length = norm(lengthvector)
   mesh = GLNormalMesh((
            HyperRectangle(
              Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),
              Vec3f0(length,width,height)
            ),
          color))
   c = n1 + v1./2
   correction = translationmatrix(Vec3f0(c...))*
                rxyz(lengthvector, wxyz(segment,cd))
   push!(allmesh, correction*mesh)
   return returnmesh
end

function appendmesh!(allmesh::HomogenousMesh,
                     plane::UniformPlane,
                     cd::Dict{Element,Context},
                     vp::VisualizationParameters)
  (c1,c2,c3,thick) = corners_xyz1_thick(plane, cd)
  lxyz = c1[1:3]-c2[1:3]
  length = norm(lxyz)
  wxyz = c3[1:3]-c2[1:3]
  width = norm(wxyz)
  height = thick
  center = center(c1,c3)
  uncorrectedplanemesh = GLNormalMesh((
    HyperRectangle(
      Vec3f0(-0.5f0*length,-0.5f0*width,-0.5f0*height),
      Vec3f0(length,width,height)),vp.colorscheme.plane
  ))
  correction =
    translationmatrix(Vec3f0(center...)) *
    rxyz(lxyz,wxyz)
  push!(allmesh, correction * uncorrectedplanemesh)
  for xyz1 in nodes_xyz1(plane, cd)
    push!(allmesh, nodemesh(xyz1[1:3],vp.nodesize, vp.colorscheme.planenode))
  end
  return nothing
end

"""
    mesharray(element)

Returns an array of `HomogenousMesh` objects for use with `GLVisualize`.

`mesharray` will accept any `Element` as it's argument, but only makes sense
 for `Group`'s.  Planes will not show their holes.
"""
function new_mesharray(element::Element)
  cd = contextdict(element)
  vp = VisualizationParameters(colorscheme, nodesize(element,cd))
  allmesh = Array(HomogenousMesh,0)
  for e in element
    appendmesh!(allmesh,e,cd,vp)
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
new_mesh(element::Element) = merge(new_mesharray(element))