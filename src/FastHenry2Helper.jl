"""
Helps creating input files for FastHenry2.
"""
module FastHenry2Helper

export external, frequency, fasthenryend, via!
export LastUsed
export node, node!
export segment, segment!
export units, default, external, frequency, equivalent, titleline, comment
export referenceplane!

"""
Keeps track of the last used node, segment and reference plane number
"""
type LastUsed
  "last used node number"
  node :: Int
  "last used segment number"
  segment :: Int
  "last used reference plane number"
  referenceplane :: Int
  LastUsed() = new(0,0,0)
end


function node(io::IO, number::Integer, x, y, z; comment="")
  if number<0
    throw(ArgumentError("node number must be >=0"))
  end
  print(io,"N",number)
  @printf(io," x=%.6e, y=%.6e, z=%.6e",x,y,z)
  if comment == ""
    println(io)
  else
    println(io," * ",comment)
  end
  return number
end

function node(io::IO, number, x,y,z; comment="")
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
    f()=@printf(io," w=%.6e",w);f()
  end
  if ~isnan(h)
    f()=@printf(io," h=%.6e",h);f()
  end
  if ~isnan(sigma)
    f()=@printf(io," sigma=%.6e",sigma);f()
  end
  if ~isnan(rho)
    f()=@printf(io," rho=%.6e",rho);f()
  end
  if ~isnan(wx)
    f()=@printf(io," wx=%.6e",wx);f()
  end
  if ~isnan(wy)
    f()=@printf(io," wy=%.6e",wy);f()
  end
  if ~isnan(wz)
    f()=@printf(io," wz=%.6e",wz);f()
  end
  if nhinc!=0
    f()=@printf(io," nhinc=%.6e",nhinc);f()
  end
  if nwinc!=0
    f()=@printf(io," nwinc=%.6e",nwinc);f()
  end
  if ~isnan(rh)
    f()=@printf(io," rh=%.6e",rh);f()
  end
  if ~isnan(rw)
    f()=@printf(io," rw=%.6e",rw);f()
  end
  if comment!=""
    println(io," * ",comment)
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
function units(io::IO, unit::AbstractString="mm"; comment="")
  if ~issubset(Set([unit]),Set(["km", "m", "cm", "mm", "um", "in", "mils"]))
    throw(ArgumentError("valid units are km, m, cm, mm, um, in, mils"))
  end
  print(io,".Units ",unit)
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
  return nothing
end


"""
    default(io, <keyword arguments>)

Write .Default command to `io`.

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
    f()=@printf(io," x=%.6e",x);f()
  end
  if ~isnan(y)
    f()=@printf(io," y=%.6e",y);f()
  end
  if ~isnan(z)
    f()=@printf(io," z=%.6e",z);f()
  end
  if ~isnan(w)
    f()=@printf(io," w=%.6e",w);f()
  end
  if ~isnan(h)
    f()=@printf(io," h=%.6e",h);f()
  end
  if ~isnan(sigma)
    f()=@printf(io," sigma=%.6e",sigma);f()
  end
  if ~isnan(rho)
    f()=@printf(io," rho=%.6e",rho);f()
  end
  if nhinc!=0
    f()=@printf(io," nhinc=%.6e",nhinc);f()
  end
  if nwinc!=0
    f()=@printf(io," nwinc=%.6e",nwinc);f()
  end
  if ~isnan(rh)
    f()=@printf(io," rh=%.6e",rh);f()
  end
  if ~isnan(rw)
    f()=@printf(io," rw=%.6e",rw);f()
  end
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
  return nothing
end

function external(io::IO, node1, node2, portname=""; comment="")
  print(io,".External N",Int(trunc(node1))," N",Int(trunc(node2))," ",portname)
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
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
    external(io::IO, node1, node2 [,portname], <keyword arguments>)
    external(io::IO, nodes1::Array{Number,1}, node2s::Array{Number,1} [,portnames::Array{AbstractString,1}=[]])

Write .External command('s) to `io`.

The .External command defines a terminal pair('s) as port(s') with an optional name('s).  A comment
may be added with the comment keyword.
"""
external


"""
    frequency(io::IO, fmin, fmax [,ndec], <keyword arguments>)

Write ".Freq" command to `io`.

If fmin is zero, FastHenry will run only the DC case regardless of the value of
 fmax.  A comment may be added with the  comment keyword.
"""
function frequency(io::IO, fmin, fmax, ndec=0; comment="")
  f()=@printf(io,".freq fmin=%.6e fmax=%.6e",fmin,fmax);f()
  if ndec!=0
    print(io," ndec=",ndec)
  else
    print(io)
  end
  if comment!=""
    print(io," * ",comment)
  end
  println(io)
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

