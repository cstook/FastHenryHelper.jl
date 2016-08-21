using FastHenryHelper
using GLVisualize
using Plots;plotly()

n1 = Node(1,1,1)
n2 = Node(3,2,2)
s = Segment(n1, n2, h=1, w=3)
g = Group([n1,n2,s])


hn = helixnodes(1.0,0.5,6π)
hs = connectnodes(hn,SegmentParameters(w=.3))
hs2 = connectnodes(hn,SegmentParameters(w=.3,h=.2))
hg = Group([hn;hs])
title = Comment("helix test")
u = Units("mm")
d = Default(h=.2)
ex = External(hn[1],hn[end],"Port1")
f = Freq(min=1e-1, max=1e9, ndec=0.05)
e = End()
helix = Group([title,u,d,hg,ex,f,e])
helix = Group([title,d,hg,ex,f,e])
helix = Group([d,hg])
helix = Group([hn;hs2])
onesegment = Group([hn[1],hn[2],Segment(hn[1],hn[2],w=.3,h=.2)])
m = mesh(helix)


plot(helix);gui()
plot(onesegment);gui()

onesegment2 = Group([n1=Node(1,0,0),
                    n2=Node(.707,.707,.0625),
                    Segment(n1,n2,w=.3,h=.2)])
plot(onesegment2);gui()

onesegment3 = Group([n1=Node(0,1,1),  # plot fail if x=0 or y=0
                    n2=Node(2,2,2),
                    Segment(n1,n2,w=.3,h=.2)])
plot(onesegment3);gui()

window = glscreen()
_view(visualize(mesh(onesegment3)), window)
renderloop(window)

window = glscreen()
_view(visualize(m), window)
renderloop(window)

vd = testvd(helix)
println(vd.elements[40])

up = UniformPlane(x1=0,   y1=0,   z1=0,
                  x2=100,   y2=0,   z2=0,
                  x3=100, y3=100, z3=0,
    thick= 50, seg1=20, seg2=20)
m = mesh(up)

g1 = Group([n1 = Node(1,1,1),
            n2 = Node(2,2,2),
            Default(w=.4),
            Units("cm"),
            Segment(n1,n2,h=20)])
plot(g1);gui()

g2 = Group([n1 = Node(1,1,1),
            n2 = Node(2,2,2),
            connectnodes([n1,n2],SegmentParameters(w=.3,h=.2))...
            ])
plot(g2);gui()

g2 = Group([n1 = Node(1,1,1),
            n2 = Node(2,2,2),
            Default(w=.4),
            connectnodes([n1,n2],SegmentParameters(h=.05))...
            ])
plot(g2);gui()

hn2 = helixnodes(1.0,0.5,6π)
hs2 = connectnodes(hn2,SegmentParameters(w=.3,h=.2))
helix2 = Group([hn2;hs2])
plot(helix2);gui()




cross([1.0,0.9,0.0],[0.9,1.0,0.0])



cross([0.382683,-0.92388,0.0],[-0.292893,0.707107,0.0625])



cross([0.382683,-0.92388,0.0],[-0.292893,0.707107,0.0])



dot([0.382683,-0.92388,0.0],[-0.292893,0.707107,0.0625])
