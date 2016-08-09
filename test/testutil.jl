function testplaneconnect()
  sp = SegmentParameters(w=0.5,h=0.2,sigma=62.1e6*1e-3)
  n1 = Node(1,0,0)
  n2 = Node(2,0,0)
  n3 = Node(3,0,0)
  n11 = Node(1,0,-1)
  n12 = Node(2,0,-1)
  n13 = Node(3,0,-1)
  n4 = Node(10,0,0)
  hsegs = connectnodes([n1,n2,n3,n4],sp)
  vsegs = [Segment(n1,n11,sp), Segment(n2,n12,sp), Segment(n3,n13,sp)]
  g1 = Group([n1;n2;n3;n4;n11;n12;n13;hsegs;vsegs], Dict(:a=>n4,:b=>[n11,n12,n13]))
  n5 = Node(20,20,-1)
  (planenodes,equivgroup) = planeconnect([n5,n11,n12,n13])
  u1 = UniformPlane(
  x1=0,  y1=0,  z1=-1,
  x2=0,  y2=20, z2=-1,
  x3=20, y3=20, z3=-1,
  thick = .5,
  seg1=100, seg2=100,
  nodes = planenodes)
  g2 = Group([n5,u1,equivgroup])
  title = Comment("term with node array")
  u = Units("mm")
  pre = Group([title,u])
  ex = External(n1,n5)
  f = Freq(min=1e-1, max=1e9, ndec=0.05)
  e = End()
  post = Group([ex,f,e])
  Group([pre;g1;g2;post])
end
testplaneconnect()

# test transform with rectangulararray
function test_rectangulararray_transform()
  g1 = transform(Node(1,1,1), rectangulararray(0,0,[1,2,3]))
  via = viagroup(radius=5, height=3, h=1, n=8)
  g2 = transform(via,  rectangulararray([20,40,60],[40,80],[100,200]))
end
test_rectangulararray_transform()

function testparsefasthenrymat()
  pfhmr_example3 = parsefasthenrymat("example3_Zc.mat")
  pfhmr_eightloops = parsefasthenrymat("eightloopsZc.mat")
end
testparsefasthenrymat()
