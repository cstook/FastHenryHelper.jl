# make element an iterator which traverses element tree
# bunch of extra code for group units

type TTState
  togo :: Array{Element,1}
  units :: Units
  usingunits :: Bool
end
update!(state::TTState, state1::Element) = nothing
function update!(state::TTState, state1::Group)
  # replace group with its elements.
  # must pass first element of state.togo as second parameter
  # for proper dispach
  shift!(state.togo)
  if state1.units == Units() # group has no units
    prepend!(state.togo, state1.elements)
  else # group has units
    if state.usingunits # caller has units
      unshift!(state.togo, state.units)  # switch back to callers units
    else # caller has no units
      unshift!(state.togo, Units("m")) # switch back to default callers units
    end
    prepend!(state.togo, state1.elements) # group elements
    unshift!(state.togo, state1.units) # switch to group units
  end
  update!(state, state.togo[1])
end

Base.start(element::Element) = TTState([element],Units(),false)
function Base.start(group::Group)
  if group.units == Units()
    return TTState(copy(group.elements), group.units, false)
  else
    return TTState([group.units;copy(group.elements)], group.units, true)
  end
end
function Base.next(element::Element, state::TTState)
  update!(state, state.togo[1]) # in case element is a group
  returnelement = shift!(state.togo)
  if isunits(returnelement)
    state.usingunits = true
    state.units = returnelement
  end
  return (returnelement, state)
end
Base.done(element::Element, state::TTState) = length(state.togo) == 0

isunits(::Element) = false
isunits(::Units) = true
