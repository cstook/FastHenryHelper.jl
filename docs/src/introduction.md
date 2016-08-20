# Introduction to FastHenryHelper

This introduction does not attempt to explain FastHenry.  See the [FastHenry User's Guide](https://github.com/ediloren/FastHenry2/blob/master/doc/FastHenry_User_Guide.pdf).

[jupyter version](https://github.com/cstook/FastHenryHelper.jl/blob/master/docs/src/Introduction.ipynb)

## Loading the modules
```@example intro
using FastHenryHelper
using Plots; pyplot() # using pyplot() backed for plots, plotlyjs() also works.
```
## Creating a Simple Group
FastHenry commands are julia types which show their command.
```@example intro
n1 = Node(10,0,0)
```
A name was not specified, so _1 was automatically generated.
x, y, and z must always be specified.  Default coordinates not allowed.

A name can be specified as the first parameter.
```@example intro
n2 = Node(:abcd,0,0,0)
```

Segments connect nodes.  Keyword parameters match the [FastHenry](https://github.com/ediloren/FastHenry2/blob/master/doc/FastHenry_User_Guide.pdf) keywords.
```@example intro
s1 = Segment(n1, n2, w=10, h=20, nwinc=5, nhinc=7)
```

Parameters may also be passed as a `SegmentParameters` object.
```@example intro
sp1 = SegmentParameters(w=10, h=20, nwinc=5, nhinc=7)
s1 = Segment(n1, n2, sp1)
```

A `SegmentParameters` object can be created by specifying the parameters that differ from another `SegmentParameters` object.
```@example intro
sp2 = SegmentParameters(sp1,w=5,h=2)
s2 = Segment(n1, n2, sp2)
```

Elements can be collected into groups.  Auto-generated names are unique within the `Group` `show` is called on.  `Group`s may be transformed (rotated, translated, etc.).  `Group`s may be nested within each other.  
```@example intro
g1 = Group([n1,n2,s2])
```

Let's take a look.
```@example intro
plot(g1)
savefig("intro_plot_1.svg"); nothing # hide
```
![](intro_plot_1.svg)

Rotate g1 π/4 around y and z azis and translate by 10 along x azis.
```@example intro
transformmatrix = ry(π/4) * rz(π/4) * txyz(10,0,0)
transform!(g1,transformmatrix)
# note: the wx, wy, wz vector for the segment has rotated from default and all
# automatically generated names are unique.
g1
```

Plot after transform.
```@example intro
plot(g1)
savefig("intro_plot_2.svg"); nothing # hide
```
![](intro_plot_2.svg)

## Creating a Group with repetitive geometry

Create a square loop in the xy plane with a gap at the origin
```@example intro
n1 = Node(0,-1,0)
n2 = Node(0,-10,0)
n3 = Node(10,-10,0)
n4 = Node(10,10,0)
n5 = Node(0,10,0)
n6 = Node(0,1,0)
sp = SegmentParameters(h=2,w=3)
s1 = Segment(n1,n2,sp)
s2 = Segment(n2,n3,sp)
s3 = Segment(n3,n4,sp)
s4 = Segment(n4,n5,sp)
s5 = Segment(n5,n6,sp)
loop = Group([n1,n2,n3,n4,n5,n6,s1,s2,s3,s4,s5])
```
Take a look.
```@example intro
plot(loop)
savefig("intro_plot_3.svg"); nothing # hide
```
![](intro_plot_3.svg)

Groups have a dictionary of terminals, nodes which are external connection points, for the group.  In this case n1 and n6 are the terminals.
```@example intro
t = terms(loop)
push!(t,:a=>n1)
push!(t,:b=>n6)
nothing # hide
```
The loop with terminals could have been defined on one line
```@example intro
loop = Group([n1,n2,n3,n4,n5,n6,s1,s2,s3,s4,s5],Dict(:a=>n1,:b=>n6));
```

Shift loop 5 along x axis
```@example intro
transform!(loop,txyz(5,0,0))
```

Create array of 8 loops each rotated π/4 around y axis
```@example intro
tm = ry(π/4)
loops = []
for i in 1:8
  transform!(loop,tm)
  push!(loops,deepcopy(loop))
end
```

Create a group of the loops.
```@example intro
loopsgroup = Group(loops)
```

Take a look.
```@example intro
plot(loopsgroup)
savefig("intro_plot_4.svg"); nothing # hide
```
![](intro_plot_4.svg)

Define a port for each loop.
```@example intro
ex = []
for loop in loops
  push!(ex, External(loop[:a],loop[:b]))  # use terminals we defined
end
externalgroup = Group(ex)
```

Create top level group.
```@example intro
eightloops = Group()
push!(eightloops, Units("mm"))
push!(eightloops, Default(SegmentParameters(sigma=62.1e6*1e-3,nwinc=7, nhinc=5)))
append!(eightloops, loopsgroup)
append!(eightloops, externalgroup)
push!(eightloops, Freq(min=1e-1, max=1e9, ndec=0.05))
push!(eightloops, End())
nothing # hide
```

Write to file.
```@example intro
open("eightloops.inp","w") do io
  print(io,eightloops)
end
```

FastHenry was run with "eightloops.inp" input file.  FastHenryHelper does not call FastHenry.

view [eightloops.inp](https://github.com/cstook/FastHenryHelper.jl/blob/gh-pages/eightloops.inp).

view FastHenry output [eightloopsZc.mat](https://github.com/cstook/FastHenryHelper.jl/blob/gh-pages/eightloopsZc.mat).

The FastHenry .mat output file can be parsed.
```@example intro
result = parsefasthenrymat("eightloopsZc.mat")
result.impedance
```
