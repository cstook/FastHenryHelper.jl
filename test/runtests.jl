using FastHenryHelper
using Base.Test

# compare what an element shows to string
function testelement(e::Element, verified::ASCIIString)
  ebuf = IOBuffer()
  show(ebuf,e)
  @test takebuf_string(ebuf) == verified
end

function testelementdebug(e::Element, verified::ASCIIString)
  ebuf = IOBuffer()
  show(ebuf,e)
  debug = open("debug.txt","w")
  println(debug,"element  =")
  println(debug, takebuf_string(ebuf))
  println(debug,"verified =")
  println(debug, verified)
  close(debug)
  warn("testelementdebug called")
end

include("testelement.jl")
#include("testvisualize.jl")
#include("testplot.jl")
#include("testgroups.jl")
#include("testutil.jl")

include("old_runtests.jl")
