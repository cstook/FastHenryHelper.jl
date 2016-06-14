using FastHenryHelper
using Base.Test

open("testend.inp","w") do io
    e = End()
    show(io,e)
end
io = open("testend.inp","r")
all_lines = readall(io)
@test all_lines == ".end\n"
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