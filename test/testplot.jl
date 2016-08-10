function testplotdata()
  (g1,junk) = groupfortests()
  pd = FastHenryHelper.plotdata(g1)
  @test pd.title == "Test Title"
  @test_approx_eq pd.x [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,2.54e-7,2.54e-7,0.0,
    0.0,0.0,2.54e-7,2.54e-7,0.0,0.0,2.54e-7,2.54e-7,2.54e-7,2.54e-7,0.0,0.0,
    2.54e-8,1.016e-7,-1.5e-9,-1.5e-9,1.5e-9,1.5e-9,-1.5e-9,-1.5e-9,-1.5e-9,
    1.5e-9,1.5e-9,-1.5e-9,-1.5e-9,-1.5e-9,1.5e-9,1.5e-9,1.5e-9,1.5e-9]
  @test_approx_eq pd.y [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,2.54e-7,2.54e-7,
    0.0,0.0,0.0,2.54e-7,2.54e-7,0.0,0.0,0.0,2.54e-7,2.54e-7,2.54e-7,2.54e-7,
    5.08e-8,1.27e-7,-2.54e-8,2.54e-8,2.54e-8,-2.54e-8,-2.54e-8,-2.54e-8,
    2.54e-8,2.54e-8,-2.54e-8,-2.54e-8,2.54e-8,2.54e-8,2.54e-8,2.54e-8,
    -2.54e-8,-2.54e-8]
  @test_approx_eq pd.z [1.0,0.001,1.0e-5,1.0e-6,1.0e-9,2.54e-5,2.54e-8,
    -1.27e-8,-1.27e-8,-1.27e-8,-1.27e-8,-1.27e-8,1.27e-8,1.27e-8,1.27e-8,
    1.27e-8,1.27e-8,-1.27e-8,1.27e-8,-1.27e-8,1.27e-8,-1.27e-8,1.27e-8,0.0,
    0.0,1.0e-5,1.0e-5,1.0e-5,1.0e-5,1.0e-5,1.0e-6,1.0e-6,1.0e-6,1.0e-6,
    1.0e-6,1.0e-5,1.0e-6,1.0e-5,1.0e-6,1.0e-5,1.0e-6]
  @test pd.group == [1,2,3,4,5,6,7,8,8,8,8,8,8,8,8,8,8,9,9,10,10,11,11,12,13,
    14,14,14,14,14,14,14,14,14,14,15,15,16,16,17,17]
  @test pd.marker == [:circle,:circle,:circle,:circle,:circle,:circle,:circle,
    :none,:none,:none,:none,:circle,:circle,:none,:none,:none,:none]
  @test pd.markercolor == [:red,:red,:red,:red,:red,:red,:red,:red,:red,:red,
    :red,:green,:green,:red,:red,:red,:red]
  @test pd.markeralpha == [0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,
    0.3,0.3,0.3,0.3]
  @test pd.markersize == [3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,3.0,
    3.0,3.0,3.0,3.0]
  @test pd.markerstrokewidth == [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,
    0.1,0.1,0.1,0.1,0.1,0.1]
  @test pd.linecolor == [:blue,:blue,:blue,:blue,:blue,:blue,:blue,:green,
    :green,:green,:green,:green,:green,:blue,:blue,:blue,:blue]

  FastHenryHelper.pointsatlimits!(pd)
  @test_approx_eq pd.x[end-1:end] [0.5000001326,-0.49999988009999996]
  @test_approx_eq pd.y[end-1:end] [0.50000012065,-0.49999989204999995]
  @test_approx_eq pd.z[end-1:end] [1.0,-1.2699999996090838e-8]
  @test pd.group[end-1:end] == [18,19]
  @test pd.markeralpha[end-1:end] == [0.0,0.0]
  @test pd.markersize[end-1:end] == [0.0,0.0]
  @test pd.markerstrokewidth[end-1:end] == [0.0,0.0]
end
testplotdata()

function testplot()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  pd = FastHenryHelper.plotdata(inductor)
  FastHenryHelper.pointsatlimits!(pd)
end
testplot()