function comment(io::IO, args...)
  print(io,"* ")
  for arg in args
    print(io,arg)
  end
  println(io)
end

"""
    fasthenryend(io::IO)

Write \".end\" to `io` to indicate end of input file.
"""
function fasthenryend(io::IO)
  println(io,".end")
end

"""
    referenceplane!(io::IO,
                   lastused :: LastUsed,
                   x1,y1,z1,
                   x2,y2,z2,
                   x3,y3,z3,
                   thick, seg1, seg2,
                   <keyword arguments>)

Write reference plane command \"G\" to io.

This function creates the command for a uniformly discretized plane.  It
returns the tuple (referenceplanenumber, [nodenumber1, nodenumber2]) 
where referenceplanenumber is an integer assigned to the reference plane and
the node numbers are integers assigned to the requested connection nodes.
For example, reference plane G4 with connection nodes N2, N3, N4 will return 
(4,[2,3,4]).  lastused is updated to reflect the reference plane and node
numbers used.

## Arguments
* `io::IO`: where the FastHenry commands are written
* `lastused::Lastused`: keeps track of last used node, segment, and reference plane number
* `x1`,`y1`,`z1`, `x2`,`y2`,`z2`, `x3`,`y3`,`z3`: three corners of a rectangle defining the plane
* `thick`: thickness of plane
* `seg1`, `seg2`: number of segments to divide plane into along each axis

## Keyword Arguments
* `segwid1`, `segwid2`: override default segment width for a meshed plane
* `sigma`, `rho`: conductivity or resistivity (only specify one).
                  sigma = 5.8e4 1/(mm*Ohms) for copper.
* `nhinc`, `rh`: specify discretization of segments perpendicular to plane.
                 use `seg1`, `seg2` in plane.
* `relx`, `rely`, `relz`: offset to be applied to connection nodes.  zero if unspecified.
* `nodes`: a list of coordinates of connection nodes [(x1,y1,z1),(x2,y2,z2),...] 
* `holes`: a list of holes
           [(hole_type_string, val1, val2, val3, ...),
            .
            .
            .]
            valid hole type are \"point\", \"rect\", and \"circle\". for example:
            [(\"point\",x,y,z),
             (\"rect\",x1,y1,z1,x2,y2,z2),
             (\"circle\",x,y,z,r)]         
"""
function referenceplane!(io::IO,
                        lastused :: LastUsed,
                        x1,y1,z1,
                        x2,y2,z2,
                        x3,y3,z3,
                        thick, seg1, seg2;
                        segwid1 = NaN, segwid2 = NaN,
                        sigma = NaN, rho = NaN,
                        nhinc = NaN, rh = NaN,
                        relx = NaN, rely = NaN, relz = NaN,
                        nodes = [],
                        holes = [])
  extendline(io) = println(io,"  +")
  checksigmaandrho(sigma,rho)
  lastused.referenceplane += 1
  print(io,"G",lastused.referenceplane)
  extendline(io)
  f()=@printf(io,"    x1=%.6e",x1);f()
  f()=@printf(io," y1=%.6e",y1);f()
  f()=@printf(io," z1=%.6e",z1);f()
  extendline(io)
  f()=@printf(io,"    x2=%.6e",x2);f()
  f()=@printf(io," y2=%.6e",y2);f()
  f()=@printf(io," z2=%.6e",z2);f()
  extendline(io)
  f()=@printf(io,"    x3=%.6e",x3);f()
  f()=@printf(io," y3=%.6e",y3);f()
  f()=@printf(io," z3=%.6e",z3);f()
  extendline(io)
  f()=@printf(io,"    thick=%.6e",thick);f()
  f()=@printf(io," seg1=%.6e",seg1);f()
  f()=@printf(io," seg2=%.6e",seg2);f()
  if ~isnan(segwid1)
    extendline(io)
    f()=@printf(io,"    segwid1=%.6e",segwid1);f()
  end
  if ~isnan(segwid2)
    extendline(io)
    f()=@printf(io,"    segwid2=%.6e",segwid2);f()
  end
  if ~isnan(sigma)
    extendline(io)
    f()=@printf(io,"    sigma=%.6e",sigma);f()
  end
  if ~isnan(rho)
    extendline(io)
    f()=@printf(io,"    rho=%.6e",rho);f()
  end
  if ~isnan(nhinc)
    extendline(io)
    f()=@printf(io,"    nhinc=%.6e",nhinc);f()
  end
  if ~isnan(rh)
    extendline(io)
    f()=@printf(io,"    rh=%.6e",rh);f()
  end
  if ~isnan(relx)
    extendline(io)
    f()=@printf(io,"    relx=%.6e",relx);f()
  end
  if ~isnan(rely)
    extendline(io)
    f()=@printf(io,"    rely=%.6e",rely);f()
  end
  if ~isnan(relz)
    extendline(io)
    f()=@printf(io,"    relz=%.6e",relz);f()
  end
  if nodes!=[]
    nodenumbers = Array(Int,length(nodes))
    for i in eachindex(nodes)
      extendline(io)
      lastused.node += 1
      nodenumbers[i] = lastused.node
      print(io,"    N",lastused.node)
      x = nodes[i][1]
      y = nodes[i][2]
      z = nodes[i][3]
      f()=@printf(io," (%.6e, %.6e, %.6e)",x,y,z);f()
    end
  else
    nodenumbers = []
  end
  for hole in holes
    extendline(io)
    holetype = hole[1]
    print(io,"    hole ",holetype," (")
    for holearg in hole[2:end-1]
      f()=@printf(io,"%.6e, ",holearg);f()
    end
    f()=@printf(io,"%.6e",hole[end]);f()
    print(io,")")
  end
  println(io)
  return (lastused.referenceplane, nodenumbers)
