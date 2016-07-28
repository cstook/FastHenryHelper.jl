using FastHenryHelper
using Base.Test

# compare what an element shows to string
function testelement(e::Element, verified::ASCIIString)
  ebuf = IOBuffer()
  show(ebuf,e)
  @test takebuf_string(ebuf) == verified
end

function testelementdebug(e::Element, verified::ASCIIString)
  ebuf = IOBuffer()
  show(ebuf,e)
  debug = open("debug.txt","w")
  println(debug,"element  =")
  println(debug, takebuf_string(ebuf))
  println(debug,"verified =")
  println(debug, verified)
  close(debug)
  warn("testelementdebug called")
end

include("testelement.jl")

function groupfortests()
  sp = SegmentParameters(h=2)
  pn1 = Node(:planenode1,1,2,3)
  pn2 = Node(:planenode2,4,5,6)
  g1 = Group([
    Title("Test Title"),
    Units("km"),
    Node(0,0,1),
    Units("m"),
    Node(0,0,1),
    Units("cm"),
    n1 = Node(:ode1,0,0,1),
    Units("mm"),
    n2 = Node(:ode2,0,0,1),
    Units("um"),
    Default(w=3),
    Node(0,0,1),
    Units("in"),
    Node(0,0,1),
    Units("mils"),
    Node(0,0,1),
    UniformPlane(
      x1= 0.0, y1= 0.0, z1=0.0,
      x2=10.0, y2= 0.0, z2=0.0,
      x3=10.0, y3=10.0, z3=0.0,
      thick=1.0,
      seg1=100, seg2=100,
      sigma=123.0,
      nodes = [pn1;pn2]
    ),
    s1 = Segment(n1,n2,sp)
  ])
end

include("testvisualize.jl")
include("testplot.jl")
include("testgroups.jl")
include("testutil.jl")
