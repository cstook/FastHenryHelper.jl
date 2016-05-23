

type Node <: Element
  name :: Symbol
  xyz  :: Array{Float64,2}
end
Node(xyz::Array{Float64,2}) = Node(:null,xyz)
Node(name,x,y,z) = Node(name,[x y z 1])
Node(x,y,z) = Node(:null,x,y,z)
Node(;name::Symbol = :null, x=0, y=0, z=0) = Node(name,x,y,z)

function printfh(io::IO, n::Node)
  print(io,"N",string(name))
  @printf(io," x=%.6e y=%.6e z=%.6e",xyz[1],xyz[2],xyz[3])
  return nothing
end

import Base.+, Base.*

+(n::Node,x) = +(n.xyz,x)
*(n::Node,x) = *(n.xyz,x)

"""
    transform(node::Node, tm::Array{Float64,2})
    transform!(node::Node, tm::Array{Float64,2})

Multiply the cooridnate of `node` by the transform matrix `tm`.
"""
transform, transform!

transform(n::Node, tm::Array{Float64,2}) = Node(n.name,n*tm)
function transform!(n::Node, tm::Array{Float64,2})
  n.xyz = n*tm
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