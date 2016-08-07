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
  scale = 1.0
  for e in element
    if haskey(context.dict,e)
      scale = scaletofirstunits(e,context)
    end
    _transform!(e,tm,scale)
  end
end
_transform!(::Element, ::Array{Float64,2}, ::Float64) = nothing

# for creating Groups of elements
function transform(e::Element, transformationlist)
  elementarraygroup(e, transformationlist)
end
function transform(e::Group, transformationlist)
  newgroup = elementarraygroup(e, transformationlist)
  newterms = terms(newgroup)
  for key in keys(terms(elements(newgroup)[1]))
    newterms[key] = Array(Node,0)
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
