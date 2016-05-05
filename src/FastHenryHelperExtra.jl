# FastHenryHelperExtra.jl

export via!
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

export trace!

function trace!(io::IO, lastused::LastUsed, nodes;
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
  if length(nodes)<2
    throw(ArgumentError("must have at least two nodes"))
  end
  for i in 1:length(nodes-1)
    segment!( io, lastused, nodes,
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
  return nodes[1]:nodes[end]
end

function trace!{T<:Point}(io::IO, lastused::LastUsed, points::Array{T};
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
  if length(points)<2
    throw(ArgumentError("must have at least two points"))
  end
  nodes = node!(io,lastused,points,comment=comment)
  trace!(io,lastused,nodes,
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
    trace!(io::IO, lastused::LastUsed, nodes, <keyword arguments>)
    trace!{T<:Point}(io::IO, lastused::LastUsed, points::Array{T}, <keyword arguments>)

connects list of nodes or points with segments.

`nodes` is any iterable object which returns integer node numbers.  Segments connecting 
nodes in order are written to `io`.  `lastused` is updated to reflect the segments 
added.  Accepts same keyword arguments as `segment()`.  Returns range firstnode:lastnode.
Instead of node numbers, an array of `Points` may be passed.  In this case nodes are created
before the segments connecting them. 
"""
trace!

hexlixpoint(radius,pitch,angle)=Cartesian(radius*cos(angle), radius*sin(angle), pitch*angle/(2π))

export helixpoints
"""
    helixpoints(radius::Float64, pitch::Float64, radians::Float64, radianperpoint::Float64=π/4)

returns an array of points along a helical path.

The helix is specified by `radius`, `pitch`, and `radians`.  The spacing of the points along 
the helix is determined by `radiansperpoint`.
"""
function helixpoints(radius::Float64, pitch::Float64, radians::Float64, radiansperpoint::Float64=π/4)
  numberofpoints = Int(cld(radians,radiansperpoint))+1
  points = Array(Cartesian,numberofpoints)
  i = 0
  for angle in 0:radiansperpoint:radians
    i+=1
    points[i] = hexlixpoint(radius,pitch,angle)
  end
  if i<numberofpoints # end point didn't fall on a multiple of radiansperpoint
    i+=1
    points[i] = hexlixpoint(radius,pitch,radians)
  end
  return points
end

export xyz

function xyz(point::Point)
  cp = convert(Cartesian,point)
  return(cp.x,cp.y,cp.z)
end

function xyz{T<:Point}(points::Array{T})
  x = similar(points,Float64)
  y = similar(points,Float64)
  z = similar(points,Float64)
  for i in eachindex(points)
    (x[i],y[i],z[i]) = xyz(points[i])
  end
  return (x,y,z)
end

"""
    xyz(point::Point)
    xyz{T<:Point}(points::Array{T})

converts an array of points to a tuple of arrays for the x,y, and z cooridnates.

usefull for plotting points for debug.
"""
xyz