using FastHenryHelper
using GLVisualize, GeometryTypes, GLAbstraction, Colors

n1 = Node(1,1,1)
n2 = Node(3,2,2)
s = Segment(n1, n2, h=1, w=3)
g = Group([n1,n2,s])


hn = helixnodes(1.0,0.5,6π)
hs = connectnodes(hn,SegmentParameters(w=.3))
hg = Group([hn;hs])
title = Title("helix test")
u = Units("mm")
d = Default(h=.05)
ex = External(hn[1],hn[end],"Port1")
f = Freq(min=1e-1, max=1e9, ndec=0.05)
e = End()
helix = Group([title,u,d,hg,ex,f,e])
helix = Group([title,d,hg,ex,f,e])
m = mesh(helix)


window = glscreen()
view(visualize(mesh(g)), window)
renderloop(window)

m = mesh(g)
window = glscreen()
view(visualize(m), window)
renderloop(window)

vd = testvd(helix)
println(vd.elements[40])


vd.displayunit
vd.state.unit
