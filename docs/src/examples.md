# Example 1: A simple example from the FastHenry documentation.

This example is a recreation of the example in section 1.2 of "FastHenry Users Guide" using FastHeneryHelper.

load the module
```@example 1
using FastHenryHelper
```

Create a group of FastHenry elements for FastHenry to compute the loop inductance of an L shaped trace over a ground plane with the trace's return path through the plane.
```@example 1
title = Title("A FastHenry example using a reference plane")
u = Units("mils")
nin = Node("in",800,800,0)
nout = Node("out",0,200,0)
g = UniformPlane(x1=0,    y1=0,    z1=0,
				 x2=1000, y2=0,    z2=0,
				 x3=1000, y3=1000, z3=0,
    			 thick= 1.2, 
    			 seg1=20, seg2=20,
    			 nodes=[nin, nout])
d = Default(SegmentParameters(sigma=62.1e6*2.54e-5,nwinc=8, nhinc=1))
n1 = Node("1",0,200,1.5)
n2 = Node(800,200,1.5)
n3 = Node(800,800,1.5)
sp = SegmentParameters(w=8,h=1)
s1 = Segment(n1,n2,sp)
s2 = Segment(n2,n3,sp)
eq = Equiv([nin,n3])
ex = External(n1,nout)
f = Freq(min=1e-1, max=1e9, ndec=0.05)
e = End()
example1 = Group([title;u;g;d;n1;n2;n3;s1;s2;eq;ex;f;e])
```

Write example1 to a file.
```@example 1
open("example1.inp","w") do io
    show(io,example1)
end
```

Groups may be transformed.  To demonstrate, example1 is rotated 90deg around x,y,and z axis.
```@example 1
transform!(example1,rx(0.5π)*ry(0.5π)*rz(0.5π))  # must keep plane parallel to xy, xz, or yz plane
```

Write rotated example1 to a file
```@example 1
open("example1_rotated.inp","w") do io
    show(io,example1)
end
```

Groups may also be built with push!.
```@example 1
# same example, using push!
example1 = Group()
push!(example1,Title("A FastHenry example using a reference plane"))
push!(example1,Units("mils"))
push!(example1,Node("in",800,800,0))
push!(example1,Node("out",0,200,0))
push!(example1,UniformPlane(x1=0, y1=0, z1=0, x2=1000, y2=0, z2=0, x3=1000, y3=1000, z3=0,
    thick= 1.2, seg1=20, seg2=20, nodes=[nin, nout]))
push!(example1,Default(SegmentParameters(sigma=62.1e6*2.54e-5,nwinc=8, nhinc=1)))
push!(example1,Node("1",0,200,1.5))
push!(example1,Node(800,200,1.5))
push!(example1,Node(800,800,1.5))
sp = SegmentParameters(w=8,h=1)
push!(example1,Segment(n1,n2,sp))
push!(example1,Segment(n2,n3,sp))
push!(example1,Equiv([nin,n3]))
push!(example1,External(n1,nout))
push!(example1,Freq(min=1e-1, max=1e9, ndec=0.05))
push!(example1,End())
```