# cooridnates

abstract Point

"a point or vector in [Spherical](http://mathworld.wolfram.com/SphericalCoordinates.html) cooridnates"
type Spherical <: Point
  "radial"
  r :: Float64 # radial
  "azimuthal"
  θ :: Float64 # azimuthal
  "polar"
  φ :: Float64 # polar
end

"a point or vector in [Cartesian](http://mathworld.wolfram.com/CartesianCoordinates.html) cooridnates"
type Polar <: Point
  "radial"
  r :: Float64 # radial
  "azimuthal"
  θ :: Float64 # azimuthal
  "z"
  z :: Float64
end

"a point or vector in [Cylindrical](http://mathworld.wolfram.com/CylindricalCoordinates.html) cooridnates"
type Cartesian <: Point
  x :: Float64
  y :: Float64
  z :: Float64
end

function Base.convert(::Type{Spherical}, arg::Cartesian)
  r = sqrt(arg.x^2 + arg.y^2 + arg.z^2)
  θ = atan2(arg.y,arg.x)
  φ = acos(arg.z/r)
  return Spherical(r,θ,φ)
end

function Base.convert(::Type{Cartesian}, arg::Spherical)
  x = arg.r*cos(arg.θ)*sin(arg.φ)
  y = arg.r*sin(arg.θ)*sin(arg.φ)
  z = arg.r*cos(arg.φ)
  return Cartesian(x,y,z)
end

function Base.convert(::Type{Polar}, arg::Cartesian)
  r = sqrt(arg.x^2 + arg.y^2)
  θ = atan2(arg.y,arg.x)
  z = arg.z
  return Polar(r,θ,z)
end

function Base.convert(::Type{Cartesian}, arg::Polar)
  x = arg.r*cos(arg.θ)
  y = arg.r*sin(arg.θ)
  z = arg.z
  return Cartesian(x,y,z)
end

function translate(point::Cartesian, vector::Cartesian)
  x = point.x + vector.x
  y = point.y + vector.y 
  z = point.z + vector.z
  return (Cartesian(x,y,z))
end

function translate!(point::Cartesian, vector::Cartesian)
  point.x += vector.x
  point.y += vector.y 
  point.z += vector.z
  return nothing
end

function translate{T::Point}(point::T, vector::Point)
  pc = convert(Cartesian,point)
  vc = convert(Cartesian,vector)
  convert(T,translate(pc,vc))
end