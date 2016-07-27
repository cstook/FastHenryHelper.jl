function testplot()
  inductor = coilcraft1010vsgroup("1010VS-111ME")
  pd = FastHenryHelper.PlotData(inductor)
  FastHenryHelper.pointsatlimits!(pd)
end
testplot()
