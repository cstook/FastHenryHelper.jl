using GLVisualize, GeometryTypes, GLAbstraction, Colors

export mesh

GeometryTypes.GLNormalMesh(::Tuple{Element,Colorant}) = nothing
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

elementcolor(::Segment) = RGBA(0.2f0,0.2f0,1f0,0.5f0)
elementcolor(::Node) = RGBA(1f0,0f0,0f0,0.5f0)
elementcolor(::Element) = nothing

updatexyzminmax!(xyzminmax, e::Element) = nothing
function updatexyzminmax!(xyzminmax, n::Node)
  for i in 1:3
    if xyzminmax[i,1]>n.xyz[i]
      xyzminmax[i,1]=n.xyz[i]
    end
    if xyzminmax[i,2]<n.xyz[i]
      xyzminmax[i,2]=n.xyz[i]
    end
  end
  return nothing
end
centerxyzminmax(x) = ((x[1,1]+x[1,2])/2, (x[2,1]+x[2,2])/2, (x[3,1]+x[3,2])/2)

function mesh(element::Element)
  xyzminmax =  [0.0 0.0; 0.0 0.0; 0.0 0.0]
  allmesh = Array(HomogenousMesh,0)
  for e in element
    mesh = GLNormalMesh((e,elementcolor(e)))
    if mesh != nothing
      push!(allmesh,mesh)
      updatexyzminmax!(xyzminmax,e)
    end
  end
  if length(allmesh)>0
    mergedmesh = merge(allmesh)
    centertm = translationmatrix(Vec3f0(centerxyzminmax(xyzminmax)...))
    return centertm * mergedmesh
  else
    return nothing
  end
end
