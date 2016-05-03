
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

cartesian_array = Array(Cartesian,8)
i = 0
for a in [-1,1]
  for b in [-1,1]
    for c in [-1,1]
      i += 1
      cartesian_array[i] = Cartesian(a,b,c)
      testconversion(cartesian_array[i])
    end
  end
end

# test converting an array
spherical_array = convert(Spherical, cartesian_array)

# test translate
translate!(spherical_array,Polar(1,1,1))

# test rotate
rotate!(spherical_array,Polar(1,1,1))

