"""
Helps creating input files for FastHenry2.
"""
module FastHenry2Helper

export setdefaults, external, frequency, fasthenryend, via
export LastUsed
export node, node!

"""
Keeps track of the last used node and segment number
"""
type LastUsed
  "last used node number"
  node :: Int
  "last used segment number"
  segment :: Int

  LastUsed() = new(0,0)
end


function node(io::IO, number::Int, x, y, z; comment="")
  if number<0
    throw(ArgumentError("node number must be >=0"))
  end
  print(io,"N",number," x=",x," y=",y," z=",z)
  if comment == ""
    println(io)
  else
    println(io," * ",comment)
  end
  return number
end

function node(io::IO, number,x,y,z; comment="")
  number_int = Int(number)
  if number_int != number
    throw(ArgumentError("node number must be integer"))
  end
  node(io,number_int, x, y, z, comment=comment)
end

function node!(io::IO, lu::LastUsed, x,y,z; comment="")
  lu.node+=1
  node(io,lu.node,x,y,z,comment=comment)
end

"""
    node(io::IO, number, x, y, z, <keyword arguments>)
    node!(io::IO, lastused::LastUsed, x, y, z, <keyword arguments>)

Write a node definition to io and update `lastused` if applicable.  Returns node number used.

## Arguments
* `io::IO`: where the FastHenry commands are written
* `number` or `lastused`: node number, either explicit or next available.
* `x`,`y`,`z`: cooridnate of node

## Keyword Arguments
* `comment`: comment to be appended to line
"""
node, node!






"""
    setdefaults(io, <keyword arguments>)

Write commands to set simulation defaults to `io`.

## Arguments
* `io::IO`: where the FastHenry commands are written

## Keyword Arguments
* `units="mm"`: default units
* `z=0`: default vertical offset
* `sigma=5.8e4`: default conductivity, 5.8e4 for copper.
* `nhinc=5`: split each segment into `nhinc` vertical segments
* `nwinc=7`: split each segment into `nwinc` horizontal segments
"""
function setdefaults(io::IO;
                     units="mm",
                     z = 0,
                     sigma=5.8e4,
                     nhinc=5,
                     nwinc=7)
  println(io,"")
  println(io,"* set defaults")
  println(io,"**************")
  println(io,"* set units to ",units)
  println(io,".Units ",units)
  println(io,"")
  println(io,"* set defaults to z=0 and copper")
  println(io,".Default z=",z," sigma=",sigma)
  println(io,"")
  println(io,"* by default split each segment into 35 filiments")
  println(io,".Default nhinc=",nhinc," nwinc=",nwinc)
  println(io,"")
  return nothing
end

function external(io::IO, node1, node2, portname="")
  println(io,".External N",Int(trunc(node1))," N",Int(trunc(node2))," ",portname)
  return nothing
end

function external(io::IO, node1s::Array{Number,1}, node2s::Array{Number,1}, portnames::Array{AbstractString,1}=[])
  l = length(nodes)
  if length(nodes2) != l
    throw(ArgumentError("arrays must have same length"))
  end
  if portnames!=[] 
    if length(portnames) != l
      throw(ArgumentError("arrays must have same length"))
    end
  end
  if l>0
    println(io,"")
    println(io,"* ports")
  end
  for i in 1:l
    external(io, node1s[i], nodes2[i], portnames[i])
  end
  if l>0
    println(io,"")
  end
end

"""
    external(io::IO, node1, node2 [,portname])
    external(io::IO, nodes1::Array{Number,1}, node2s::Array{Number,1} [,portnames::Array{AbstractString,1}=[]])

Write .External command('s) to `io`.

The .External command defines a terminal pair('s) as port(s') with an optional name('s).
"""
external


"""
    frequrncy(io::IO, fmin, fmax [,ndec])

Write ".Freq" command to `io`.
"""
function frequency(io::IO, fmin, fmax, ndec=0)
  println(io,"")
  println(io,"* frequency range")
  print(io,".freq fmin=",fmin," fmax=",fmax)
  if ndec!=0
    println(io," ndec=",ndec)
  else
    println(io)
  end
  return nothing
end


"""
    fasthenryend(io::IO)

Write \".end\" to `io` to indicate end of input file.
"""
function fasthenryend(io::IO)
  println(io,"")
  println(io,".end")
end


"""
    via(io, x_offset, y_offset, top, bot, radius, wall_thickness, height 
        [,startnode = 1]; <keyword arguments>)

Write commands to create the barrel of a via to `io` and returns tuple 
`(topnode,bottomnode)`.

## Arguments
* `io::IO`: where the FastHenry commands are written
* `x_offset`: x position of via
* `y_offset`: y position of via
* `top`: z offset of top of via
* `bot`: z offset of bottom of via
* `radius`: radius of via
* `wall_thickness`: thickness of the plating in the barrel
* `startnode=1`: where to start numbering nodes

## Keyword Arguments
* `n=8`: number of segments used to create via
* `description=""`: text to be included as comment in output 

note: Nodes from `startnode` to `bottomnode` are used.
"""
function via(io::IO, x_offset, y_offset, top, bot,
             radius, wall_thickness, 
             startnode = 1;
             n=8,
             description = "")
  if n<2 
    throw(ArgumentError("must have at least 2 segments"))
  end
  ts = linspace(0.0, 2.0*pi-(2*pi/n), n)
  x = radius .* map(cos,ts) .+ x_offset
  y = radius .* map(sin,ts) .+ y_offset
  wx = map(cos,ts.+(pi/2))
  wy = map(sin,ts.+(pi/2))
  segment_width = sqrt((x[1]-x[2])^2+(y[1]-y[2])^2)
  println(io,"* ",description)
  println(io,"* Barrel of a via")
  println(io,"*    diameter = ", 2*radius)
  println(io,"*    wall thickness = ", wall_thickness)
  println(io,"*    x_offset = ", x_offset)
  println(io,"*    y_offset = ", y_offset)
  println(io,"*    top = ", top)
  println(io,"*    bot = ", bot)
  println(io,"*    number of segments = ",n)
  println(io,"")
  println(io,"")
  println(io,"* nodes around top and bottom")
  r = startnode:n+startnode-1
  for i in r
      println(io,"N",i," x=",x[i]," y=",y[i]," z=",top)
      println(io,"N",i+n," x=",x[i]," y=",y[i]," z=",bot)
  end
  println(io,"* center node, top and bottom")
  topnode = 2*n+startnode
  bottomnode = 2*n+startnode+1
  println(io,"N",topnode ," x=0 y=0 z=",top)
  println(io,"N",bottomnode ," x=0 y=0 z=",bot)
  println(io,"")
  println(io,"* connect top and bottom together and to the center node")
  for i in r
      println(io,".equiv N",topnode," N",i)
      println(io,".equiv N",bottomnode," N",i+n)
  end
  println(io,"")
  println(io,"* segments")
  for i in r
      print(io,"E",i," N",i," N",i+n," w=",segment_width," h=",wall_thickness)
      print(io," wx=",wx[i]," wy=",wy[i]," wz=0")
      println(io,"nhinc = 5 nwinc = 1")
  end
  return (topnode, bottomnode)
end

end # module