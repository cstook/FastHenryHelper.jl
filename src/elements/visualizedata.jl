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

function mesh(element::Element)
  allmesh = Array(HomogenousMesh,0)
  for e in element
    mesh = GLNormalMesh((e,elementcolor(e)))
    if mesh != nothing
      push!(allmesh,mesh)
    end
  end
  if length(allmesh)>0
    return merge(allmesh)
  else
    return nothing
  end
end
