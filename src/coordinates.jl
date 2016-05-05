# coordinates

export Point, Spherical, Polar, Cartesian

abstract Point

"""
a point or vector in [Spherical](http://mathworld.wolfram.com/SphericalCoordinates.html) coordinates<br>
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
a point or vector in [Cartesian](http://mathworld.wolfram.com/CartesianCoordinates.html) coordinates<br>
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
a point or vector in [Cylindrical](http://mathworld.wolfram.com/CylindricalCoordinates.html) coordinates<br>
Cartesian(x,y,z)
"""
type Cartesian <: Point
  x :: Float64
  y :: Float64
  z :: Float64
end

function Base.convert(::Type{Spherical}, arg::Cartesian)
  if arg.x==0.0 && arg.y==0.0 && arg.z==0.0
    return Spherical(0,0,0)
  end
  r = sqrt(arg.x^2 + arg.y^2 + arg.z^2)
  θ = atan2(arg.y,arg.x)
  φ = acos(arg.z/r)
  return Spherical(r,θ,φ)
end

function Base.convert(::Type{Cartesian}, arg::Spherical)
  if arg.r==0.0
    return Cartesian(0,0,0)
  end
  x = arg.r*cos(arg.θ)*sin(arg.φ)
  y = arg.r*sin(arg.θ)*sin(arg.φ)
  z = arg.r*cos(arg.φ)
  return Cartesian(x,y,z)
end

function Base.convert(::Type{Polar}, arg::Cartesian)
  if arg.x==0 && arg.y==0
    return Polar(0,0,arg.z)
  end
  r = sqrt(arg.x^2 + arg.y^2)
  θ = atan2(arg.y,arg.x)
  z = arg.z
  return Polar(r,θ,z)
end

function Base.convert(::Type{Cartesian}, arg::Polar)
  if arg.r==0
    return Cartesian(0,0,arg.z)
  end
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

function Base.convert{T<:Point,S<:Point}(::Type{T}, arg::Array{S})
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
  newpoint = translate(point,vector)
  point.(1) = newpoint.(1)
  point.(2) = newpoint.(2)
  point.(3) = newpoint.(3)
  return nothing
end

function translate!{T<:Point}(points::Array{T}, vector::Point)
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

"""
    rx(α) = [[1 0 0];[0 cos(α) sin(α)];[0 -sin(α) cos(α)]]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle α around x axis.
"""
rx(α) = [[1 0 0];[0 cos(α) sin(α)];[0 -sin(α) cos(α)]]

"""
    ry(β) = [[cos(β) 0 -sin(β)];[0 1 0];[sin(β) 0 cos(β)]]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle β around y axis.
"""
ry(β) = [[cos(β) 0 -sin(β)];[0 1 0];[sin(β) 0 cos(β)]]

"""
    rz(γ) = [[cos(γ) sin(γ) 0];[-sin(γ) cos(γ) 0];[0 0 1]]

[rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) for angle γ around z axis.
"""
rz(γ) = [[cos(γ) sin(γ) 0];[-sin(γ) cos(γ) 0];[0 0 1]]

export rotate,rotate!

function rotate(point::Cartesian, rotationmatrix::Array{Float64,2})
  newpoint = [point.x point.y point.z]*rotationmatrix
  Cartesian(newpoint.x, newpoint.y, newpoint.z)
end

function rotate!(point::Cartesian, rotationmatrix::Array{Float64,2})
  newpoint = [point.x point.y point.z]*rotationmatrix
  point.x = newpoint[1]
  point.y = newpoint[2]
  point.z = newpoint[3]
  return nothing
end

function rotate{T<:Point}(point::T, rotationmatrix::Array{Float64,2})
  ps = convert(Cartesian,point)
  convert(T,rotate(ps,rotationmatrix))
end

function rotate!(point::Point, rotationmatrix::Array{Float64,2})
  newpoint = rotate(point,rotationmatrix)
  point.(1) = newpoint.(1)
  point.(2) = newpoint.(2)
  point.(3) = newpoint.(3)
  return nothing
end

function rotate!{T<:Point}(points::Array{T}, rotationmatrix::Array{Float64,2})
  for i in eachindex(points)
    rotate!(points[i],rotationmatrix)
  end
  return nothing
end

function rotate{T<:Point}(points::Array{T}, rotationmatrix::Array{Float64,2})
  result = similar(points)
  for i in eachindex(points)
    result[i] = rotate(points[i],rotationmatrix)
  end
  return result
end

rotate(p, α::Float64, β::Float64, γ::Float64) = rotate(p,rx(α)*ry(β)*rz(γ))
rotate!(p, α::Float64, β::Float64, γ::Float64) = rotate!(p,rx(α)*ry(β)*rz(γ))

"""
    rotate(point::Point, rotationmatrix::Array{Float64,2})
    rotate!(point::Point, rotationmatrix::Array{Float64,2})
    rotate!(points::Array{Point}, rotationmatrix::Array{Float64,2})
    rotate(points, α::Float64, β::Float64, γ::Float64)
    rotate!(points, α::Float64, β::Float64, γ::Float64)

rotates `point` or `points`

specify rotation by [rotation matrix](http://mathworld.wolfram.com/RotationMatrix.html) 
or α, β, γ angles around x,y,z axis
"""
rotate, rotate!

