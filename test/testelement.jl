function testend()
  testelement(End(),".end\n")
end
testend()

function testnode()
  testelement(Node(1,1,1),
  "N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00\n" )
  testelement(Node(:abc,2,2,2),
  "Nabc x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00\n")
  testelement(Node([3.0,3.0,3.0]),
  "N_1 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00\n")
  testelement(Node(x=4, y=4, z=4),
  "N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00\n")
  testelement(Node(name=:abc, x=5, y=5, z=5),
  "Nabc x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00\n")
  coordinate = [1.0,2.0,3.0]
  n1 = Node(coordinate)
  @test xyz(n1) == coordinate
end
testnode()

function testmatrices()
  result = [1.0   0.0       0.0       0.0
         0.0   0.707107  0.707107  0.0
         0.0  -0.707107  0.707107  0.0
         0.0   0.0       0.0       1.0]
  @test_approx_eq_eps(sum(rx(π/4)-result),0.0,1e-5)

  result = [0.707107  0.0  -0.707107  0.0
   0.0       1.0   0.0       0.0
   0.707107  0.0   0.707107  0.0
   0.0       0.0   0.0       1.0]
  @test_approx_eq_eps(sum(ry(π/4)-result),0.0,1e-5)

  result = [0.707107  0.707107  0.0  0.0
   -0.707107  0.707107  0.0  0.0
    0.0       0.0       1.0  0.0
    0.0       0.0       0.0  1.0]
  @test_approx_eq_eps(sum(rz(π/4)-result),0.0,1e-5)

  result = [1.0  0.0  0.0  1.0
   0.0  1.0  0.0  2.0
   0.0  0.0  1.0  3.0
   0.0  0.0  0.0  1.0]
  @test_approx_eq_eps(sum(txyz(1.0,2.0,3.0)-result),0.0,1e-5)

  result = [ 1.0  0.0  0.0  0.0
   0.0  2.0  0.0  0.0
   0.0  0.0  3.0  0.0
   0.0  0.0  0.0  1.0]
  @test_approx_eq_eps(sum(scalexyz(1.0,2.0,3.0)-result),0.0,1e-5)
end
testmatrices()

function testsigmarho()
  @test_throws(ArgumentError,FastHenryHelper.SigmaRho(sigma=1.0, rho=2.0))
  sr1 = FastHenryHelper.SigmaRho(sigma=1.0)
  @test sr1.sigma == 1.0
  @test isnan(sr1.rho)
  sr2 = FastHenryHelper.SigmaRho(rho=1.0)
  @test sr2.rho == 1.0
  @test isnan(sr2.sigma)
end
testsigmarho()

function testwxwywz()
  w1 = FastHenryHelper.WxWyWz(wx=1.0,wy=2.0,wz=3.0)
  @test w1.xyz == [1.0, 2.0, 3.0]
  @test w1.isdefault == false
  w2 = FastHenryHelper.WxWyWz()
  @test isnan(w2.xyz[1]) && isnan(w2.xyz[2]) && isnan(w2.xyz[3])
  @test w2.isdefault == true
end
testwxwywz()

function testwh()
  @test_throws(ArgumentError,FastHenryHelper.WH(nhinc=-1))
  @test_throws(ArgumentError,FastHenryHelper.WH(nwinc=-1))
  @test_throws(ArgumentError,FastHenryHelper.WH(rh=-1))
  @test_throws(ArgumentError,FastHenryHelper.WH(rw=-1))
  wh1 = FastHenryHelper.WH()
  @test isnan(wh1.w)
  @test isnan(wh1.h)
  @test wh1.nhinc == 0
  @test wh1.nwinc == 0
  @test isnan(wh1.rh)
  @test isnan(wh1.rw)
  wh2 = FastHenryHelper.WH(w=1.0,h=2.0,nhinc=3.0,nwinc=4.0,rh=5.0,rw=6.0)
  @test wh2.w == 1.0
  @test wh2.h == 2.0
  @test wh2.nhinc == 3.0
  @test wh2.nwinc == 4.0
  @test wh2.rh == 5.0
  @test wh2.rw == 6.0
end
testwh()

