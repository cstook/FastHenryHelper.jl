function testmesh()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  meshtest1 = mesh(inductor)
  meshtest2 = mesh(Node(1,1,1))
  meshtest3 = mesh(groupfortests())
end
testmesh()
