export UniformPlane, Point, Rect, Circle, Hole


"""
Subtypes of `Hole` are holes in a plane.

**Subtypes**

- Point
- Rect
- Circle
"""
abstract Hole <: Element

"""
    Point(x, y, z)
    Point(<keyword arguments>)

`Point` objects are used for point holes in a `UniformPlane`.

Keyword arguments are `x`, `y`, `z`.
"""
immutable Point <: Hole
  xyz1  :: Array{Float64,1}
end
Point(x,y,z) = Point([x,y,z,1])
Point(; x=0, y=0, z=0) = Point(x,y,z)

function Base.show(io::IO, x::Point)
  print(io,"+ hole point ")
  @printf(io,"(%.9e, %.9e, %.9e)",x.xyz1[1],x.xyz1[2],x.xyz1[3])
  println(io)
  return nothing
end

function _transform!(x::Point, tm::Array{Float64,2}, scale::Float64)
  x.xyz1[1:3] *= scale
  xyz1 = tm*x.xyz1
  x.xyz1[1:4] = xyz1[1:4]
  x.xyz1[1:3] *= 1.0/scale
  return nothing
end


"""
    Rect(x1, y1, z1, x2, y2, z2)
    Rect(<keyword arguments>)

`Rect` objects are used for rectangular holes in a `UniformPlane`.

Keyword arguments are `x1`, `y1`, `z1`, `x2`, `y2`, `z2`.
"""
immutable Rect <: Hole
  corner1  :: Array{Float64,1}
  corner2  :: Array{Float64,1}
end
Rect(x1,y1,z1,x2,y2,z2) = Rect([x1,y1,z1,1],[x2,y2,z2,1])
Rect(; x1=0, y1=0, z1=0, x2=0, y2=0, z2=0) =
  Rect(x1,y1,z1,x2,y2,z2)

function Base.show(io::IO, x::Rect)
  print(io,"+ hole rect ")
  @printf(io,"(%.9e, %.9e, %.9e, %.9e, %.9e, %.9e)",
          x.corner1[1],x.corner1[2],x.corner1[3],
          x.corner2[1],x.corner2[2],x.corner2[3])
  println(io)
  return nothing
end

function _transform!(x::Rect, tm::Array{Float64,2}, scale::Float64)
  x.corner1[1:3] *= scale
  x.corner2[1:3] *= scale
  corner1 = tm*x.corner1
  corner2 = tm*x.corner2
  x.corner1[1:4] = corner1[1:4]
  x.corner2[1:4] = corner2[1:4]
  x.corner1[1:3] *= 1/scale
  x.corner2[1:3] *= 1/scale
  return nothing
end

"""
    Circle(x, y, z, r)
    Circle(<keyword arguments>)

`Circle` objects are used for circular holes in a `UniformPlane`.

Keyword arguments are `x`, `y`, `z`, `r`.
"""
immutable Circle <: Hole
  xyz1    :: Array{Float64,1} # center
  radius  :: Float64
end
Circle(x,y,z,r) = Circle([x,y,z,1],r)
Circle(; x=0, y=0, z=0, r=0) =
  Circle(x,y,z,r)

function Base.show(io::IO, x::Circle)
  print(io,"+ hole circle ")
  @printf(io, "(%.9e, %.9e, %.9e, %.9e)",
          x.xyz1[1],x.xyz1[2],x.xyz1[3],
          x.radius)
  println(io)
  return nothing
end

function _transform!(x::Circle, tm::Array{Float64,2}, scale::Float64)
  x.xyz1[1:3] *= scale
  xyz1 = tm*x.xyz1
  x.xyz1[1:4] = xyz1[1:4]
  x.xyz1[1:3] *= 1/scale
  return nothing
end

