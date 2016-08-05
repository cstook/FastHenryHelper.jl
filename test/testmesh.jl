function testmesh()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  meshtest1 = mesh(inductor)
  meshtest2 = mesh(Node(1,1,1))
  (g1,junk) = groupfortests()
  meshtest3 = mesh(g1)
end
testmesh()
