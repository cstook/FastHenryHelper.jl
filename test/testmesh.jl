function testnewmesh()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  meshtest1 = new_mesh(inductor)
  meshtest2 = new_mesh(Node(1,1,1))
end
testnewmesh()
