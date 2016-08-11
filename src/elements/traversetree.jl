# make element an iterator which traverses element tree

type TTState
  togo :: Array{Element,1}
  units :: Units
end

Base.start(element::Element) = TTState([e],Units())
function Base.Start(group::Group)
  if group.units == Units("")
    return TTState([copy(group.element)],group.units)
  else
    return TTState([group.units;copy(group.element)],groupunits)
end




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
