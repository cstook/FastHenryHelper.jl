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

# units all "converted" to meters.  display in km.
function groupfortests2()
  sp = SegmentParameters(h=0.2/2.54e-5)
  pn1 = Node(:planenode1,1/2.54e-5,2/2.54e-5,10/2.54e-5)
  pn2 = Node(:planenode2,4/2.54e-5,5/2.54e-5,10/2.54e-5)
  g1 = Group([
        Title("Test Title"),
        Units("km"),
        Node(0,0,1*1e-3),
        Units("m"),
        Node(0,0,2),
        Units("cm"),
        n1 = Node(:ode1,0,0,3*1e2),
        Units("mm"),
        n2 = Node(:ode2,0,0,4*1e3),
        Units("um"),
        Default(w=0.2*1e6),
        Node(0,0,5*1e6),
        Units("in"),
        Node(0,0,6/2.54e-2),
        Units("mils"),
        Node(0,0,7/2.54e-5),
        UniformPlane(
          x1= 0.0/2.54e-5, y1= 0.0/2.54e-5, z1=10.0/2.54e-5,
          x2=10.0/2.54e-5, y2= 0.0/2.54e-5, z2=10.0/2.54e-5,
          x3=10.0/2.54e-5, y3=10.0/2.54e-5, z3=10.0/2.54e-5,
          thick=1.0/2.54e-5,
          seg1=100, seg2=100,
          sigma=123.0,
          nodes = [pn1;pn2]
        ),
        s1 = Segment(n1,n2,sp)
  ])
end
g = groupfortests2();
