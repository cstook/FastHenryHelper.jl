export Group, terms, terms!, elements, elements!

const TermsDict = Dict{Symbol,Union{Node,Array{Node,1}}}
"""
    Group([elements [, terms[, units]]])
    Group(<keyword arguments>)

`Group` objects `show` FastHenry commands of their
elements.

**Keyword Arguments**

- `elements`    -- Array of `Element`'s
- `terms`       -- Dict{Symbol,Node} # connections to the Group
- `units`       -- Units used for the Group

Groups may be nested.  Automatic name generation will create a name for
each `Element` in the `Group` and all subgroups as needed when `show` is
called.  Generated names start with an underscore.  Do not use these names
for user named elements.

`getindex`, `setindex!`, and `merge!` operate on `terms`.
`push!`, `pop!`, `unshift!`, `shift!`, `append!`, `prepend!` operate on `elements`.
"""
mutable struct Group <: Element
  elements :: Array{Element,1}
  terms :: TermsDict
  units :: Units
end
# Group() = Group([],TermsDict(),Units())
Group(e) = Group(e,TermsDict(),Units())
Group(e,d) = Group(e,d,Units())
Group(;elements=[],terms=TermsDict(),units=Units())= Group(elements,terms,units)

units(g::Group) = g.units
function units!(g::Group, u::Units)
  g.units = u
  return nothing
end

elements(g::Group) = g.elements
function elements!{T<:Element}(g::Group, e::Array{T,1})
  g.elements = e
  return nothing
end
"""
    elements(g::Group)
    elements!(g::Group, e::Element)

Get and set `elements` field in a `Group`.
"""
elements, elements!


terms(g::Group) = g.terms
function terms!(g::Group, p)
  g.terms = p
  return nothing
end
"""
    terms(g::Group)
    terms!(g::Group, p::Dict{Symbol,Node})

Get and set the `terms` field in a `Group`.
"""
terms, terms!

Base.getindex(g::Group, key::Symbol) = g.terms[key]
function Base.setindex!(g::Group, n::Union{Node,Array{Node,1}}, key::Symbol)
  g.terms[key] = n
  return nothing
end
function Base.merge!(g::Group, args...)
  for arg in args
    merge!(g.terms, arg.terms)
  end
end
Base.push!(g::Group, args...) = push!(g.elements, args...)
Base.pop!(g::Group) = pop!(g.elements)
Base.unshift!(g::Group, args...) = unshift!(g.elements, args...)
Base.shift!(g::Group) = shift!(g.elements)
Base.append!(g1::Group, g2::Group) = append!(g1.elements, g2.elements)
Base.prepend!(g1::Group, g2::Group) = prepend!(g1.elements, g2.elements)
