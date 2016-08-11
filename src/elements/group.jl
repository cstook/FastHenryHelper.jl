export Group, terms, terms!, elements, elements!

typealias TermsDict Dict{Symbol,Union{Node,Array{Node,1}}}

"""
    Group([elements [, terms]])

`Group` objects `show` FastHenry commands of their
elements.

**Fields**

- `elements`    -- Array of `Element`'s
- `terms`       -- Dict{Symbol,Node} # connections to the Group

Groups may be nested.  Automatic name generation will create a name for
each `Element` in the `Group` and all subgroups as needed when `show` is
called.  Generated names start with an underscore.  Do not use these names
for user named elements.

`getindex`, `setindex!`, and `merge!` operate on `terms`.
`push!`, `pop!`, `unshift!`, `shift!`, `append!`, `prepend!` operate on `elements`.
"""
type Group <: Element
  elements :: Array{Element,1}
  terms :: TermsDict
  units :: Units
end
Group() = Group([],TermsDict(),Units())
Group(e) = Group(e,TermsDict(),Units())
Group(e,d) = Group(e,d,Units())

units(g::Group) = g.units
function units!(g::Group, u::Units)
  g.units = use
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

deepcopy!(::Dict{Element,Element}, e::Element) = deepcopy(e)
function deepcopy!(nodedict::Dict{Element,Element}, n::Node)
  newnode = Node(Symbol(""), n.xyz1[1], n.xyz1[2], n.xyz1[3])
  nodedict[n] = newnode
  return newnode
end
function deepcopy!(nodedict::Dict{Element,Element}, seg::Segment)
  node1 = nodedict[seg.node1]
  node2 = nodedict[seg.node2]
  Segment(deepcopy(seg.name),
          node1, node2,
          deepcopy(seg.wh),
          deepcopy(seg.sigmarho),
          deepcopy(seg.wxwywz))
end
function deepcopy!(nodedict::Dict{Element,Element}, p::UniformPlane)
  newnodes = similar(p.nodes)
  for i in eachindex(p.nodes)
    deepcopy!(nodedict,p.nodes[i])
    newnodes[i] = nodedict[p.nodes[i]]
  end
  UniformPlane(deepcopy(p.name),
               deepcopy(p.corner1),
               deepcopy(p.corner2),
               deepcopy(p.corner3),
               p.thick,p.seg1,p.seg2,p.segwid1,p.segwid2,p.sigma,p.rho,
               p.nhinc,p.rh,p.relx,p.rely,p.relz,
               newnodes,
               deepcopy(p.holes))
end

# need to make sure nodes in segments still === the correct node
function Base.deepcopy(group::Group)
  elements = similar(group.elements)
  nodedict = Dict{Element,Element}()
  for i in eachindex(group.elements)
    elements[i] = deepcopy!(nodedict::Dict{Element,Element}, group.elements[i])
  end
  newgroup = Group(elements)
  for (key,value) in group.terms
    newgroup.terms[key] = newvalue(nodedict,value) # nodedict[value]
  end
  return newgroup
end

newvalue(nodedict::Dict{Element,Element}, value::Node) = nodedict[value]
function newvalue(nodedict::Dict{Element,Element}, value::Array{Node,1})
  nv = similar(value)
  for i in eachindex(value)
    nv[i] = nodedict[value[i]]
  end
  return nv
end
