# Introduction to FastHenryHelper

This introduction does not attempt to explain FastHenry.  See the [FastHenry User's Guide](https://github.com/ediloren/FastHenry2/blob/master/doc/FastHenry_User_Guide.pdf).

[jupyter version](https://github.com/cstook/FastHenryHelper.jl/blob/master/docs/src/Introduction.ipynb)

## Loading the modules
```@example intro
using FastHenryHelper
using Plots; pyplot() # using pyplot() backed for plots, plotly(), plotlyjs() also work.
```
## Creating a simple group
FastHenry commands are julia types which show their command.  In FastHenryHelper these are all subtypes of the supertype `Element`.
```@example intro
n1 = Node(10,0,0)
```
A name was not specified, so _1 was automatically generated.
x, y, and z must always be specified.  Default coordinates are not allowed.

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

Elements can be collected into groups.  Auto-generated names are unique within the `Group` `show` is called on.  `Group`s may be transformed (rotated, translated, etc.).  `Group`s may be nested within each other (`Group` is a subtype of `Element`).  
```@example intro
g1 = Group([n1,n2,s2])
g1 = Group(elements = [n1,n2,s2]) # or use keyword argument
```

Let's take a look.
```@example intro
plot(g1)
savefig("intro_plot_1.svg"); nothing # hide
```
![](intro_plot_1.svg)

Rotate g1 π/4 around y and z axis and translate by 10 along x axis.
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
t[:a] = n1
t[:b] = n6;
```
`loop` can be defined more concisely using `element` and `terms` keyword arguments and the function  `connectnodes`.
```@example intro
sp = SegmentParameters(h=2,w=3)
loop = Group(
  elements = [
    n1 = Node(0,-1,0),
    n2 = Node(0,-10,0),
    n3 = Node(10,-10,0),
    n4 = Node(10,10,0),
    n5 = Node(0,10,0),
    n6 = Node(0,1,0),
    connectnodes([n1,n2,n3,n4,n5,n6],sp)...
  ],
  terms = Dict(:a=>n1,:b=>n6)
)
```

Shift loop 5 along x axis
```@example intro
transform!(loop,txyz(5,0,0))
```

Create array of 8 loops each rotated π/4 around y axis
```@example intro
tm = ry(π/4)
loops = Array(Group,8)
for i in 1:8
  transform!(loop,tm)
  loops[i] = deepcopy(loop)
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

Define a port for each loop. Ports could have been defined as the loops were created. This way demonstrates the use of terminals.
```@example intro
ex = []
for loop in loops
  push!(ex, External(loop[:a],loop[:b]))  # use terminals we defined
end
externalgroup = Group(ex)
```

Create top level group.
```@example intro
eightloops = Group(
  elements = [
    Units("mm"),
    Default(SegmentParameters(sigma=62.1e6*1e-3, nwinc=7, nhinc=5)),
    loopsgroup,
    externalgroup,
    Freq(min=1e-1, max=1e9, ndec=0.05),
    End()
  ]
);
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
## Group units

In addition to the `Units` type, units may be specified for a `Group` using the units keyword.  Group units only apply to the `elements` in the `Group`.
```@example intro
groupunitexample = Group(
  elements = [
    Units("cm"),
    Node(1,0,0),
    Group(
      elements = [
        Node(20,0,0)
      ],
      units = Units("mm")
    ),
    Node(3,0,0)
  ]
)
```
