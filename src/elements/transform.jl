export transform, transform!

transform{T<:Number}(x::Element, tm::Array{T,2}) = _transform(x,tm)
transform{T<:Number}(x::Group, tm::Array{T,2}) = _transform(x,tm)
function _transform{T<:Number}(x::Element, tm::Array{T,2})
  newx = deepcopy(x)
  transform!(newx,tm)
  return newx
end

transform!{T<:Number}(::Element, ::Array{T,2}) = nothing
function transform!{T<:Element}(x::Array{T,1}, tm::Array{Float64,2})
  for i in eachindex(x)
    transform!(x[i],tm)
  end
end
function transform!(element::Element, tm::Array{Float64,2},
                    context::Context = Context(element))
  for e in element
    _transform!(e,tm,context)
  end
end
function tmscaletofirstunits(tm::Array{Float64,2},
                             element::Element,
                             context::Context)
  scale = scaletofirstunits(element,context)
  invscale = 1/scale
  scalexyz(invscale,invscale,invscale)*tm*scalexyz(scale,scale,scale)
end

_transform!(::Element, ::Array{Float64,2}, ::Context) = nothing
function _transform!(n::Node, tm::Array{Float64,2})
  n.xyz1[1:4] = tm*n.xyz1
  return nothing
end
function _transform!(n::Node, tm::Array{Float64,2}, context::Context)
  _transform!(n,tmscaletofirstunits(tm,n,context))
  return nothing
end
function _transform!(s::Segment, tm::Array{Float64,2}, context::Context)
  #assumes nodes are transformed as part of a group
  s.wxwywz.xyz[1:3] = tm[1:3,1:3]*s.wxwywz.xyz
  s.wxwywz.isdefault = false
  return nothing
end
function _transform!(x::UniformPlane, tm::Array{Float64,2}, context::Context)
  tmscale = tmscaletofirstunits(tm,x,context)
  x.corner1[1:4] = tmscale*x.corner1
  x.corner2[1:4] = tmscale*x.corner2
  x.corner3[1:4] = tmscale*x.corner3
  for i in eachindex(x.nodes)
    _transform!(x.nodes[i],tmscale)
  end
  for i in eachindex(x.holes)
    _transform!(x.holes[i],tmscale)
  end
  return nothing
end
function _transform!(x::Point, tm::Array{Float64,2})
  x.xyz1[1:4] = tm*x.xyz1
  return nothing
end
function _transform!(x::Rect, tm::Array{Float64,2})
  x.corner1[1:4] = tm*x.corner1
  x.corner2[1:4] = tm*x.corner2
  return nothing
end
function _transform!(x::Circle, tm::Array{Float64,2})
  x.xyz1[1:4] = tm*x.xyz1
  return nothing
end

# for creating Groups of elements
function transform(e::Element, transformationlist)
  elementarraygroup(e, transformationlist)
end
function transform(e::Group, transformationlist)
  newgroup = elementarraygroup(e, transformationlist)
  newterms = terms(newgroup)
  for key in keys(terms(elements(newgroup)[1]))
    newterms[key] = Array{Node}(0)
  end
  for subgroup in elements(newgroup)
    for (key,value) in terms(subgroup)
      addterm!(newterms, key, value)
    end
  end
  return newgroup
end
function elementarraygroup(e::Element, transformationlist)
  newgroup = Group()
  newelements = elements(newgroup)
  for tm in transformationlist
    push!(newelements,transform(e,tm))
  end
  return newgroup
end
function addterm!(newterms::Dict{Symbol,Union{Node,Array{Node,1}}},
                           key::Symbol, value::Array{Node,1})
  append!(newterms[key],value)
  return nothing
end
function addterm!(newterms::Dict{Symbol,Union{Node,Array{Node,1}}},
                           key::Symbol, value::Node)
  push!(newterms[key],value)
  return nothing
end

"""
    transform(element, transformation_matrix)
    transform!(element, transformation_matrix)

Transform (rotate, translate, scale, etc...) a element by 4x4
[transform matrix](# http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/geometry/geo-tran.html)
 `tm`.

 Transform will modify the coordinates of `Element`s and the `wx`, `wy`, and `wz`
 parameters of `Segment`.  `transform` of a `Segment` will not modify its `Node`s.
 `transform` a `Group` containing the `Node`s and `Segment` instead.  Typically
 `transform` would only be applied to `Group` objects.

`transform(element, transformation_matrix_list)`

Return a `Group` of copies of `element` transformed by each matrix in
`transformation_matrix_list`.

If the `element` is a `Group`, the terms of the returned group has the same
keys as `element`, but the values are arrays of `Nodes` of all the copies of
elements.  In other words, the elements are electricaly in parallel.
"""
transform, transform!
