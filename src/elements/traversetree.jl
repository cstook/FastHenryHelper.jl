# make element an iterator which traverses element tree
# TODO
# might be more efficent with IObuffer instead of shifting and
# prepending an array

Base.start(e::Element) = [e]
Base.start(e::Group) = copy(e.elements)

updatestate!(state, s::Element) = nothing
function updatestate!(state, s::Group)
  # replace group with its elements
  shift!(state)
  prepend!(state,s.elements)
  return nothing
end

function Base.next(e::Element, state)
  updatestate!(state, state[1])
  item = shift!(state)
  return (item,state)
end

Base.done(e::Element, state) = length(state) == 0