"""
    UniformPlane(<keyword arguments>)

`UniformPlane` objects `show` a FastHenry uniform discretized plane command.

**Keyword Arguments**

- `name`              -- plane name
- `x1`,`y1`,`z1`      -- coordinate of first corner
- `x2`,`y2`,`z2`      -- coordinate of second corner
- `x3`,`y3`,`z3`      -- coordinate of third corner
- `thick`             -- segment thickness
- `seg1`,`seg2`       -- number of segments along each side of plane
- `segwid1`,`segwid2` -- segment width
- `sigma`,`rho`       -- specify conductivity or resistivity
- `nhinc`             -- integer number of filaments
- `rh`                -- filament ratio
- `relx`,`rely`,`relz`-- see FastHenry documentation
- `nodes`             -- Array of `Node` connection points to plane
- `holes`             -- Array of `Hole` (`Point`, `Rect`, or `Circle`)
"""
immutable UniformPlane <: Element
  name :: Symbol
  corner1 :: Array{Float64,1}
  corner2 :: Array{Float64,1}
  corner3 :: Array{Float64,1}
  thick :: Float64
  seg1 :: Int
  seg2 :: Int
  segwid1 :: Float64
  segwid2 :: Float64
  sigma :: Float64
  rho :: Float64
  nhinc :: Int
  rh :: Int
  relx :: Float64
  rely :: Float64
  relz :: Float64
  nodes :: Array{Node,1}
  holes :: Array{Hole,1}
  function UniformPlane(name, corner1, corner2, corner3, thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes::Array{Node,1}, holes)
    if isnan(thick)
      throw(ArgumentError("Must specify thick for plane"))
    end
    if seg1<1
      throw(ArgumentError("Must specify seg1>0 for plane"))
    end
    if seg2<1
      throw(ArgumentError("Must specify seg2>0 for plane"))
    end
    if nhinc<0
      throw(ArgumentError("nhinc must be a positive integer"))
    end
    if rh<0
      throw(ArgumentError("rh must be positive integer"))
    end
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
    v1 = corner1 - corner2
    v2 = corner3 - corner2
    if abs(dot(v1/norm(v1), v2/norm(v2))) > 1e-9
      throw(ArgumentError("Corners do not form a rectangle"))
    end
    new(Symbol(name), corner1, corner2, corner3, thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes, holes)
  end
end
function UniformPlane(name, corner1, corner2, corner3, thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes::Node, holes)
  UniformPlane(name, corner1, corner2, corner3, thick, seg1, seg2,
        segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
        [nodes], holes)
end
UniformPlane(;name = Symbol(""),
              x1=0, y1=0, z1=0, x2=0, y2=0, z2=0, x3=0, y3=0, z3=0,
              thick = NaN, seg1 = 0, seg2 = 0,
              segwid1 = NaN, segwid2 = NaN,
              sigma = NaN, rho = NaN,
              nhinc = 0, rh = 0,
              relx = NaN, rely = NaN, relz = NaN,
              nodes = Array{Node,1}(), holes = []) =
  UniformPlane(name,[x1,y1,z1,1],[x2,y2,z2,1],[x3,y3,z3,1], thick, seg1, seg2,
                segwid1, segwid2, sigma, rho, nhinc, rh, relx, rely, relz,
                nodes, holes)

function _transform!(x::UniformPlane, tm::Array{Float64,2}, scale::Float64)
  x.corner1[1:3] *= scale
  x.corner2[1:3] *= scale
  x.corner3[1:3] *= scale
  corner1 = tm*x.corner1
  x.corner1[1:4] = corner1[1:4]
  corner2 = tm*x.corner2
  x.corner2[1:4] = corner2[1:4]
  corner3 = tm*x.corner3
  x.corner3[1:4] = corner3[1:4]
  x.corner1[1:3] *= 1/scale
  x.corner2[1:3] *= 1/scale
  x.corner3[1:3] *= 1/scale
  for i in eachindex(x.nodes)
    _transform!(x.nodes[i],tm,scale)
  end
  for i in eachindex(x.holes)
    _transform!(x.holes[i],tm,scale)
  end
  return nothing
end
