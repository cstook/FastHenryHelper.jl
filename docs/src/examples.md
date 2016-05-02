# Examples

## Example 1
This is a duplicate of the simple example in section 1.1 of "FastHenry USER'S GUIDE"

```julia
{example}
using FastFieldSolversHelper
using .FastHenry2Helper
io = STDOUT

titleline(io,"This is the title line")
units(io,"mm")
default(io,sigma=5.8e4) # for copper
comment(io)
comment(io,"nodes of a square")
node(io,1,0,0,0)
node(io,2,1,0,0)
node(io,3,1,1,0)
node(io,4,0,1,0)
node(io,5,0,0.01,0)
comment(io)
comment(io,"the segments connecting the nodes")
segment(io,1,1,2,w=0.2,h=0.1)
segment(io,2,2,3,w=0.2,h=0.1)
segment(io,3,3,4,w=0.2,h=0.1)
segment(io,4,4,5,w=0.2,h=0.1)
comment(io)
comment(io,"define one port of the network")
external(io,1,5)
comment(io)
comment(io,"frequency range of interest")
frequency(io,1e4,1e8,1.0)
comment(io)
comment(io,"all files must end with .end")
fasthenryend(io)
```

## Example 2
Same as example 1, except using LastUsed(), node!, and segment! to automatically number the nodes and segments.

```julia
{example}
using FastFieldSolversHelper
using .FastHenry2Helper
io = STDOUT

lastused = LastUsed()
titleline(io,"This is the title line")
units(io,"mm")
default(io,sigma=5.8e4) # for copper
comment(io)
comment(io,"nodes of a square")
start_node = node!(io,lastused,0,0,0)
node_a = node!(io,lastused,1,0,0)
node_b = node!(io,lastused,1,1,0)
node_c = node!(io,lastused,0,1,0)
end_node = node!(io,lastused,0,0.01,0)
comment(io)
comment(io,"the segments connecting the nodes")
segment!(io,lastused,start_node,node_a,w=0.2,h=0.1)
segment!(io,lastused,node_a,node_b,w=0.2,h=0.1)
segment!(io,lastused,node_b,node_c,w=0.2,h=0.1)
segment!(io,lastused,node_c,end_node,w=0.2,h=0.1)
comment(io)
comment(io,"define one port of the network")
external(io,start_node,end_node)
comment(io)
comment(io,"frequency range of interest")
frequency(io,1e4,1e8,1.0)
comment(io)
comment(io,"all files must end with .end")
fasthenryend(io)
```

## Example 3, using a thin ground plane as a shield between two loops

```julia
{example}
using FastFieldSolversHelper
using .FastHenry2Helper

function loop!(io,lastused,r,z)
    n = 16
    ts = linspace(2*pi/n,2*pi*(1-1/n),n)
    x = r.*map(cos,ts)
    y = r.*map(sin,ts)
    nodes = Array(Int,n)
    for i in 1:n
        nodes[i] = node!(io,lastused,x[i],y[i],z)
    end
    for i in 1:n-1
        segment!(io,lastused,nodes[i],nodes[i+1])
    end
    return (nodes[1],nodes[end])
end

io = STDOUT
lastused = LastUsed()
titleline(io,"Example 3, reference plane shield")
units(io,"mm")
default(io,w=1,h=1,nhinc=5,nwinc=5,sigma=5.8e4) # for copper
comment(io)
loop1=loop!(io,lastused,20,2)
loop2=loop!(io,lastused,20,-2)
corner1 = (-100,-100,0)
corner2 = (100,-100,0)
corner3 = (100,100,0)
thick = 0.01
seg1 = 100
seg2 = 100
referenceplane!(io,lastused,corner1...,corner2...,corner3...,thick,seg1,seg2, nhinc=10)
external(io,loop1...,"loop1")
external(io,loop2...,"loop2")
frequency(io,1e6,1e9,2)
fasthenryend(io)
```

Results from FastHenry:

Computed matrices (R+jL)
 Row 0:  n1 to n16, loop1
 Row 1:  n17 to n32, loop2
 Freq = 1000
  Row 0: 0.0018911+8.22381e-008j 5.66428e-006+3.56763e-008j 
  Row 1: 5.65315e-006+3.5639e-008j 0.00189111+8.22586e-008j 
 Freq = 10000
  Row 0: 0.00239051+7.94741e-008j 0.000481143+3.29497e-008j 
  Row 1: 0.000480184+3.29179e-008j 0.00239094+7.94921e-008j 
 Freq = 100000
  Row 0: 0.0105075+5.51391e-008j 0.00732349+1.03681e-008j 
  Row 1: 0.00731384+1.0378e-008j 0.0105129+5.51362e-008j 
 Freq = 1e+006
  Row 0: 0.0219248+4.3985e-008j 0.013729+2.18739e-009j 
  Row 1: 0.0137217+2.20128e-009j 0.0219282+4.39802e-008j 
 Freq = 1e+007
  Row 0: 0.0242984+4.32715e-008j 0.0141905+1.88773e-009j
  Row 1: 0.0141852+1.90144e-009j 0.0243002+4.32667e-008j 
 Freq = 1e+008
  Row 0: 0.0295116+4.32578e-008j 0.00978452+1.88764e-009j 
  Row 1: 0.00978393+1.90134e-009j 0.0295129+4.3253e-008j 
 Freq = 1e+009
  Row 0: 0.0780739+4.32381e-008j -0.000142952+1.9013e-009j 
  Row 1: -0.000119808+1.91501e-009j 0.0780644+4.32334e-008j 

All impedance matrices dumped to file Zc.mat

Times:  Read geometry   0.063
        Multipole setup 45.549
        Scanning graph  0
        Form A M and Z  0.0469999
        form M'ZM       0
        Form precond    74.973
        GMRES time      744.624
   Total:               865.256

