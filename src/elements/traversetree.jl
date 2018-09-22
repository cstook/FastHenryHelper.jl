mutable struct TTState
  currentunits :: Units
end

global function _traverseTree(e::Element, c::Channel, ::TTState)
  put!(c, e)
end
global function _traverseTree(u::Units, c::Channel, state::TTState)
  put!(c, u)
  state.currentunits = u
end
global function _traverseTree(g::Group, c::Channel, state::TTState)
  previousunits = state.currentunits
  if g.units != Units()
    put!(c, g.units)
    state.currentunits = g.units
  end
  for e in g.elements
    _traverseTree(e, c, state)
  end
  if g.units != Units()
    put!(c, previousunits)
    state.currentunits = previousunits
  end
end
function __traverseTree(e,c)
  _traverseTree(e,c,TTState(Units("mm")))
  close(c)
end

function traverseTree(e::Element)
  c = Channel{Element}(32)
  @async __traverseTree(e,c)
  return c
end
