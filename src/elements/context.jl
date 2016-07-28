export contextdict

immutable Context
  default :: Default
  units :: Units
  autoname :: Int
  firstunits :: Units
end
Context() = Context(Default(), Units("m"), 0, Units())

function contextdict(element::Element)
  cd = Dict{Element,Context}()
  c = Context()
  for e in element
    c = context(c,e)
    cd[e] = c
  end
  return cd
end

function context(c::Context, x::Default)
  Context(x, c.units, c.autoname, c.firstunits)
end
function context(c::Context, x::Units)
  if c.firstunits == Units()
    Context(c.default, x, c.autoname, x)
  else
    Context(c.default, x, c.autoname, c.firstunits)
  end
end
function context(c::Context, x::Union{Node,Segment,UniformPlane})
  if x.name == Symbol("")
    return Context(c.default, c.units, c.autoname+1 , c.firstunits)
  else
    return c
  end
end
context(c::Context, ::Element) = c
