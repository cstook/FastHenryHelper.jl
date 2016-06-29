# make element an iterator which traverses element tree
immutable NullElement<:Element end

Base.start(e::Element) = e

Base.next(e::Element, state) = state, NullElement()
function Base.next(e::Group, state)
  for groupe in e.elements
    next(groupe,state)
  end
  return NullElement(), NullElement()
end

Base.done(e::Element, state::Element) = false
Base.done(e::Element, state::NullElement) = true