function testsegmentparameters()
  sp1 = SegmentParameters(w=1.0,h=2.0,sigma=3.0,wx=4.0,wy=5.0,wz=6.0,
                          nhinc=7.0,nwinc=8.0,rh=9,rw=10)
  sp2 = SegmentParameters(sp1,)
  sp3 = SegmentParameters(sp1,w=21.0,h=22.0,sigma=23.0,wx=24.0,wy=25.0,wz=26.0,
                          nhinc=27.0,nwinc=28.0,rh=29,rw=210)
  @test FastHenryHelper.w(sp2) == 1.0
  @test FastHenryHelper.h(sp2) == 2.0
  @test FastHenryHelper.sigma(sp2) == 3.0
  @test FastHenryHelper.wx(sp2) == 4.0
  @test FastHenryHelper.wy(sp2) == 5.0
  @test FastHenryHelper.wz(sp2) == 6.0
  @test FastHenryHelper.nhinc(sp2) == 7.0
  @test FastHenryHelper.nwinc(sp2) == 8.0
  @test FastHenryHelper.rh(sp2) == 9
  @test FastHenryHelper.rw(sp2) == 10
  @test isnan(FastHenryHelper.rho(sp2))
  @test FastHenryHelper.w(sp3) == 21.0
  @test FastHenryHelper.h(sp3) == 22.0
  @test FastHenryHelper.sigma(sp3) == 23.0
  @test FastHenryHelper.wx(sp3) == 24.0
  @test FastHenryHelper.wy(sp3) == 25.0
  @test FastHenryHelper.wz(sp3) == 26.0
  @test FastHenryHelper.nhinc(sp3) == 27.0
  @test FastHenryHelper.nwinc(sp3) == 28.0
  @test FastHenryHelper.rh(sp3) == 29
  @test FastHenryHelper.rw(sp3) == 210
  @test isnan(FastHenryHelper.rho(sp3))
end
testsegmentparameters()

function testsegment()
  sp1 = SegmentParameters(w=1.0,h=2.0,sigma=3.0,wx=4.0,wy=5.0,wz=6.0,
                          nhinc=7.0,nwinc=8.0,rh=9,rw=10)
  n1 = Node(1,2,3)
  n2 = Node(4,5,6)
  s1 = Segment(n1,n2,sp1)
  verified =
  """
  E_1 N_2 N_3
  +  w=1.000000000e+00 h=2.000000000e+00 nhinc=7 nwinc=8 rh=9.000000000e+00 rw=1.000000000e+01
  +  sigma=3.000000000e+00
  +  wx=-7.071067812e-01 wy=0.000000000e+00 wz=7.071067812e-01
  """
  testelement(s1,verified)
  n3 = Node(0,0,0)
  n4 = Node(1,0,0)
  s2 = Segment(n3,n4,w=.5,h=.2)
  verified =
  """
  E_1 N_2 N_3
  +  w=5.000000000e-01 h=2.000000000e-01
  """
  testelement(s2,verified)
  s3 = Segment(n3,n4,w=.5,h=.2,wx=0,wy=1,wz=0)
  verified =
  """
  E_1 N_2 N_3
  +  w=5.000000000e-01 h=2.000000000e-01
  +  wx=0.000000000e+00 wy=1.000000000e+00 wz=0.000000000e+00
  """
  testelement(s3,verified)
  s4 = Segment(n3,n4,w=.5,h=.2,wx=1,wy=1,wz=0)
  verified =
  """
  E_1 N_2 N_3
  +  w=5.000000000e-01 h=2.000000000e-01
  +  wx=0.000000000e+00 wy=1.000000000e+00 wz=0.000000000e+00
  """
  testelement(s4,verified)
  s5 = Segment(n3,n4,w=.5,h=.2,wx=0,wy=0,wz=1)
  verified =
  """
  E_1 N_2 N_3
  +  w=5.000000000e-01 h=2.000000000e-01
  +  wx=0.000000000e+00 wy=0.000000000e+00 wz=1.000000000e+00
  """
  testelement(s5,verified)
  s6 = Segment(n3,n4,w=.5,h=.2,wx=1,wy=1,wz=1)
  verified =
  """
  E_1 N_2 N_3
  +  w=5.000000000e-01 h=2.000000000e-01
  +  wx=-0.000000000e+00 wy=7.071067812e-01 wz=7.071067812e-01
  """
  testelement(s6,verified)
  @test_throws(ArgumentError,Segment(n1,n2,w=1,h=2,wx=0,wy=0,wz=0))
