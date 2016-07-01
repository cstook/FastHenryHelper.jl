using FastHenryHelper
using GLVisualize, GeometryTypes, GLAbstraction, Colors

n1 = Node(1,1,1)
n2 = Node(3,3,3)
s = Segment(n1, n2, h=1, w=3)
g = Group([n1,n2,s])

window = glscreen()
view(visualize(mesh(g)), window)
renderloop(window)
