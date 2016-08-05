
function contexttest1()
  (g1,(t,sp,pn1,pn2,u1,u2,u3,u4,u5,u6,u7,n1,n2,n3,n4,n5,n6,n7,d1,p1,s1)) =
    groupfortests()

  context = Context(g1)

  @test context.dict[t].default == Default()
  @test context.dict[t].units == Units()
  @test context.dict[t].autoname == 0
  @test context.firstunits == Units("km")
  @test context.title == "Test Title"

  @test context.dict[n1].default == Default()
  @test context.dict[n1].units == Units("km")
  @test context.dict[n1].autoname == 1

  @test context.dict[n2].default == Default()
  @test context.dict[n2].units == Units("m")
  @test context.dict[n2].autoname == 2

  @test context.dict[n3].default == Default()
  @test context.dict[n3].units == Units("cm")
  @test context.dict[n3].autoname == 2

  @test context.dict[n4].default == Default()
  @test context.dict[n4].units == Units("mm")
  @test context.dict[n4].autoname == 2

  @test context.dict[n5].default == Default(w=3)
  @test context.dict[n5].units == Units("um")
  @test context.dict[n5].autoname == 3

  @test context.dict[n6].default == Default(w=3)
  @test context.dict[n6].units == Units("in")
  @test context.dict[n6].autoname == 4

  @test context.dict[n7].default == Default(w=3)
  @test context.dict[n7].units == Units("mils")
  @test context.dict[n7].autoname == 5

  @test context.dict[p1].default == Default(w=3)
  @test context.dict[p1].units == Units("mils")
  @test context.dict[p1].autoname == 6

  @test context.dict[s1].default == Default(w=3)
  @test context.dict[s1].units == Units("mils")
  @test context.dict[s1].autoname == 7

  @test_approx_eq xyz1(n1,context) [0.0,0.0, 1.0    ,1.0]
  @test_approx_eq xyz1(n2,context) [0.0,0.0, 0.001  ,1.0]
  @test_approx_eq xyz1(n3,context) [0.0,0.0, 1.0e-5 ,1.0]
  @test_approx_eq xyz1(n4,context) [0.0,0.0, 1.0e-6 ,1.0]
  @test_approx_eq xyz1(n5,context) [0.0,0.0, 1.0e-9,1.0]
  @test_approx_eq xyz1(n6,context) [0.0,0.0, 2.54e-5,1.0]
  @test_approx_eq xyz1(n7,context) [0.0,0.0, 2.54e-8,1.0]

  (n1xyz1,n2xyz1) = nodes_xyz1(s1,context)
  @test_approx_eq n1xyz1 [0.0,0.0,1.0e-5,1.0]
  @test_approx_eq n2xyz1 [0.0,0.0,1.0e-6,1.0]

  @test_approx_eq [width_height(s1,context)...] [3.0e-9,5.08e-8]

  @test_approx_eq wxyz(s1,context) [-1.0,0.0,0.0]

  (c1,c2,c3,thick) = corners_xyz1_thick(p1,context)
  @test_approx_eq c1 [0.0,0.0,0.0,0.0]
  @test_approx_eq c2 [2.54e-7,0.0,0.0,0.0]
  @test_approx_eq c3 [2.54e-7,2.54e-7,0.0,0.0]
  @test_approx_eq thick 2.54e-8

  (pn1xyz1,pn2xyz1)=nodes_xyz1(p1,context)
  @test_approx_eq pn1xyz1 [2.54e-8,5.08e-8,7.62e-8,1.0]
  @test_approx_eq pn2xyz1 [1.016e-7,1.27e-7,1.524e-7,1.0]
end
contexttest1()
