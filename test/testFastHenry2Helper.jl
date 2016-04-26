using .FastHenry2Helper

io = STDOUT
#io = "/test/testoutput.inp"

setdefaults(io)
x_offset = 1.0
y_offset = 2.0
top = 0.0
bot = 1.0
radius = 10.0
wall_thickness = 0.3
(topnode,bottomnode) = via(io, x_offset, y_offset, top, bot, radius, wall_thickness, description="test via")
external(io,topnode,bottomnode,"test port")
frequency(io,1e6,10e9,2.5)
fasthenryend(io)

# this will not be a vaild file for now
lastused = LastUsed()
@test 1 == node!(io, lastused, 1.0,1.1,2.3)
@test 2 == node!(io, lastused, 2.0,2.1,3.3,comment="comment test")

