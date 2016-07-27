function testvisualizedata()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  vd = FastHenryHelper.VisualizeData(inductor)
  meshtest1 = mesh(inductor)
  meshtest2 = mesh(Node(1,1,1))
end
testvisualizedata()
