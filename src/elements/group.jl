export Group, terms, terms!, elements, elements!

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

`getindex`, `setindex!`, and `merge!` work on `terms`.
`push!`, `pop!`, `unshift!`, `shift!`, `append!`, `prepend!` work on `elements`.
"""
type Group <: Element
  elements :: Array{Element,1}
  terms :: Dict{Symbol,Node}
end
Group() = Group([],Dict{Symbol,Node}())
Group(e) = Group(e,Dict{Symbol,Node}())


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
function terms!(g::Group, p::Dict{Symbol,Node})
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
function Base.setindex!(g::Group, n::Node, key::Symbol)
  g.terms[key] = n
  return nothing
end
Base.merge!(g::Group, args...) = merge(g.terms, args...)
Base.push!(g::Group, args...) = push!(g.elements, args...)
Base.pop!(g::Group) = pop!(g.elements)
Base.unshift!(g::Group, args...) = unshift!(g.elements, args...)
Base.shift!(g::Group) = shift!(g.elements)
Base.append!(g1::Group, g2::Group) = append!(g1.elements, g2.elements)
Base.prepend!(g1::Group, g2::Group) = prepend!(g1.elements, g2.elements)

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

elementcopy!(::Dict{Element,Element}, e::Element) = deepcopy(e)
function elementcopy!(nodedict::Dict{Element,Element}, n::Node)
  newnode = deepcopy(n)
  nodedict[n] = newnode
  return newnode
end
function elementcopy!(nodedict::Dict{Element,Element}, seg::Segment)
  node1 = nodedict[seg.node1]
  node2 = nodedict[seg.node2]
  Segment(seg.name.name, node1, node2, seg.wh, seg.sigmarho, seg.wxwywz)
end

# need to make sure nodes in segments still === the corrent node
function elementcopy(group::Group)
  newgroup = Group()
  nodedict = Dict{Element,Element}()
  for element in group.elements
    newelement = elementcopy!(nodedict::Dict{Element,Element}, element)
    push!(newgroup,newelement)
  end
  for (key,value) in group.terms
    newgroup.terms[key] = nodedict[value]
  end
  return newgroup
end
#=
function transform(group::Group, tm::Array{Float64,2})
  newgroup = deepcopy(group)
  transform!(newgroup,tm)
  return newgroup
end
=#

function plotdata!(pd::PlotData, group::Group)
  for i in eachindex(group.elements)
    plotdata!(pd,group.elements[i])
  end
  return nothing
end