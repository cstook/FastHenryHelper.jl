using FastHenryHelper
using Base.Test

io = IOBuffer()
e = End()
show(io,e)
@test takebuf_string(io) == ".end\n"
close(io)

open("testnode.inp","w") do io
    n1 = Node(1,1,1)
    n2 = Node(:abc,2,2,2)
    n3 = Node([3.0,3.0,3.0])
    n4 = Node(x=4, y=4, z=4)
    n5 = Node(name=:abc, x=5, y=5, z=5)
    show(io,n1)
    show(io,n2)
    show(io,n3)
    show(io,n4)
    show(io,n5) 
end
io = open("testnode.inp","r")
@test readline(io) == "N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00\n"
@test readline(io) == "Nabc x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00\n"
@test readline(io) == "N_1 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00\n"
@test readline(io) == "N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00\n"
@test readline(io) == "Nabc x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00\n"
close(io)

coordinate = [1.0,2.0,3.0]
n1 = Node(coordinate)
@test xyz(n1) == coordinate

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

@test_throws(ArgumentError,FastHenryHelper.SigmaRho(sigma=1.0, rho=2.0))
sr1 = FastHenryHelper.SigmaRho(sigma=1.0)
@test sr1.sigma == 1.0
@test isnan(sr1.rho)
sr2 = FastHenryHelper.SigmaRho(rho=1.0)
@test sr2.rho == 1.0
@test isnan(sr2.sigma)

w1 = FastHenryHelper.WxWyWz(wx=1.0,wy=2.0,wz=3.0)
@test w1.xyz == [1.0, 2.0, 3.0]
@test w1.isdefault == false
w2 = FastHenryHelper.WxWyWz()
@test isnan(w2.xyz[1]) && isnan(w2.xyz[2]) && isnan(w2.xyz[3])
@test w2.isdefault == true

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

n1 = Node(1,2,3)
n2 = Node(4,5,6)
s1 = Segment(n1,n2,sp1)
io = IOBuffer()
print(io,s1)
@test takebuf_string(io) == "E_1 N_2 N_3 \n+  w=1.000000000e+00 h=2.000000000e+00 nhinc=7 nwinc=8 rh=9.000000000e+00 rw=1.000000000e+01\n+  sigma=3.000000000e+00\n+  wx=4.000000000e+00 wy=5.000000000e+00 wz=6.000000000e+00\n"
close(io)

c = Comment("adcd")
io = IOBuffer()
print(io,c)
@test takebuf_string(io) == "* adcd\n"

t = Title("adcd")
io = IOBuffer()
print(io,t)
@test takebuf_string(io) == "* adcd\n"

def1 = Default(sp1)
io = IOBuffer()
print(io,def1)
@test takebuf_string(io) == ".default \n+  w=1.000000000e+00 h=2.000000000e+00 nhinc=7 nwinc=8 rh=9.000000000e+00 rw=1.000000000e+01\n+  sigma=3.000000000e+00\n"
close(io)
def2 = Default(rho=1.0)
io = IOBuffer()
print(io,def2)
@test takebuf_string(io) == ".default \n+  rho=1.000000000e+00\n"
close(io)

n3 = Node(:abc,3,3,3)
n4 = Node(:def,4,4,4)
eq1 = Equiv([n3,n4])
io = IOBuffer()
print(io,eq1)
@test takebuf_string(io) == ".equiv Nabc Ndef\n"
close(io)

ex1 = External(n3,n4,"portname")
io = IOBuffer()
print(io,ex1)
@test takebuf_string(io) == ".external Nabc Ndef portname\n"
close(io)

@test_throws(ArgumentError,Freq())
@test_throws(ArgumentError,Freq(min=100,max=10))
@test_throws(ArgumentError,Freq(max=1000, ndec=-10))
f1 = Freq(min=1,max=2,ndec=3)
io = IOBuffer()
print(io,f1)
@test takebuf_string(io) == ".freq fmin=1.000000000e+00 fmax=2.000000000e+00 ndec=3.000000000e+00\n"
close(io)

