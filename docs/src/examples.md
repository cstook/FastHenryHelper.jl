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
node!(io,lastused,1,0,0)
node!(io,lastused,1,1,0)
node!(io,lastused,0,1,0)
end_node = node!(io,lastused,0,0.01,0)
comment(io)
comment(io,"the segments connecting the nodes")
segment!(io,lastused,1,2,w=0.2,h=0.1)
segment!(io,lastused,2,3,w=0.2,h=0.1)
segment!(io,lastused,3,4,w=0.2,h=0.1)
segment!(io,lastused,4,5,w=0.2,h=0.1)
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