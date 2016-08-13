function testemptygroup()
  Group([])
end
testemptygroup()


function testgroupnesting1()
  g1 = Group([Node(1,1,1),
      Node(2,2,2),
      Node(3,3,3)])
  verified =
  """
  N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  N_2 x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00
  N_3 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  """
  testelement(g1,verified)
  g2 = Group([Node(4,4,4),
      g1,
      Node(:a,5,5,5)])
  verified =
  """
  N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  N_2 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  N_3 x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00
  N_4 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  Na x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  """
  testelement(g2,verified)
  g3 = Group([g2,Node(6,6,6)])
  verified =
  """
  N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  N_2 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  N_3 x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00
  N_4 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  Na x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  N_5 x=6.000000000e+00 y=6.000000000e+00 z=6.000000000e+00
  """
  testelement(g3,verified)
  g4 = Group([Node(7,7,7),g3])
  verified =
  """
  N_1 x=7.000000000e+00 y=7.000000000e+00 z=7.000000000e+00
  N_2 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  N_3 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  N_4 x=2.000000000e+00 y=2.000000000e+00 z=2.000000000e+00
  N_5 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  Na x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  N_6 x=6.000000000e+00 y=6.000000000e+00 z=6.000000000e+00
  """
  testelement(g4,verified)
end
testgroupnesting1()

function testgroupunits1()
  g1 = Group([Node(1,1,1),
              Units("in"),
              Node(3,3,3)],
              Dict(),
              Units("mm"))
  g2 = Group([Node(4,4,4)], Dict(), Units("cm"))
  g3 =  Group([Node(5,5,5)])
  g4 = Group([Node(6,6,6),
              Units("um"),
              Node(7,7,7)])
  g5 = Group([g4,g2])
  verified =
  """
  N_1 x=6.000000000e+00 y=6.000000000e+00 z=6.000000000e+00
  .units um
  N_2 x=7.000000000e+00 y=7.000000000e+00 z=7.000000000e+00
  .units cm
  N_3 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units um
  """
  testelement(g5, verified)
  g6 = Group([g2,g4])
  verified =
  """
  .units cm
  N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units m
  N_2 x=6.000000000e+00 y=6.000000000e+00 z=6.000000000e+00
  .units um
  N_3 x=7.000000000e+00 y=7.000000000e+00 z=7.000000000e+00
  """
  testelement(g6, verified)
  g7 = Group([g3,g2])
  verified =
  """
  N_1 x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  .units cm
  N_2 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units m
  """
  testelement(g7, verified)
  g8 = Group([g2,g3])
  verified =
  """
  .units cm
  N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units m
  N_2 x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  """
  testelement(g8, verified)
  g9 = Group([Units("um"),g1,g2,g1,g2])
  verified =
  """
  .units um
  .units mm
  N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  .units in
  N_2 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  .units um
  .units cm
  N_3 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units um
  .units mm
  N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  .units in
  N_2 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  .units um
  .units cm
  N_3 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units um
  """
  testelement(g9, verified)
  g10 = Group([Group([g1,g3]),Group([g4,g2])])
  verified =
  """
  .units mm
  N_1 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  .units in
  N_2 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  .units m
  N_3 x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  N_4 x=6.000000000e+00 y=6.000000000e+00 z=6.000000000e+00
  .units um
  N_5 x=7.000000000e+00 y=7.000000000e+00 z=7.000000000e+00
  .units cm
  N_6 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units um
  """
  testelement(g10, verified)
  g11 = Group([Node(4,4,4), g1, Node(:a,5,5,5)])
  verified =
  """
  N_1 x=4.000000000e+00 y=4.000000000e+00 z=4.000000000e+00
  .units mm
  N_2 x=1.000000000e+00 y=1.000000000e+00 z=1.000000000e+00
  .units in
  N_3 x=3.000000000e+00 y=3.000000000e+00 z=3.000000000e+00
  .units m
  Na x=5.000000000e+00 y=5.000000000e+00 z=5.000000000e+00
  """
  testelement(g11, verified)
end
testgroupunits1()
