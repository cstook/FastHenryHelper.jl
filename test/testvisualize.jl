function testvisualizedata()
  vd = FastHenryHelper.VisualizeData(groupfortests())
  verified = [1000.0, 1.0, 0.01, 0.001, 1.0e-6, 0.0254, 2.54e-5]
  for i in eachindex(vd.nodedataarray)
    @test vd.nodedataarray[i].xyz[3] == verified[i]
  end
  @test vd.segmentdataarray[1].n1xyz[3] == verified[3]
  @test vd.segmentdataarray[1].n2xyz[3] == verified[4]
  @test vd.planedataarray[1].c1 ≈ [0.0,0.0,0.0]
  @test vd.planedataarray[1].c2 ≈ [0.000254,0.0,0.0]
  @test vd.planedataarray[1].c3 ≈ [0.000254,0.000254,0.0]
  @test vd.planedataarray[1].node_xyz ≈
    [2.54e-5 0.0001016;5.08e-5 0.000127;7.62e-5 0.0001524]
  FastHenryHelper.todisplayunit!(vd)
  for i in eachindex(vd.nodedataarray)
    @test vd.nodedataarray[i].xyz[3] == 1e-3*verified[i]
  end
  @test vd.segmentdataarray[1].n1xyz[3] == 1e-3*verified[3]
  @test vd.segmentdataarray[1].n2xyz[3] == 1e-3*verified[4]
  @test vd.planedataarray[1].c1 ≈ 1e-3 * [0.0,0.0,0.0]
  @test vd.planedataarray[1].c2 ≈ 1e-3 * [0.000254,0.0,0.0]
  @test vd.planedataarray[1].c3 ≈ 1e-3 * [0.000254,0.000254,0.0]
  @test vd.planedataarray[1].node_xyz ≈
    1e-3 * [2.54e-5 0.0001016;5.08e-5 0.000127;7.62e-5 0.0001524]
end
testvisualizedata()

function testmesh()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  vd = FastHenryHelper.VisualizeData(inductor)
  meshtest1 = mesh(inductor)
  meshtest2 = mesh(Node(1,1,1))
end
testmesh()
