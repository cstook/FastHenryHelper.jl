"""
Helps creating input files for FastHenry2.
"""
module FastHenry2Helper

export setdefaults, external, frequency, fasthenryend, via
export LastUsed
export node, node!
export segment, segment!
export units, default, external, frequency, equivalent, titleline, comment

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
  number_int = Int(trunc(number))
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
* `x`,`y`,`z`: coordinate of node

## Keyword Arguments
* `comment`: comment to be appended to line
"""
node, node!

"""
    checksigmaandrho(sigma,rho)

Throws an ArgumentError() if both sigma and rho are specified.
"""
function checksigmaandrho(sigma,rho)
  if ~isnan(sigma) && ~isnan(rho)
    throw(ArgumentError("cannot specify both sigma (conductivity) and rho (resistivity)"))
  end
end

function segment(io::IO, segment_number::Integer, node1::Integer, node2::Integer; 
                 w::Float64=NaN,
                 h::Float64=NaN,
                 sigma::Float64 = NaN,
                 rho::Float64 = NaN,
                 wx::Float64 = NaN,
                 wy::Float64 = NaN,
                 wz::Float64 = NaN,
                 nhinc::Integer = 0,
                 nwinc::Integer = 0,
                 rh::Float64 = NaN,
                 rw::Float64 = NaN,
                 comment = "")
  if segment_number<0 || node1<0 || node2<0
    throw(ArgumentError("segment and node numbers must be >=0"))
  end
  checksigmaandrho(sigma,rho)
  print(io,"E",segment_number," N",node1," N",node2)
  if ~isnan(w)
    print(io," w=",w)
  end
  if ~isnan(h)
    print(io," h=",h)
  end
  if ~isnan(sigma)
    print(io," sigma=",sigma)
  end
  if ~isnan(rho)
    print(io," rho=",rho)
  end
  if ~isnan(wx)
    print(io," wx=",wx)
  end
  if ~isnan(wy)
    print(io," wy=",wy)
  end
  if ~isnan(wz)
    print(io," wz=",wz)
  end
  if nhinc!=0
    print(io," nhinc=",nhinc)
  end
  if nwinc!=0
    print(io," nwinc=",nwinc)
  end
  if ~isnan(rh)
    print(io," rh=",rh)
  end
  if ~isnan(rw)
    print(io," rw=",rw)
  end
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
  return segment_number
end

function segment(io::IO, segment_number, node1, node2; 
                 w::Float64=NaN,
                 h::Float64=NaN,
                 sigma::Float64 = NaN,
                 rho::Float64 = NaN,
                 wx::Float64 = NaN,
                 wy::Float64 = NaN,
                 wz::Float64 = NaN,
                 nhinc::Integer = 0,
                 nwinc::Integer = 0,
                 rh::Float64 = NaN,
                 rw::Float64 = NaN,
                 comment = "")
  int_segment_number = Int(trunc(segment_number))
  int_node1 = Int(trunc(node1))
  int_node2 = Int(trunc(node2))
  if int_segment_number!=segment_number || int_node1!=node1 || int_node2!=node2
    throw(ArgumentError("segment_number, node1, and node2 must be integers"))
  end
  segment(io, int_segment_number, int_node1, int_node2,
           w = w,
           h = h,
           sigma = sigma,
           rho = rho,
           wx = wx,
           wy = wy,
           wz = wz,
           nhinc = nhinc,
           nwinc = nwinc,
           rh = rh,
           rw = rw,
           comment = comment)
end

function segment!(io::IO, lu::LastUsed, node1, node2; 
                 w::Float64=NaN,
                 h::Float64=NaN,
                 sigma::Float64 = NaN,
                 rho::Float64 = NaN,
                 wx::Float64 = NaN,
                 wy::Float64 = NaN,
                 wz::Float64 = NaN,
                 nhinc::Integer = 0,
                 nwinc::Integer = 0,
                 rh::Float64 = NaN,
                 rw::Float64 = NaN,
                 comment = "")
  lu.segment+=1
  segment(io, lu.segment, node1, node2,
           w = w,
           h = h,
           sigma = sigma,
           rho = rho,
           wx = wx,
           wy = wy,
           wz = wz,
           nhinc = nhinc,
           nwinc = nwinc,
           rh = rh,
           rw = rw,
           comment = comment)
end


"""
    segment(io, segment_number, node1, node2, <keyword arguments>)
    segment!(io, lastused::LastUsed, node1, node2, <keyword arguments>)