end
testsegment()

function testcomment()
  c = Comment("abcd")
  testelement(c,"* abcd\n")
end
testcomment()

function testdefault()
  sp1 = SegmentParameters(w=1.0,h=2.0,sigma=3.0,wx=4.0,wy=5.0,wz=6.0,
                          nhinc=7.0,nwinc=8.0,rh=9,rw=10)
  def1 = Default(sp1)
  verified =
  """
  .default
  +  w=1.000000000e+00 h=2.000000000e+00 nhinc=7 nwinc=8 rh=9.000000000e+00 rw=1.000000000e+01
  +  sigma=3.000000000e+00
  """
  testelement(def1,verified)
  def2 = Default(rho=1.0)
  verified =
  """
  .default
  +  rho=1.000000000e+00
  """
  testelement(def2,verified)
end
testdefault()

function testequiv()
  n3 = Node(:abc,3,3,3)
  n4 = Node(:def,4,4,4)
  eq1 = Equiv([n3,n4])
  testelement(eq1,".equiv Nabc Ndef\n")
  n5 = Node(5,5,5)
  n6 = Node(6,6,6)
  eq2 = Equiv([n5,n6])
  testelement(eq2,".equiv N_1 N_2\n")
end
testequiv()

function testexternal()
  n3 = Node(:abc,3,3,3)
  n4 = Node(:def,4,4,4)
  ex1 = External(n3,n4,"portname")
  testelement(ex1,".external Nabc Ndef portname\n")
  n5 = Node(5,5,5)
  n6 = Node(6,6,6)
  ex2 = External(n5,n6,"portname")
  testelement(ex2,".external N_1 N_2 portname\n")
end
testexternal()

function testfreq()
  @test_throws(ArgumentError,Freq())
  @test_throws(ArgumentError,Freq(min=100,max=10))
  @test_throws(ArgumentError,Freq(max=1000, ndec=-10))
  f1 = Freq(min=1,max=2,ndec=3)
  testelement(f1,".freq fmin=1.000000000e+00 fmax=2.000000000e+00 ndec=3.000000000e+00\n")
end
testfreq()

function testunits()
  @test_throws(ArgumentError,Units("kk"))
  u = Units("in")
  testelement(u,".units in\n")
end
testunits()

function testuniformplane()
  p = Point(x=1,y=2,z=3)
  testelement(p,"+ hole point (1.000000000e+00, 2.000000000e+00, 3.000000000e+00)\n")
  r = Rect(x1=1,y1=2,z1=3,x2=4,y2=5,z2=6)
  testelement(r,"+ hole rect (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00, 5.000000000e+00, 6.000000000e+00)\n")
  c = Circle(x=1,y=2,z=3,r=4)
  testelement(c,"+ hole circle (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00)\n")
  @test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=4,rh=5,sigma=6,rho=7))
  @test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=4,rh=-5,sigma=6))
  @test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=-4,rh=5,rho=7))
  @test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=0, nhinc=4,rh=5,sigma=6))
  @test_throws(ArgumentError,UniformPlane(thick=1, seg1=0, seg2=3, nhinc=4,rh=5,sigma=6))
  @test_throws(ArgumentError,UniformPlane(seg1=2, seg2=3, nhinc=4,rh=5,sigma=6))
  n10 = Node(10,11,12)
  n11 = Node(13,14,15)
  up = UniformPlane(
  x1=1, y1=2, z1=1,
  x2=1, y2=1, z2=1,
  x3=2, y3=1, z3=1,
  thick=10, seg1=11, seg2=12,
  segwid1 = 13, segwid2 = 14,
  sigma = 15,
  nhinc=16, rh=17,
  relx=18, rely=19, relz=20,
  nodes=[n10,n11],
  holes=[p,r,c])
  verified =
  """
  G_1
  + x1=1.000000000e+00 y1=2.000000000e+00 z1=1.000000000e+00
  + x2=1.000000000e+00 y2=1.000000000e+00 z2=1.000000000e+00
  + x3=2.000000000e+00 y3=1.000000000e+00 z3=1.000000000e+00
  + thick=1.000000000e+01 seg1=11 seg2=12
  + segwid1=1.300000000e+01
  + segwid2=1.400000000e+01
  + sigma=1.500000000e+01
  + nhinc=16
  + rh=17
  + relx=1.800000000e+01
  + rely=1.900000000e+01
  + relz=2.000000000e+01
  + N_2 (1.000000000e+01,1.100000000e+01,1.200000000e+01)
  + N_3 (1.300000000e+01,1.400000000e+01,1.500000000e+01)
  + hole point (1.000000000e+00, 2.000000000e+00, 3.000000000e+00)
  + hole rect (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00, 5.000000000e+00, 6.000000000e+00)
  + hole circle (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00)
  """
  testelement(up,verified)
  up2 = deepcopy(up)
  transform!(up2,txyz(1,2,3))
  verified =
  """
  G_1
  + x1=2.000000000e+00 y1=4.000000000e+00 z1=4.000000000e+00
  + x2=2.000000000e+00 y2=3.000000000e+00 z2=4.000000000e+00
  + x3=3.000000000e+00 y3=3.000000000e+00 z3=4.000000000e+00
  + thick=1.000000000e+01 seg1=11 seg2=12
  + segwid1=1.300000000e+01
  + segwid2=1.400000000e+01
  + sigma=1.500000000e+01
  + nhinc=16
  + rh=17
  + relx=1.800000000e+01
  + rely=1.900000000e+01
  + relz=2.000000000e+01
  + N_2 (1.100000000e+01,1.300000000e+01,1.500000000e+01)
  + N_3 (1.400000000e+01,1.600000000e+01,1.800000000e+01)
  + hole point (2.000000000e+00, 4.000000000e+00, 6.000000000e+00)
  + hole rect (2.000000000e+00, 4.000000000e+00, 6.000000000e+00, 5.000000000e+00, 7.000000000e+00, 9.000000000e+00)
  + hole circle (2.000000000e+00, 4.000000000e+00, 6.000000000e+00, 4.000000000e+00)
  """
  testelement(up2,verified)
