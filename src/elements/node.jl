export Node, rx, ry, rz, txyz, scalexyz

immutable Node <: Element
  name :: AutoName
  xyz  :: Array{Float64,1}
  Node(n,xyz::Array{Float64,1}) = new(AutoName(n),xyz) 
end
Node(xyz::Array{Float64,1}) = Node(:null,xyz)
Node(name,x,y,z) = Node(name,[x,y,z,1.0])
Node(x,y,z) = Node(:null,x,y,z)
Node(;name = :null, x=0, y=0, z=0) = Node(name,x,y,z)

function printfh!(io::IO, pfh::PrintFH, n::Node; plane = false)
  if plane
    print(io,"+ ")
  end
  print(io,"N",autoname!(pfh, n.name)," ")
  if plane
    @printf(io,"(%.6e,%.6e,%.6e)",n.xyz[1],n.xyz[2],n.xyz[3])
  else
    @printf(io,"x=%.6e y=%.6e z=%.6e",n.xyz[1],n.xyz[2],n.xyz[3])
  end
  println(io)
  return nothing
end

resetiname!(n::Node) = reset!(n.name)

function transform!(n::Node, tm::Array{Float64,2})
  xyz = tm*n.xyz
  n.xyz[1:4] = xyz[1:4]
  return nothing
end
function transform(n::Node, tm::Array{Float64,2})
  newn = deepcopy(n)
  transform!(newn)
end

"""
    rx(α) = [1      0       0     0;
             0    cos(α)  sin(α)  0;
             0   -sin(α)  cos(α)  0;
             0      0       0     1]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle α around x axis.
"""
rx(α) = [1.0      0.0       0.0     0.0;
         0.0     cos(α)    sin(α)   0.0;
         0.0    -sin(α)    cos(α)   0.0;
         0.0      0.0       0.0     1.0]

"""
    ry(β) = [cos(β)   0    -sin(β)  0;
               0      1       0     0;
             sin(β)   0     cos(β)  0;
               0      0       0     1]


[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle β around y axis.
"""
ry(β) = [cos(β)   0.0    -sin(β)    0.0;
          0.0     1.0      0.0      0.0;
         sin(β)   0.0     cos(β)    0.0;
          0.0     0.0      0.0      1.0]

"""
    rz(γ) = [cos(γ) sin(γ) 0  0;
            -sin(γ) cos(γ) 0  0;
              0       0    1  0;
              0       0    0  1]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle γ around z axis.
"""
rz(γ) = [cos(γ) sin(γ) 0.0  0.0;
        -sin(γ) cos(γ) 0.0  0.0;
          0.0    0.0   1.0  0.0;
          0.0    0.0   0.0  1.0]

txyz(x,y,z) = [1.0 0.0 0.0  x;
               0.0 1.0 0.0  y;
               0.0 0.0 1.0  z;
               0.0 0.0 0.0 1.0]

scalexyz(x,y,z) = [ x  0.0 0.0 0.0;
                   0.0  y  0.0 0.0;
                   0.0 0.0  z  0.0;
                   0.0 0.0 0.0 1.0] 
# http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html