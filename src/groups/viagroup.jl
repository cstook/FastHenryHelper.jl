export viagroup

viagroup(;radius=NaN, height=NaN, wallthickness=NaN, n=8, nhinc=5, rh=NaN) = 
  viagroup(radius, height, wallthickness, n, nhinc)
function viagroup(r, h, t, n=8, nhinc=5)
  if isnan(r)
    throw(ArgumentError("radius must be specified"))
  end
  if isnan(h)
    throw(ArgumentError("height must be specified"))
  end
  if isnan(t)
    throw(ArgumentError("wallthickness must be specified"))
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
    sp = SegmentParameters(w=w,h=t,nhinc=nhinc,nwinc=1)
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
                      w=w, h=t, wx=wx[i], wy=wy[i], nhinc=nhinc, rh=rh, nwinc=1)
    end
    group = Group([topnodes;botnodes;eqtop;eqbot;segments],terminals)
  else # n=0 for bypass
    eq = Equiv([centertop;centerbot])
    group = Group([centertop;centerbot;eq],terminals)
  end
  return group
end