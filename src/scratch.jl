using FastHenryHelper
using GLVisualize

n1 = Node(1,1,1)
n2 = Node(3,2,2)
s = Segment(n1, n2, h=1, w=3)
g = Group([n1,n2,s])

window = glscreen()
view(visualize(mesh(g)), window)
renderloop(window)

m = mesh(g)
m2 = merge(m)
window = glscreen()
view(visualize(m2, window)
renderloop(window)


s.node1 === n1
nodedict =  Dict{Node,Array{Float64,1}}()
nodedict[n1] = n1.xyz[1:3]
nodedict[n2] = n2.xyz[1:3]
nodedict[s.node1]
pointer_from_objref(g.elements[1])
pointer_from_objref(n1)
pointer_from_objref(s.node1)
pointer_from_objref(n2)
pointer_from_objref(s.node2)

pointer_from_objref(collect(keys(nodedict))[1])

vs = FastHenryHelper.VisualizeState()
FastHenryHelper.NodeData!(vs, n1)
FastHenryHelper.NodeData!(vs, n2)
FastHenryHelper.SegmentData(vs, s)

vd = FastHenryHelper.VisualizeData()
FastHenryHelper.visualizedata!(vd, n1)
FastHenryHelper.visualizedata!(vd, n2)
FastHenryHelper.visualizedata!(vd, s)
vd.state.nodedict[n1]


a = ["a","b","c"]
pointer_from_objref(a)
pointer_from_objref(a[1])

b = copy(a)
pointer_from_objref(b)
pointer_from_objref(b[1])

c = copy(a)
pointer_from_objref(c)
pointer_from_objref(c[1])
