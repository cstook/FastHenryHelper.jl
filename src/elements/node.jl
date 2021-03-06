export Node, rx, ry, rz, xyz, txyz, scalexyz

"""
    Node([name],x,y,z)
    Node(xyz::Array{Float64,1})

`Node` objects `show` a FastHenry node command.
"""
struct Node <: Element
  name :: Symbol
  xyz1  :: Array{Float64,1}
  function Node(n,xyz::Array{Float64,1})
    xyz1 = Array{Float64}(undef,4)
    xyz1[1:3] = xyz[1:3]
    xyz1[4] = 1.0
    new(Symbol(n),xyz1)
  end
end
Node(xyz::Array{Float64,1}) = Node(Symbol(""),xyz)
Node(name,x,y,z) = Node(name,[x,y,z,1.0])
Node(x,y,z) = Node(Symbol(""),x,y,z)
Node(;name = Symbol(""), x=0, y=0, z=0) = Node(name,x,y,z)

"""
    xyz(n::Node)

Return the coordinate of a node.
"""
xyz(n::Node) = n.xyz1[1:3]

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
