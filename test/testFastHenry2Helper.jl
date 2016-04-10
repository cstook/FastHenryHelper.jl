using .FastHenry2Helper

io = STDOUT
#io = "/test/testoutput.inp"

setdefaults(io)
(topnode,bottomnode) = via(io,2,.1,1,description="test via")
external(io,topnode,bottomnode,"test port")
frequency(io,1e6,10e9,2.5)
fasthenryend(io)

