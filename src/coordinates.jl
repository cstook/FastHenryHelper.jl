# coordinates

export Point, Spherical, Polar, Cartesian

abstract Point

"""
a point or vector in [Spherical](http://mathworld.wolfram.com/SphericalCoordinates.html) coordinates
Spherical(r,θ,φ)
"""
type Spherical <: Point
  "radial"
  r :: Float64 # radial
  "azimuthal"
  θ :: Float64 # azimuthal
  "polar"
  φ :: Float64 # polar
end

"""
a point or vector in [Cartesian](http://mathworld.wolfram.com/CartesianCoordinates.html) coordinates
Polar(r,θ,z)
"""
type Polar <: Point
  "radial"
  r :: Float64 # radial
  "azimuthal"
  θ :: Float64 # azimuthal
  "z"
  z :: Float64
end

"""
a point or vector in [Cylindrical](http://mathworld.wolfram.com/CylindricalCoordinates.html) coordinates
Cartesian(x,y,z)
"""
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

function Base.convert(::Type{Spherical}, arg::Polar)
  convert(Spherical,convert(Cartesian,arg))
end

function Base.convert(::Type{Polar}, arg::Spherical)
  convert(Polar,convert(Cartesian,arg))
end

function Base.convert{T<:Type{Point}}(::T, arg::Array{Point})
  result = Array(T,size(arg))
  for i in eachindex(arg)
    result[i] = convert(T,arg[i])
  end
  return result
end

export translate,translate!

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

function translate{T<:Point}(point::T, vector::Point)
  pc = convert(Cartesian,point)
  vc = convert(Cartesian,vector)
  convert(T,translate(pc,vc))
end

function translate!(point::Point, vector::Point)
  point = translate(point,vector)
  return nothing
end

function translate!(points::Array{Point}, vector::Point)
  for i in eachindex(points)
    translate!(points[i],vector)
  end
  return nothing
end

"""
    translate(point::Point, vector::Point)
    translate!(point::Point, vector::Point)
    translate!(points::Array{Point}, vector::Point)

translates `point` or `points` by `vector`
"""
translate, translate!

export rotate,rotate!

function rotate(point::Spherical, vector::Spherical)
  θ = point.θ + vector.θ
  φ = point.φ + vector.φ
  return Spherical(point.r,θ,φ)
end

function rotate!(point::Spherical, vector::Spherical)
  point.θ += vector.θ
  point.φ += vector.φ
  return nothing
end

function rotate{T<:Point}(point::T, vector::Point)
  ps = convert(Spherical,point)
  vs = convert(Spherical,vector)
  convert(T,rotate(ps,vs))
end

function rotate!(point::Point, vector::Point)
  point = rotate(point,vector)
  return nothing
end

function rotate!(points::Array{Point}, vector::Point)
  for i in eachindex(points)
    rotate!(points[i],vector)
  end
  return nothing
end

"""
    rotate(point::Point, vector::Point)
    rotate!(point::Point, vector::Point)
    rotate!(points::Array{Point}, vector::Point)

rotates `point` or `points` by `vector`
"""
rotate, rotate!

