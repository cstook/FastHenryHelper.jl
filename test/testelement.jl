using FastHenryHelper
using Base.Test

# compare what an element shows to string
function testelement(e::Element, verified::ASCIIString)
  ebuf = IOBuffer()
  show(ebuf,e)
  @test takebuf_string(ebuf) == verified
end


testend()
function testend()
  testelement(End(),".end\n")
end

testnode()
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

testmatrices()
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

testsigmarho()
function testsigmarho()
  @test_throws(ArgumentError,FastHenryHelper.SigmaRho(sigma=1.0, rho=2.0))
  sr1 = FastHenryHelper.SigmaRho(sigma=1.0)
  @test sr1.sigma == 1.0
  @test isnan(sr1.rho)
  sr2 = FastHenryHelper.SigmaRho(rho=1.0)
  @test sr2.rho == 1.0
  @test isnan(sr2.sigma)
end

testwxwywz()
function testwxwywz()
  w1 = FastHenryHelper.WxWyWz(wx=1.0,wy=2.0,wz=3.0)
  @test w1.xyz == [1.0, 2.0, 3.0]
  @test w1.isdefault == false
  w2 = FastHenryHelper.WxWyWz()
  @test isnan(w2.xyz[1]) && isnan(w2.xyz[2]) && isnan(w2.xyz[3])
  @test w2.isdefault == true
end

testwh()
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

testsegmentparameters()
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

testsegment()
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
  +  wx=4.000000000e+00 wy=5.000000000e+00 wz=6.000000000e+00
  """
  testelement(s1,verified)
end

testcomment()
function testcomment()
  c = Comment("abcd")
  testelement(c,"* abcd\n")
end

testtitle()
function testtitle()
  c = Title("abcd")
  testelement(c,"* abcd\n")
end

testdefault()
function  testdefault()
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
