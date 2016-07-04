export Node, rx, ry, rz, xyz, txyz, scalexyz

"""
    Node([name],x,y,z)
    Node(xyz::Array{Float64,1})

`Node` objects `show` a FastHenry node command.
"""
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
    @printf(io,"(%.9e,%.9e,%.9e)",n.xyz[1],n.xyz[2],n.xyz[3])
  else
    @printf(io,"x=%.9e y=%.9e z=%.9e",n.xyz[1],n.xyz[2],n.xyz[3])
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

"""
    xyz(n::Node)

Return the coordinate on a node.
"""
xyz(n::Node) = n.xyz[1:3]

"""
    rx(α) = [1      0       0     0;
             0    cos(α)  sin(α)  0;
             0   -sin(α)  cos(α)  0;
             0      0       0     1]

[Rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle α around x axis.
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


[Rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle β around y axis.
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

[Rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle γ around z axis.
"""
rz(γ) = [cos(γ) sin(γ) 0.0  0.0;
        -sin(γ) cos(γ) 0.0  0.0;
          0.0    0.0   1.0  0.0;
          0.0    0.0   0.0  1.0]


"""
    txyz(p,q,r) = [1.0 0.0 0.0  p;
                   0.0 1.0 0.0  q;
                   0.0 0.0 1.0  r;
                   0.0 0.0 0.0 1.0]

[Translation matrix](http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html).  Translate a coordinate by adding [p,q,r]
"""
txyz(p,q,r) = [1.0 0.0 0.0  p;
               0.0 1.0 0.0  q;
               0.0 0.0 1.0  r;
               0.0 0.0 0.0 1.0]
txyz(a) = txyz(a[1],a[2],a[3])

"""
    scalexyz(p,q,r) = [ p  0.0 0.0 0.0;
                       0.0  q  0.0 0.0;
                       0.0 0.0  r  0.0;
                       0.0 0.0 0.0 1.0]

[Scale matrix](http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html).  Scale a coordinate [x, y, z] by [p, q, r].
"""
scalexyz(p,q,r) = [ p  0.0 0.0 0.0;
                   0.0  q  0.0 0.0;
                   0.0 0.0  r  0.0;
                   0.0 0.0 0.0 1.0]
