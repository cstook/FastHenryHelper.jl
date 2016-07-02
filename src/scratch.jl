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

vs = FastHenryHelper.VisualizeState()
FastHenryHelper.NodeData!(vs, n1)
FastHenryHelper.NodeData!(vs, n2)
FastHenryHelper.SegmentData(vs, s)
