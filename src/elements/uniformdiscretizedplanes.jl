abstract Hole <: Element

immutable Point <: Hole
  xyz  :: Array{Float64,2}
end
Point(x,y,z) = Point([x y z 1])
Point(; x=0, y=0, z=0) = Point(x,y,z)

function printfh(io::IO,x::Point)
  print(io,"+ hole point ")
  @printf(io,"(%.6e, %.6e, %.6e)",x.xyz[1],x.xyz[2],x.xyz[3])
  println(io)
  return nothing
end

transform(x::Point, tm::Array{Float64,2}) = Point(x.xyz*tm)
function transform!(x::Point, tm::Array{Float64,2})
  xyz = x.xyz*tm
  x.xyz[1:4] = xyz[1:4]
  return nothing
end

immutable Rect <: Hole
  corner1  :: Array{Float64,2}
  corner2  :: Array{Float64,2}
end
Rect(x1,y1,z1,x2,y2,z2) = Rect([x1 y1 z1 1],[x2 y2 z2 1])
Rect(; x1=0, y1=0, z1=0, x2=0, y2=0, z2=0) = 
  Rect(x1,y1,z1,x2,y2,z2)

function printfh(io::IO,x::Rect)
  print(io,"+ hole rect ")
  @printf(io,"(%.6e, %.6e, %.6e, %.6e, %.6e, %.6e)",
          x.corner1[1],x.corner1[2],x.corner1[3],
          x.corner2[1],x.corner2[2],x.corner2[3])
  println(io)
  return nothing
end

transform(x::Rect, tm::Array{Float64,2}) = Rect(x.corner1*tm,x.corner2*tm)
function transform!(x::Rect, tm::Array{Float64,2})
  corner1 = x.corner1*tm
  corner2 = x.corner2*tm
  x.corner1[1:4] = corner1[1:4]
  x.corner2[1:4] = corner2[1:4]
  return nothing
end

end

immutable Circle <: Hole
  center  :: Array{Float64,2}
  radius  :: Float64
end
Circle(x,y,z,r) = Circle([x y z 1],r)
Circle(; x=0, y=0, z=0, r=0) =
  Circle(x,y,z,r)

function printfh(io::IO,x::Circle)
  print(io,"+ hole circle ")
  @printf(io, "(%.6e, %.6e, %.6e, %.6e)",
          x.center[1],x.center[2],x.center[3],
          x.radius)
  println(io)
  return nothing
end

transform(x::Circle, tm::Array{Float64,2}) = Circle(x.center*tm,x.r)
function transform!(x::Circle, tm::Array{Float64,2})
  center = x.center*tm
  x.center[1:4] = center[1:4]
  return nothing
end

immutable UniformPlane <: Element
  name :: Symbol
  corner1 :: Array{Float64,2}
  corner2 :: Array{Float64,2}
  corner3 :: Array{Float64,2}
  thick :: Float64
  seg1 :: Float64 
  seg2 :: Float64 
  segwid1 :: Float64 
  segwid2 :: Float64 
  sigma :: Float64 
  rho :: Float64 
  nhinc :: Float64 
  rh :: Float64 
  relx :: Float64 
  rely :: Float64 
  relz :: Float64 
  nodes :: Array{Node,1}
  holes :: Array{Hole,1}
  function UniformPlane(name, corner1, corner2, corner3, thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes, holes)
    if isnan(thick)
      throw(ArgumentError("Must specify thick for plane"))
    end
    if isnan(seg1)
      throw(ArgumentError("Must specify seg1 for plane"))
    end
    if isnan(seg2)
      throw(ArgumentError("Must specify seg2 for plane"))
    end
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
    new(Symbol(name), corner1, corner2, corner3, thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes, holes)
  end
end
UniformPlane(;name = :null  
              x1=0, y1=0, z1=0, x2=0, y2=0, z2=0, x3=0, y3=0, z3=0,
              thick = NaN, seg1 = NaN, seg2 = NaN,
              segwid1 = NaN, segwid2 = NaN,
              sigma = NaN, rho = NaN,
              hninc = NaN, rh = NaN,
              relx = NaN, rely = NaN, relz = NaN,
              nodes = [], holes = []) = 
  UniformPlane(name,[x1 y1 z1 1],[x2 y2 z2 1],[x3 y3 z3 1], thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes, holes)

function printfh(io::IO, x:UniformPlane)
  println(io,"G",string(x.name))
  @printf(io,"+ x1=%.6e",x.x.corner1[1]) 
  @printf(io," y1=%.6e",x.corner1[2]) 
  @printf(io," z1=%.6e\n",x.corner1[3]) 
  @printf(io,"+ x2=%.6e",x.corner2[1]) 
  @printf(io," y2=%.6e",x.corner2[2]) 
  @printf(io," z2=%.6e\n",x.corner2[3]) 
  @printf(io,"+ x3=%.6e",x.corner3[1]) 
  @printf(io," y3=%.6e",x.corner3[2]) 
  @printf(io," z3=%.6e\n",x.corner3[3]) 
  @printf(io,"+ thick=%.6e",x.thick) 
  print(io," seg1=",x.seg1)
  println(io," seg2=",x.seg2)
  if ~isnan(x.segwid1)
    @printf(io,"+ segwid1=%.6e\n",x.segwid1) 
  end
  if ~isnan(x.segwid2)
    @printf(io,"+ segwid2=%.6e\n",x.segwid2) 
  end
  if ~isnan(x.sigma)
    @printf(io,"+ sigma=%.6e\n",x.sigma) 
  end
  if ~isnan(x.rho)
    @printf(io,"+ rho=%.6e\n",x.rho) 
  end
  if ~isnan(x.nhinc)
    println(io,"+ nhinc=\n",x.nhinc)
  end
  if ~isnan(x.rh)
    @printf(io,"+ rh=%.6e\n",x.rh) 
  end
  if ~isnan(x.relx)
    @printf(io,"+ relx=%.6e\n",x.relx) 
  end
  if ~isnan(x.rely)
    @printf(io,"+ rely=%.6e\n",x.rely) 
  end
  if ~isnan(x.relz)
    @printf(io,"+ relz=%.6e\n",x.relz) 
  end
  for node in x.nodes
    printfh(io,node,plane=true)
  end
  for hole in x.holes
    printfh(io,hole)
  end
  return nothing
end