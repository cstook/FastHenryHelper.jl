export viagroup

"""
    viagroup(radius, height, n, [parameters::SegmentParameters])
    viagroup(<keyword arguments>)

Returns a `Group` of `Segment`s for the barrel of a via.

**Keyword Arguments**

- `radius`          -- radius of via 
- `height`          -- height of via 
- `h`               -- thickness of copper plating
- `n`               -- number of segment around via
- `sigma`,`rho`     -- specify conductivity or resistivity
- `nhinc`           -- number of filaments per segment 
- `rh`              -- ratio of filament width

Terminals are in the center labeled :top and :bot.  Only `SegmentParameters` 
which match keyword arguments are used.  Specify n=0 to bypass via (.equiv top bot).
"""
viagroup(;radius=NaN, height=NaN, n=8, h=NaN, sigma=NaN, rho=NaN,
          nhinc=5, rh=NaN) = 
  viagroup(radius, height, n, SegmentParameters(h=h,sigma=sigma,rho=rho,nhinc=nhinc,rh=rh))
function viagroup(radius, height, n=8, sp::SegmentParameters=SegmentParameters())
  if isnan(radius)
    throw(ArgumentError("radius must be specified"))
  end
  if isnan(height)
    throw(ArgumentError("height must be specified"))
  end
  if isnan(h(sp))
    throw(ArgumentError("wall thickness (height of segment) must be specified"))
  end
  if n!=0 && n<2 
    throw(ArgumentError("must have zero or at least 2 segments"))
  end
  group = Group()
  terminals = terms(group)
  viaelements = elements(group)
  centertop = Node(0,0,0)
  centerbot = Node(0,0,-height)
  # terminals = Dict(:top=>centertop,:bot=>centerbot)
  terminals[:top] = centertop
  terminals[:bot] = centerbot
  if n!=0
    angle = linspace(0.0, 2.0*pi-(2*pi/n), n)
    x = radius .* map(cos,angle)
    y = radius .* map(sin,angle)
    wx = map(cos,angle.+(pi/2))
    wy = map(sin,angle.+(pi/2))
    w = sqrt((x[1]-x[2])^2+(y[1]-y[2])^2) * 1/cos(pi/n)
    topnodes = Array(Node,n)
    botnodes = Array(Node,n)
    for i in 1:n
      topnodes[i] = Node(x[i],y[i],0.0)
      botnodes[i] = Node(x[i],y[i],-height)
    end
    eqtop = Equiv([centertop;topnodes])
    eqbot = Equiv([centerbot;botnodes])
    segments = Array(Segment,n)
    for i in 1:n
      segments[i] = Segment(topnodes[i],botnodes[i],
        SegmentParameters(sp, w=w, wx=wx[i], wy=wy[i], wz=0.0, nwinc=1))
    end
    terminals[:alltop] = topnodes
    terminals[:allbot] = botnodes
    # group = Group([topnodes;botnodes;centertop;centerbot;eqtop;eqbot;segments],terminals)
    append!(viaelements,[topnodes;botnodes;centertop;centerbot;eqtop;eqbot;segments])
  else # n=0 for bypass
    terminals[:alltop] = Array{Node}([centertop])
    terminals[:allbot] = Array{Node}([centerbot])
    eq = Equiv([centertop;centerbot])
    # group = Group([centertop;centerbot;eq],terminals)
    append!(viaelements,[centertop;centerbot;eq])
  end
  return group
end