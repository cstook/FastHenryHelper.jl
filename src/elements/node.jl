export Node, rx, ry, rz, txyz, scalexyz

immutable Node <: Element
  name :: AutoName
  xyz  :: Array{Float64,2}
  Node(n,xyz::Array{Float64,2}) = new(AutoName(n),xyz) 
end
Node(xyz::Array{Float64,2}) = Node(:null,xyz)
Node(name,x,y,z) = Node(name,[x y z 1.0])
Node(x,y,z) = Node(:null,x,y,z)
Node(;name = :null, x=0, y=0, z=0) = Node(name,x,y,z)

function printfh!(io::IO, pfh::PrintFH, n::Node; plane = false)
  if plane
    print(io,"+ ")
  end
  print(io,"N",autoname!(pfh, n.name)," ")
  if plane
    print(io,"(")
  end
  @printf(io,"x=%.6e y=%.6e z=%.6e",n.xyz[1],n.xyz[2],n.xyz[3])
  if plane
    print(io,")")
  end
  println(io)
  return nothing
end

resetiname!(n::Node) = reset!(n.name)

import Base.+, Base.*

+(n::Node,x) = +(n.xyz,x)
*(n::Node,x) = *(n.xyz,x)

"""
    transform(node::Node, tm::Array{Float64,2})
    transform!(node::Node, tm::Array{Float64,2})

Multiply the cooridnate of `node` by the transform matrix `tm`.
"""
transform, transform!

transform(n::Node, tm::Array{Float64,2}) = Node(n.name.name,n*tm)
function transform!(n::Node, tm::Array{Float64,2})
  xyz = n*tm
  n.xyz[1:4] = xyz[1:4]
  return nothing
end

"""
    rx(α) = [1      0       0     0;
             0    cos(α)  sin(α)  0;
             0   -sin(α)  cos(α)  0;
             0      0       0     1]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle α around x axis.
"""
rx(α) = [1      0       0     0;
         0    cos(α)  sin(α)  0;
         0   -sin(α)  cos(α)  0;
         0      0       0     1]

"""
    ry(β) = [cos(β)   0    -sin(β)  0;
               0      1       0     0;
             sin(β)   0     cos(β)  0;
               0      0       0     1]


[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle β around y axis.
"""
ry(β) = [cos(β)   0    -sin(β)  0;
         0        1       0     0;
         sin(β)   0     cos(β)  0;
         0        0       0     1]

"""
    rz(γ) = [cos(γ) sin(γ) 0  0;
            -sin(γ) cos(γ) 0  0;
              0       0    1  0;
              0       0    0  1]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle γ around z axis.
"""
rz(γ) = [cos(γ) sin(γ) 0  0;
        -sin(γ) cos(γ) 0  0;
          0       0    1  0;
          0       0    0  1]

txyz(x,y,z) = [1 0 0 x;
               0 1 0 y;
               0 0 1 z;
               0 0 0 1]

scalexyz(x,y,z) = [x 0 0 0;
                   0 y 0 0;
                   0 0 z 0;
                   0 0 0 1] 
# http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html