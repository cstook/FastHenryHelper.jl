using FastHenryHelper
using Base.Test

# compare what an element shows to string
function testelement(e::Element, verified::String)
  ebuf = IOBuffer()
  show(ebuf,e)
  @test takebuf_string(ebuf) == verified
end

function testelementdebug(e::Element, verified::String)
  ebuf = IOBuffer()
  show(ebuf,e)
  debugio = open("debug.txt","w")
  println(debugio, takebuf_string(ebuf))
  close(debugio)
  verifiedio = open("verified.txt","w")
  println(verifiedio, verified)
  close(verifiedio)
  warn("testelementdebug called")
end

include("testelement.jl")
include("groupsfortests.jl")
include("testcontext.jl")
include("testtraversetree.jl")
include("testtransform.jl")
include("testmesh.jl")
include("testplot.jl")
include("testgroups.jl")
include("testutil.jl")