end

"""
    via!(io, lastused::LastUsed, x, y, top, bot, radius, wall_thickness, height 
        ; <keyword arguments>)

Write commands to create the barrel of a via to `io` and returns tuple 
`(topnode,bottomnode)`.  PCB is assumed to be parallel to the xy plane.

## Arguments
* `io::IO`: where the FastHenry commands are written
* `lastused`: used to keep track of used nodes and segments
* `x`: x position of via
* `y`: y position of via
* `top`: z offset of top of via
* `bot`: z offset of bottom of via
* `radius`: radius of via
* `wall_thickness`: thickness of the plating in the barrel

## Keyword Arguments
* `n=8`: number of segments used to create via
         n=0 will bypass the via
* `comment=""`: text to be included as comment in output 
"""
function via!(io::IO, lu::LastUsed, x, y, top, bot,
             radius, wall_thickness;
             n=8,
             comment = "")
  if n!=0 && n<2 
    throw(ArgumentError("must have zero or at least 2 segments"))
  end
  FastHenry2Helper.comment(io,"***** BEGIN ",comment)
  if n!=0
    ts = linspace(0.0, 2.0*pi-(2*pi/n), n)
    xarray = radius .* map(cos,ts) .+ x
    yarray = radius .* map(sin,ts) .+ y
    wx = map(cos,ts.+(pi/2))
    wy = map(sin,ts.+(pi/2))
    segment_width = sqrt((xarray[1]-xarray[2])^2+(yarray[1]-yarray[2])^2)
    FastHenry2Helper.comment(io,"Barrel of a via")
    FastHenry2Helper.comment(io,"  diameter = ", 2*radius)
    FastHenry2Helper.comment(io,"  wall thickness = ", wall_thickness)
    FastHenry2Helper.comment(io,"  x = ", x)
    FastHenry2Helper.comment(io,"  y = ", y)
    FastHenry2Helper.comment(io,"  top = ", top)
    FastHenry2Helper.comment(io,"  bot = ", bot)
    FastHenry2Helper.comment(io,"  number of segments = ",n)
    FastHenry2Helper.comment(io)
    FastHenry2Helper.comment(io,"nodes around top and bottom")
    topnodes = Array(Int,n)
    botnodes = Array(Int,n)
    for i in 1:n
      topnodes[i] = node!(io,lu,xarray[i],yarray[i],top)
      botnodes[i] = node!(io,lu,xarray[i],yarray[i],bot)
    end
    FastHenry2Helper.comment(io,"center node, top and bottom")
    centertopnode = node!(io,lu,x,y,top)
    centerbotnode = node!(io,lu,x,y,bot)
    FastHenry2Helper.comment(io)
    FastHenry2Helper.comment(io,"connect top and bottom together and to the center node")
    equivalent(io,topnodes,centertopnode)
    equivalent(io,botnodes,centerbotnode)
    FastHenry2Helper.comment(io)
    FastHenry2Helper.comment(io,"segments")
    for i in 1:n
      segment!(io,lu,topnodes[i],botnodes[i],
                w=segment_width,
                h=wall_thickness,
                wx=wx[i], wy=wy[i], wz=0.0,
                nhinc=5, nwinc=1)
    end
  else
    FastHenry2Helper.comment(io,"via bypass")
    centertopnode = node!(io,lu,x,y,top)
    centerbotnode = node!(io,lu,x,y,bot)
    equivalent(io,centertopnode,centerbotnode)
  end
  FastHenry2Helper.comment(io,"***** END ",comment)
  return (centertopnode, centerbotnode)
end

end # module