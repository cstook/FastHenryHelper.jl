export rectangulararray

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
