using .FastHenry2Helper

io = STDOUT
#io = "/test/testoutput.inp"

titleline(io,"Testing FestHenry2Helper")
units(io,"mm")
default(io,x=0,y=0,z=0,sigma=5.8e4,nhinc=5,nwinc=7,comment="sigma for copper")
comment(io,"a comment")

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
@test 1 == segment!(io, lastused, 1.0,2.0,w=0.4,h=0.2)

external(io,1,2,"port1")


