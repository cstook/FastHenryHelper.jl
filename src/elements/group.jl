export Group

"""
    Group()
    Group(Array{Element,1})
    Group(Array{Element,1}, Dict{Symbol,Node})

`Group` objects `show` FastHenry commands of their 
elements.

**Fields**

- `elements`    -- Array of `Element`'s
- `terms`       -- Dict{Symbol,Node} # connections to the Group

Groups may be nested.  Automatic name generation will create a 
name for each `Element` in the `Group` and all subgroups as needed 
when `show` is called.  Generated names start with an 
underscore (_1, _2, _3, ...).  Do not use these names for manual 
named elements.

Connection points to the group are in the `terms` dictionary.  The Group
is a dictionary of its terms.  In other words, you may write group[key]
instead of group.terms[key].
"""
immutable Group <: Element
  elements :: Array{Element,1}
  terms :: Dict{Symbol,Node}
end
Group() = Group([],Dict{Symbol,Node}())
Group(e) = Group(e,Dict{Symbol,Node}())

"""
    elements(g::Group)
    elements!(g::Group, e::Element)

Get and set `elements` field in a `Group`.
"""
elements, elements!
elements(g::Group) = g.elements
elements!(g::Group, e::Element) = g.elements = e

"""
    terms(g::Group)
    terms!(g::Group, p::Dict{Symbol,Node})

Get and set the `terms` field in a `Group`.
"""
terms, terms!
terms(g::Group) = g.terms
terms!(g::Group, p::Dict{Symbol,Node}) = g.terms = p

Base.getindex(g::Group, key::Symbol) = g.terms[key]
function Base.setindex!(g::Group, n::Node, key::Symbol)
  g.terms[key] = n
  return nothing
end

function printfh!(io::IO, pfh::PrintFH, group::Group)
  for element in group.elements 
    printfh!(io, pfh, element)
  end
  return nothing
end

function resetiname!(group::Group)
  for element in group.elements 
    resetiname!(element)
  end
end

function transform!(group::Group, tm::Array{Float64,2})
  for i in eachindex(group.elements)
    transform!(group.elements[i],tm)
  end
  return nothing
end

function transform(group::Group, tm::Array{Float64,2})
  newgroup = deepcopy(group)
  transform!(newgroup,tm)
  return newgroup
end

