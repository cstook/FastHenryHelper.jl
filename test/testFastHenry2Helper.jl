using .FastHenry2Helper

include("testcoordinates.jl")
result = parsefasthenrymap("example3_Zc.mat")

io = STDOUT
#io = "/test/testoutput.inp"

lastused = LastUsed()
titleline(io,"Testing FestHenry2Helper")
units(io,"mm")
default(io,x=0,y=0,z=0,sigma=5.8e4,nhinc=5,nwinc=7,comment="sigma for copper")
comment(io,"a comment")

x = 1.0
y = 2.0
top = 0.0
bot = 1.0
radius = 10.0
wall_thickness = 0.3
(topnode,bottomnode) = via!(io, lastused, x, y, top, bot, radius, wall_thickness, comment="test via")

node!(io, lastused, 1.0,1.1,2.3)
node!(io, lastused, 2.0,2.1,3.3,comment="comment test")
segment!(io, lastused, 1.0,2.0,w=0.4,h=0.2)
referenceplane!(io,lastused,1,1,1,2,2,2,3,3,3,.1,10,10)
referenceplane!(io,lastused,1,1,1,2,2,2,3,3,3,.1,10,10,
                segwid1 = .2, segwid2 = .2,
                sigma = 5.8e4,
                nhinc = 10, rh = 2,
                relx = 0, rely = 0, relz = 0,
                nodes = [(1.1,2.2,3.3),(1.2,1.3,1.4)],
                holes = [("point",1,2,3),
                         ("rect",1,2,3,4,5,6),
                         ("circle",2,3,4,5)])

external(io,1,2,"port1")
external(io,topnode,bottomnode,"test port")
frequency(io,1e6,10e9,2.5)
fasthenryend(io)



