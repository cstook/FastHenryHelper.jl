export planeconnect

"""
    planeconnect(Array{Node,1})
    planeconnect(Node)

Provides objects needed to connect to a plane.

Returns a tuple of a deepcopy of the nodes passed and a group of equiv objects
 connecting the nodes passed to the nodes returned.

`(planenodearray, equivgroup) = planeconnect(nodearray)`
"""
function planeconnect(nodes::Array{Node,1})
  planenodearray = deepcopy(nodes)
  equivarray = Array(Equiv,length(nodes))
  for i in eachindex(nodes)
    equivarray[i] = Equiv([nodes[i],planenodearray[i]])
  end
  equivgroup = Group(equivarray)
  return (planenodearray, equivgroup)
end

planeconnect(node::Node) = planeconnect([node])
