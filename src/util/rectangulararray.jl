export rectangulararray


#
# switch to generator expression:
# f(i) for i in 1:n

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
function rectangulararray(x,y=0.0,z=0.0)
  tm = txyz(0,0,0)
  ch = Channel{typeof(tm)}(1)
  @async begin
    for a in x
      tm[1,4] = a
      for b in y
        tm[2,4] = b
        for c in z
          tm[3,4] = c
          put!(ch,copy(tm))
        end
      end
    end
    close(ch)
  end
  return ch
end
rectangulararray(;x=0.0, y=0.0, z=0.0) = rectangulararray(x,y,z)