end
testuniformplane()

function testgroup()
  title = Comment("test title")
  n20 = Node(1,0,0)
  n21 = Node(10,0,0)
  sp20 = SegmentParameters(h=3,w=5,sigma=0.1)
  seg20 = Segment(n20,n21,sp20)
  g1 = Group([title,n20,n21,seg20],Dict(:a=>n20,:b=>n21))
  g2 = transform(g1,rz(π/4))
  g3 = Group([g1,g2],Dict(:c=>g1[:a], :d=>g1[:b], :e=>g2[:a], :f=>g2[:b]))
  testelement(g3[:c],"N_1 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00\n")
  testelement(g3[:d],"N_1 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00\n")
  testelement(g3[:e],"N_1 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00\n")
  testelement(g3[:f],"N_1 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00\n")
  verified =
  """
  * test title
  N_1 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00
  N_2 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00
  E_3 N_1 N_2
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  * test title
  N_4 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00
  N_5 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00
  E_6 N_4 N_5
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  +  wx=-7.071067812e-01 wy=-7.071067812e-01 wz=0.000000000e+00
  """
  testelement(g3,verified)
  u = Units("in")
  def1 = Default(sigma = 1.234)
  n3 = Node(:abc,3,3,3)
  n4 = Node(:def,4,4,4)
  eq1 = Equiv([n3,n4])
  n5 = Node(:abc,3,3,3)
  n6 = Node(:def,4,4,4)
  ex1 = External(n5,n6,"portname")
  f1 = Freq(min=1,max=2,ndec=3)
  p = FastHenryHelper.Point(x=1,y=2,z=3)
  r = FastHenryHelper.Rect(x1=1,y1=2,z1=3,x2=4,y2=5,z2=6)
  c = FastHenryHelper.Circle(x=1,y=2,z=3,r=4)
  n10 = Node(10,11,12)
  n11 = Node(13,14,15)
  up = UniformPlane(
  x1=1, y1=2, z1=1,
  x2=1, y2=1, z2=1,
  x3=2, y3=1, z3=1,
  thick=10, seg1=11, seg2=12,
  segwid1 = 13, segwid2 = 14,
  sigma = 15,
  nhinc=16, rh=17,
  relx=18, rely=19, relz=20,
  nodes=[n10,n11],
  holes=[p,r,c])
  g4 = Group([title,u,n20,n21,n3,n4,n5,n6,seg20,def1,eq1,up,ex1,f1])
  g5 = transform(g4,rx(π/2))
  verified =
  """
  * test title
  .units in
  N_1 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00
  N_2 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00
  N_3 x=3.000000000e+00 y=3.000000000e+00 z=-3.000000000e+00
  N_4 x=4.000000000e+00 y=4.000000000e+00 z=-4.000000000e+00
  N_5 x=3.000000000e+00 y=3.000000000e+00 z=-3.000000000e+00
  N_6 x=4.000000000e+00 y=4.000000000e+00 z=-4.000000000e+00
  E_7 N_1 N_2
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  +  wx=0.000000000e+00 wy=-6.123233996e-17 wz=1.000000000e+00
  .default
  +  sigma=1.234000000e+00
  .equiv Nabc Ndef
  G_8
  + x1=1.000000000e+00 y1=1.000000000e+00 z1=-2.000000000e+00
  + x2=1.000000000e+00 y2=1.000000000e+00 z2=-1.000000000e+00
  + x3=2.000000000e+00 y3=1.000000000e+00 z3=-1.000000000e+00
  + thick=1.000000000e+01 seg1=11 seg2=12
  + segwid1=1.300000000e+01
  + segwid2=1.400000000e+01
  + sigma=1.500000000e+01
  + nhinc=16
  + rh=17
  + relx=1.800000000e+01
  + rely=1.900000000e+01
  + relz=2.000000000e+01
  + N_9 (1.000000000e+01,1.200000000e+01,-1.100000000e+01)
  + N_10 (1.300000000e+01,1.500000000e+01,-1.400000000e+01)
  + hole point (1.000000000e+00, 3.000000000e+00, -2.000000000e+00)
  + hole rect (1.000000000e+00, 3.000000000e+00, -2.000000000e+00, 4.000000000e+00, 6.000000000e+00, -5.000000000e+00)
  + hole circle (1.000000000e+00, 3.000000000e+00, -2.000000000e+00, 4.000000000e+00)
  .external Nabc Ndef portname
  .freq fmin=1.000000000e+00 fmax=2.000000000e+00 ndec=3.000000000e+00
  """
  testelement(g5,verified)
  c1 = Comment("this is a comment")
  # Default and Freq are immutable
  g6 = Group([title,c1,u,n20,n21,n3,n4,n5,n6,seg20,eq1,up,ex1])
  deepcopyg6 = deepcopy(g6)
  for i in eachindex(elements(g6))
    @test ~(elements(deepcopyg6)[i] === elements(g6)[i])
  end

  g7 = Group()
  elements!(g7,[title,n20,n21,seg20])
  terms!(g7,Dict(:a=>n20,:b=>n21))
  g7[:c] = n20
  @test g7[:a] === g7[:c]
  deepcopyg7 = deepcopy(g7)
  @test elements(deepcopyg7)[4].node1 === elements(deepcopyg7)[2]
  @test elements(deepcopyg7)[4].node2 === elements(deepcopyg7)[3]
  push!(g1,n20)
  @test pop!(g1) === n20
  unshift!(g1,n20)
  @test shift!(g1) === n20
  append!(g1,g2)
  prepend!(g1,g2)
  merge!(g1,g2,g3)
  verified =
  """
  * test title
  N_1 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00
  N_2 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00
  E_3 N_1 N_2
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  +  wx=-7.071067812e-01 wy=-7.071067812e-01 wz=0.000000000e+00
  * test title
  N_4 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00
  N_5 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00
  E_6 N_4 N_5
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  * test title
  N_1 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00
  N_2 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00
  E_3 N_1 N_2
  +  w=5.000000000e+00 h=3.000000000e+00
  +  sigma=1.000000000e-01
  +  wx=-7.071067812e-01 wy=-7.071067812e-01 wz=0.000000000e+00
  """
  testelement(g1,verified)
  g7 = Group([Node(1,2,3)])
  g8 = Group([g7])
  g9 = Group([g8])
  g10 = Group([g9])
  g11 = Group([g10])
  g12 = Group([g11])
  testelement(g12,"N_1 x=1.000000000e+00 y=2.000000000e+00 z=3.000000000e+00\n")
  for element in g12
    @test typeof(element) != Group
  end
end
testgroup()
