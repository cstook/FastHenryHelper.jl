export rectangulararray

function transform(e::Element, transformationlist)
  elementarraygroup(e, transformationlist)
end
function transform(e::Group, transformationlist)
  newgroup = elementarraygroup(e, transformationlist)
  newterms = terms(newgroup)
  for key in keys(terms(elements(newgroup)[1]))
    newterms[key] = Array(Node,0)
  end
  for subgroup in newgroup
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
function addterm!{T::Node}(newterms, key, value::Array{T,1})
  append!(newterms[key],value)
  return nothing
end
function addterm!(newterms, key, value::Node)
  push!(newterms[key],value)
  return nothing
end

"""
    rectangulararray(x[,y[,z]])
    rectangulararray(<keyword arguments>)

Used with `transform` to create rectangular arrays of elements.

`rectangulararray` returns a iterable object which returns a sequence of
transformation matrices, which when passed to `transform` will produce
a rectangular array of elements.  `x`, `y`, and `z` are iterable objects
which specify the offsets along the x, y, and z axis.  Unspecified
arguments are zero.
"""
function rectangulararray(x=0.0,y=0.0,z=0.0)
  function producer(x,y,z)
    tm = txyz(0,0,0)
    for a in x
      tm[1,4] = a
      for b in y
        tm[2,4] = b
        for c in z
          tm[3,4] = c
          produce(tm)
        end
      end
    end
  end
  return Task(() -> producer(x,y,z))
end
rectangulararray(;x=0.0, y=0.0, z=0.0) = rectangulararray(x,y,z)
