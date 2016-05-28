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
- `sigma`,`rho`     -- specify conductivity or resitivity
- `hninc`           -- number of filaments per segment 
- `rh`              -- ratio of filament width

Terminals are in the center labeled :top and :bot.  Only `SegmentParameters` 
which match keyword arguments are used.  Specify n=0 to bypass via (.equiv top bot).
"""
viagroup(;radius=NaN, height=NaN, n=8, h=NaN, sigma=NaN, rho=NaN,
          nhinc=5, rh=NaN) = 
  viagroup(radius, height, n, SegmentParameters(h=h,sigma=sigma,rho=rho,nhinc=nhinc,rh=rh))
function viagroup(r, h, n=8, sp::SegmentParameters=SegmentParameters())
  if isnan(r)
    throw(ArgumentError("radius must be specified"))
  end
  if isnan(h)
    throw(ArgumentError("height must be specified"))
  end
  if isnan(sp.wh.h)
    throw(ArgumentError("wall thickness (height of segemnt) must be specified"))
  end
  if n!=0 && n<2 
    throw(ArgumentError("must have zero or at least 2 segments"))
  end
  centertop = Node(0,0,0)
  centerbot = Node(0,0,-h)
  terminals = Dict(:top=>centertop,:bot=>centerbot)
  if n!=0
    angle = linspace(0.0, 2.0*pi-(2*pi/n), n)
    x = r .* map(cos,angle)
    y = r .* map(sin,angle)
    wx = map(cos,angle.+(pi/2))
    wy = map(sin,angle.+(pi/2))
    w = sqrt((x[1]-x[2])^2+(y[1]-y[2])^2)
    topnodes = Array(Node,n)
    botnodes = Array(Node,n)
    for i in 1:n
      topnodes[i] = Node(x[i],y[i],0.0)
      botnodes[i] = Node(x[i],y[i],-h)
    end
    eqtop = Equiv([centertop;topnodes])
    eqbot = Equiv([centerbot;botnodes])
    segments = Array(Segment,n)
    for i in 1:n
      segments[i] = Segment(topnodes[i],botnodes[i],
                      w=sp.wh.w, h=sp.wh.h, wx=wx[i], wy=wy[i], 
                      nhinc=sp.wh.nhinc, rh=sp.wh.rh, sigma=sp.sigmarho.sigma,
                      rho=sp.sigmarho.rho, nwinc=1)
    end
    group = Group([topnodes;botnodes;eqtop;eqbot;segments],terminals)
  else # n=0 for bypass
    eq = Equiv([centertop;centerbot])
    group = Group([centertop;centerbot;eq],terminals)
  end
  return group
end