Write a segment definition to io and update `lastused` if applicable.  Returns segment number used.

## Arguments
* `io::IO`: where the FastHenry commands are written
* `segment_number` or `lastused`: segment number, either explicit or next available.
* `node1`, `node2`: segment will extend from node1 to node2

## Keyword Arguments
* `w`: segment width
* `h`: segment height
* `sigma`: conductivity 
* `rho`: resistivity 
* `wx`, `wy`, `wz`: segment orientation.  vector pointing along width of segment's cross section.
* `nhinc`, `nwinc`: integer number of filaments in height and width
* `rh`, `rw`: ratio in the height and width
* `comment`: comment to be appended to line
"""
segment, segment!


"""
    units(io::IO, unit::AbstractString="mm")

Writes .Units command to io.

Species the units to be used for all subsequent coordinates and lengths until the
end of file or another .Units specication is encountered.
"""
function units(io::IO, unit::AbstractString="mm")
  if ~issubset(Set([unit]),Set(["km", "m", "cm", "mm", "um", "in", "mils"]))
    throw(ArgumentError("valid units are km, m, cm, mm, um, in, mils"))
  end
  println(io,".Units ",unit)
  return nothing
end


"""
    default(io, <keyword arguments>)

Write commands to set simulation defaults to `io`.

## Arguments
* `io::IO`: where the FastHenry commands are written

## Keyword Arguments
* `x`, `y`, `z`: default x,y, and z cooridantes
* `w`, `h`:  default width and height
* `sigma` ,`rho`: default conductivity or resistivity (only specify one).
                  sigma = 5.8e4 1/(mm*Ohms) for copper.
* `nhinc`, `nwinc`: default integer number of filaments in height and width
* `rh`, `rw`: default ratio in the height and width
* `comment`: comment to be appended to line
"""
function default(io::IO;
                     x = NaN, y = NaN, z = NaN,
                     w = NaN, h = NaN,
                     sigma = NaN, rho = NaN,
                     nhinc::Integer = 0, nwinc::Integer = 0,
                     rh = NaN, rw = NaN,
                     comment = "")
  if x===NaN && y===NaN && z===NaN && w===NaN && h===NaN &&
     sigma===NaN && rho===NaN && nhinc===NaN && nhinc==0 && nwinc==0 && rh===NaN && rw===NaN
    throw(ArgumentError("at least one non comment keyword argument must be specified"))
  end
  checksigmaandrho(sigma,rho)
  print(io,".Default")
  if ~isnan(x)
    print(io," x=",x)
  end
  if ~isnan(y)
    print(io," y=",y)
  end
  if ~isnan(z)
    print(io," z=",z)
  end
  if ~isnan(w)
    print(io," w=",w)
  end
  if ~isnan(h)
    print(io," h=",h)
  end
  if ~isnan(sigma)
    print(io," sigma=",sigma)
  end
  if ~isnan(rho)
    print(io," rho=",rho)
  end
  if nhinc!=0
    print(io," nhinc=",nhinc)
  end
  if nwinc!=0
    print(io," nwinc=",nwinc)
  end
  if ~isnan(rh)
    print(io," rh=",rh)
  end
  if ~isnan(rw)
    print(io," rw=",rw)
  end
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
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
    frequency(io::IO, fmin, fmax [,ndec])

Write ".Freq" command to `io`.

If fmin is zero, FastHenry will run only the DC case regardless of the value of fmax.
"""
function frequency(io::IO, fmin, fmax, ndec=0)
  print(io,".freq fmin=",fmin," fmax=",fmax)
  if ndec!=0
    println(io," ndec=",ndec)
  else
    println(io)
  end
  return nothing
end


"""
    equivalent(io::IO, args...)

Write .Equiv command to io.

Specifies that the nodes listed in args are electrically equivalent.  
"""
function equivalent(io::IO, args...)
  print(io,".Equiv")
  for arg in args
    for element in arg
      int_element = Int(trunc(element))
      if int_element != element
        throw(ArgumentError("all elements must be integers"))
      end
      print(io," N",int_element)
    end
  end
  println(io)
  return nothing
end

"""
    titleline(io::IO, title="")

Writes title line (first line) to io.

This is the same as comment with a time stamp.
"""
function titleline(io::IO, title="")
  print(io,"* ",title)
  println(io," ",now())
  return nothing
end


"""
    comment(io::IO, c="")

Writes a comment line to io.
"""
function comment(io::IO, c="")
  println(io,"* ",c)
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