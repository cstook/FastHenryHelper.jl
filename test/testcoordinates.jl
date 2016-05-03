
function testconversion(c1::Point)
  # convert to spherical and polar
  s1 = convert(Spherical,c1)
  p1 = convert(Polar,c1)
  # between spherical and polar
  s2 = convert(Spherical,p1)
  p2 = convert(Polar,s1)
  # and back
  c2 = convert(Cartesian,s1)
  c3 = convert(Cartesian,p1)
  c4 = convert(Cartesian,s2)
  c5 = convert(Cartesian,p2)

  function testequal(a::Point, b::Point)
    @test_approx_eq(a.x,b.x)
    @test_approx_eq(a.y,b.y)
    @test_approx_eq(a.z,b.z)
  end

  testequal(c1,c2)
  testequal(c1,c3)
  testequal(c1,c4)
  testequal(c1,c5)
end

for a in [-1,1]
  for b in [-1,1]
    for c in [-1,1]
      testconversion(Cartesian(a,b,c))
    end
  end
end


