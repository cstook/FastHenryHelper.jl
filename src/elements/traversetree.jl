# make element an iterator which traverses element tree

type TTState
  togo :: Array{Element,1}
  units :: Units
end
update!(state::TTState, state1::Element) = nothing
function update!(state::TTState, state1::Group)
  # replace group with its elements.
  # must pass first element of state.togo as second parameter
  # for proper dispach
  shift!(state.togo)
  if state1.units == Units()
    prepend!(state.togo, state1.elements)
  else
    unshift!(state.togo, state.units)
    prepend!(state.togo, state1.elements)
    unshift!(state.togo, state1.units)
  end
  update!(state, state.togo[1])
end

Base.start(element::Element) = TTState([element],Units())
function Base.start(group::Group)
  if group.units == Units()
    return TTState(copy(group.elements),group.units)
  else
    return TTState([group.units;copy(group.elements)],groupunits)
  end
end
function Base.next(element::Element, state::TTState)
  update!(state, state.togo[1]) # in case element is a group
  returnelement = shift!(state.togo)
  return (returnelement, state)
end
Base.done(element::Element, state::TTState) = length(state.togo) == 0




#=

# old version #############
# state is an array of elements to be retruned
Base.start(e::Element) = [e]
Base.start(e::Group) = copy(e.elements)

function Base.next(e::Element, state)
  updatestate!(state, state[1]) # in case element is a group
  item = shift!(state)
  return (item,state)
end

Base.done(e::Element, state) = length(state) == 0

updatestate!(state, s::Element) = nothing
function updatestate!(state, s::Group)
  # replace group with its elements
  shift!(state)
  prepend!(state,s.elements)
  updatestate!(state, state[1])
  return nothing
end
=#
