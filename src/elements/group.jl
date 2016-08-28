export Group, terms, terms!, elements, elements!

typealias TermsDict Dict{Symbol,Union{Node,Array{Node,1}}}

"""
    Group([elements [, terms]])

`Group` objects `show` FastHenry commands of their
elements.

**Fields**

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


# If you decide to put this back, need to use Base.deepcopy_internal
# in function declaration and call.
#=
function deepcopy_internal(e::Element, oidd::ObjectIdDict)
  newelement = deepcopy(e)
  oidd[e] = newelement
  return newelement
end
function deepcopy_internal(n::Node, oidd::ObjectIdDict)
  newnode = Node(Symbol(""), n.xyz1[1], n.xyz1[2], n.xyz1[3])
  oidd[n] = newnode
  return newnode
end
function deepcopy_internal(seg::Segment, oidd::ObjectIdDict)
  node1 = oidd[seg.node1]
  node2 = oidd[seg.node2]
  newsegment = Segment(deepcopy(seg.name),
    node1, node2,
    deepcopy(seg.wh),
    deepcopy(seg.sigmarho),
    deepcopy(seg.wxwywz))
  oidd[seg] = newsegment
  return newsegment
end
function deepcopy_internal(p::UniformPlane, oidd::ObjectIdDict)
  newnodes = similar(p.nodes)
  for i in eachindex(p.nodes)
    deepcopy_internal(p.nodes[i],oidd)
    newnodes[i] = oidd[p.nodes[i]]
  end
  newplane = UniformPlane(deepcopy(p.name),
    deepcopy(p.corner1),
    deepcopy(p.corner2),
    deepcopy(p.corner3),
    p.thick,p.seg1,p.seg2,p.segwid1,p.segwid2,p.sigma,p.rho,
    p.nhinc,p.rh,p.relx,p.rely,p.relz,
    newnodes,
    deepcopy(p.holes))
  oidd[p] = newplane
  return newplane
end

# need to make sure nodes in segments still === the correct node
function deepcopy_internal(group::Group, oidd::ObjectIdDict)
  println(length(oidd)); wait(Timer(.5))
  if haskey(oidd,group)
    return oidd[group]
  end
  elements = similar(group.elements)
  newgroup = Group(elements)
  # allow deepcopy of recursive structures.  which should never happen anyway.
  oidd[group] = newgroup # key is object to be copied, value is copy
  for i in eachindex(group.elements)
    elements[i] = deepcopy_internal(group.elements[i], oidd)
  end
  for (key,value) in group.terms
    newgroup.terms[key] = newvalue(oidd,value) # oidd[value]
  end
  return newgroup
end

newvalue(oidd::ObjectIdDict, value::Node) = oidd[value]
function newvalue(oidd::ObjectIdDict, value::Array{Node,1})
  nv = similar(value)
  for i in eachindex(value)
    nv[i] = oidd[value[i]]
  end
  return nv
end
=#