@test_throws(ArgumentError,Units("kk"))
u = Units("in")
io = IOBuffer()
print(io,u)
@test takebuf_string(io) == ".units in\n"
close(io)

p = FastHenryHelper.Point(x=1,y=2,z=3)
io = IOBuffer()
print(io,p)
@test takebuf_string(io) == "+ hole point (1.000000000e+00, 2.000000000e+00, 3.000000000e+00)\n"
close(io)

r = FastHenryHelper.Rect(x1=1,y1=2,z1=3,x2=4,y2=5,z2=6)
io = IOBuffer()
print(io,r)
@test takebuf_string(io) == "+ hole rect (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00, 5.000000000e+00, 6.000000000e+00)\n"
close(io)

c = FastHenryHelper.Circle(x=1,y=2,z=3,r=4)
io = IOBuffer()
print(io,c)
@test takebuf_string(io) == "+ hole circle (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00)\n"
close(io)

@test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=4,rh=5,sigma=6,rho=7))
@test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=4,rh=-5,sigma=6))
@test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=3, nhinc=-4,rh=5,rho=7))
@test_throws(ArgumentError,UniformPlane(thick=1, seg1=2, seg2=0, nhinc=4,rh=5,sigma=6))
@test_throws(ArgumentError,UniformPlane(thick=1, seg1=0, seg2=3, nhinc=4,rh=5,sigma=6))
@test_throws(ArgumentError,UniformPlane(seg1=2, seg2=3, nhinc=4,rh=5,sigma=6))

n10 = Node(10,11,12)
n11 = Node(13,14,15)
up = UniformPlane(
x1=1, y1=2, z1=3,
x2=4, y2=5, z2=6,
x3=7, y3=8, z3=9,
thick=10, seg1=11, seg2=12,
segwid1 = 13, segwid2 = 14,
sigma = 15,
nhinc=16, rh=17,
relx=18, rely=19, relz=20,
nodes=[n10,n11],
holes=[p,r,c])
up2 = deepcopy(up)
transform!(up2,txyz(1,2,3))
open("testuniformplane.inp","w") do io
    print(io,up)
end
io = open("testuniformplane.inp","r")
@test readline(io) == "G_1\n"
@test readline(io) == "+ x1=1.000000000e+00 y1=2.000000000e+00 z1=3.000000000e+00\n"
@test readline(io) == "+ x2=4.000000000e+00 y2=5.000000000e+00 z2=6.000000000e+00\n"
@test readline(io) == "+ x3=7.000000000e+00 y3=8.000000000e+00 z3=9.000000000e+00\n"
@test readline(io) == "+ thick=1.000000000e+01 seg1=11 seg2=12\n"
@test readline(io) == "+ segwid1=1.300000000e+01\n"
@test readline(io) == "+ segwid2=1.400000000e+01\n"
@test readline(io) == "+ sigma=1.500000000e+01\n"
@test readline(io) == "+ nhinc=16\n"
@test readline(io) == "+ rh=17\n"
@test readline(io) == "+ relx=1.800000000e+01\n"
@test readline(io) == "+ rely=1.900000000e+01\n"
@test readline(io) == "+ relz=2.000000000e+01\n"
@test readline(io) == "+ N_2 (1.000000000e+01,1.100000000e+01,1.200000000e+01)\n"
@test readline(io) == "+ N_3 (1.300000000e+01,1.400000000e+01,1.500000000e+01)\n"
@test readline(io) == "+ hole point (1.000000000e+00, 2.000000000e+00, 3.000000000e+00)\n"
@test readline(io) == "+ hole rect (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00, 5.000000000e+00, 6.000000000e+00)\n"
@test readline(io) == "+ hole circle (1.000000000e+00, 2.000000000e+00, 3.000000000e+00, 4.000000000e+00)\n"
close(io)

title = Title("test title")
n20 = Node(1,0,0)
n21 = Node(10,0,0)
sp20 = SegmentParameters(h=3,w=5,sigma=0.1)
seg20 = Segment(n20,n21,sp20)
g1 = Group([title,n20,n21,seg20],Dict(:a=>n20,:b=>n21))
g2 = transform(g1,rz(π/4))
g3 = Group([g1,g2],Dict(:c=>g1[:a], :d=>g1[:b], :e=>g2[:a], :f=>g2[:b]))
io = IOBuffer()
print(io,g3[:c])
@test takebuf_string(io) == "N_1 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00\n"
print(io,g3[:d])
@test takebuf_string(io) == "N_1 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00\n"
print(io,g3[:e])
@test takebuf_string(io) == "N_1 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00\n"
print(io,g3[:f])
@test takebuf_string(io) == "N_1 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00\n"
close(io)
open("testgroup.inp","w") do io
    print(io,g3)
end
io = open("testgroup.inp","r")
@test readline(io) == "* test title\n"
@test readline(io) == "N_1 x=1.000000000e+00 y=0.000000000e+00 z=0.000000000e+00\n"
@test readline(io) == "N_2 x=1.000000000e+01 y=0.000000000e+00 z=0.000000000e+00\n"
@test readline(io) == "E_3 N_1 N_2 \n"
@test readline(io) == "+  w=5.000000000e+00 h=3.000000000e+00\n"
@test readline(io) == "+  sigma=1.000000000e-01\n"
@test readline(io) == "* test title\n"
@test readline(io) == "N_4 x=7.071067812e-01 y=-7.071067812e-01 z=0.000000000e+00\n"
@test readline(io) == "N_5 x=7.071067812e+00 y=-7.071067812e+00 z=0.000000000e+00\n"
@test readline(io) == "E_6 N_4 N_5 \n"
@test readline(io) == "+  w=5.000000000e+00 h=3.000000000e+00\n"
@test readline(io) == "+  sigma=1.000000000e-01\n"
@test readline(io) == "+  wx=-7.071067812e-01 wy=-7.071067812e-01 wz=0.000000000e+00\n"
close(io)
g4 = Group([title,u,n20,n21,seg20,c,def1,eq1,up,ex1,f1,])
deepcopyg4 = deepcopy(g4)
g5 = transform(g1,rx(π/2))
pd = FastHenryHelper.plotdata(g4)
FastHenryHelper.pointsatlimits!(pd)
nullgroup = Group()
elements!(nullgroup,[title,n20,n21,seg20])
terms!(nullgroup,Dict(:a=>n20,:b=>n21))
nullgroup[:c] = n20
@test nullgroup[:a] === nullgroup[:a]
push!(g1,n20)
@test pop!(g1) === n20
unshift!(g1,n20)
@test shift!(g1) === n20
append!(g1,g2)
prepend!(g1,g2)
merge!(g1,g2,g3)

n1 = Node(1,2,3)
n2 = Node(4,5,6)
n3 = Node(7,8,9)
sp = SegmentParameters(w=10,h=2,sigma=3)
segmentarray = connectnodes([n1,n2,n3],sp)
@test length(segmentarray) == 2
g6 = Group([n1,n2,n3,segmentarray...])

@test_throws(ArgumentError,viagroup(height=20, h=3))
@test_throws(ArgumentError,viagroup(radius=10, h=3))
@test_throws(ArgumentError,viagroup(radius=10, height=20))
@test_throws(ArgumentError,viagroup(radius=10, height=20, h=3,n=1))
via = viagroup(radius=10, height=20, h=3)

inductor = coilcraft1010vsgroup("1010VS-111ME")
@test length(elements(inductor)) == 85
@test length(keys(terms(inductor))) == 2

pfhmr = parsefasthenrymat("example3_Zc.mat")

nothing