export Segment, SegmentParameters

immutable SigmaRho
  sigma :: Float64
  rho   :: Float64 
  function SigmaRho(sigma,rho)
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
    new(sigma,rho)
  end
end
SigmaRho(;sigma = NaN, Rho=NaN) = SigmaRho(sigma,rho)
function printfh!(io::IO, ::PrintFH, x::SigmaRho)
  if isnan(x.sigma) && isnan(x.rho)
    return nothing
  end
  print(io,"+ ")
  if ~isnan(x.sigma)
    @printf(io," sigma=%.9e",x.sigma) 
  end
  if ~isnan(x.rho)
    @printf(io," rho=%.9e",x.rho) 
  end
  println(io)
  return nothing
end

type WxWyWz
  xyz :: Array{Float64,1}
  isdefault :: Bool
end
WxWyWz(;wx=0.0, wy=0.0, wz=0.0) = 
  WxWyWz([wx,wy,wz],wx==0.0 && wy==0.0 && wz==0.0)
WxWyWz(wx, wy, wz) = 
  WxWyWz([wx,wy,wz],wx==0.0 && wy==0.0 && wz==0.0)
function printfh!(io::IO, ::PrintFH, x::WxWyWz)
  if ~x.isdefault
    print(io,"+ ")
    if ~isnan(x.xyz[1])
      @printf(io," wx=%.9e",x.xyz[1]) 
    end
    if ~isnan(x.xyz[2])
      @printf(io," wy=%.9e",x.xyz[2]) 
    end
    if ~isnan(x.xyz[3])
      @printf(io," wz=%.9e",x.xyz[3]) 
    end
    println(io)
  end
  return nothing
end
function transform!(x::WxWyWz, tm::Array{Float64,2})
  newxyz = tm[1:3,1:3]*x.xyz
  x.xyz = newxyz
  x.isdefault = false
  return nothing
end

immutable WH
  w :: Float64
  h :: Float64 
  nhinc :: Int 
  nwinc :: Int 
  rh :: Float64 
  rw :: Float64
  function WH(w, h, nhinc, nwinc, rh, rw)
    if nhinc<0
      throw(ArgumentError("nhinc must be a positive integer"))
    end
    if nwinc<0
      throw(ArgumentError("nwinc must be a positive integer"))
    end
    if rh<0
      throw(ArgumentError("rh must be positive"))
    end
    if rw<0
      throw(ArgumentError("rw must be positive"))
    end
    return new(w, h, nhinc, nwinc, rh, rw)
  end
end
WH(;w=NaN, h=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
  WH(w, h, nhinc, nwinc, rh, rw)
function printfh!(io::IO, ::PrintFH, x::WH)
  if isnan(x.w) && isnan(x.h) && x.nhinc==0 && x.nwinc==0 && isnan(x.rh) && isnan(x.rw)
    return nothing
  end
  print(io,"+ ")
  if ~isnan(x.w)
    @printf(io," w=%.9e",x.w)
  end
  if ~isnan(x.h)
    @printf(io," h=%.9e",x.h) 
  end
  if x.nhinc>0
    print(io," nhinc=",x.nhinc) 
  end
  if x.nwinc>0
    print(io," nwinc=",x.nwinc) 
  end
  if ~isnan(x.rh)
    @printf(io," rh=%.9e",x.rh) 
  end
  if ~isnan(x.rw)
    @printf(io," rw=%.9e",x.rw) 
  end
  println(io)
  return nothing
end

"""
    SegmentParameters(<keyword arguments>)
    SegmentParameters(parameters::SegmentParameters, <keyword arguments>)

Object to hold parameters for `Segment` and `Default`

**Keyword Arguments**

- `w`               -- segment width
- `h`               -- segment height
- `sigma`           -- conductivity 
- `rho`             -- resistivity 
- `wx`, `wy`, `wz`  -- segment orientation.  vector pointing along width of segment's cross section.
- `nhinc`, `nwinc`  -- integer number of filaments in height and width
- `rh`, `rw`        -- ratio in the height and width

The second form replaces values in `parameters` with any keyword parameters present.
"""
immutable SegmentParameters
  wh        :: WH
  sigmarho  :: SigmaRho
  wxwywz    :: WxWyWz
end
SegmentParameters(;w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=0.0, wy=0.0, wz=0.0,
                  nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
  SegmentParameters(WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
function SegmentParameters(sp::SegmentParameters; w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=0.0,
                           wy=0.0, wz=0.0, nhinc=0, nwinc=0, rh=NaN, rw=NaN)
  new_w = isnan(w) ? sp.wh.w : w
  new_h = isnan(h) ? sp.wh.h : h
  new_nhinc = isnan(nhinc) ? sp.wh.nhinc : nhinc
  new_nwinc = isnan(nwinc) ? sp.wh.nwinc : nwinc
  new_rh = isnan(rh) ? sp.wh.rh : rh
  new_rw = isnan(rw) ? sp.wh.rw : rw
  new_sigma = isnan(sigma) ? sp.sigmarho.sigma : sigma
  new_rho = isnan(rho) ? sp.sigmarho.rho : rho
  new_wx = isnan(wx) ? sp.wxwywz.wx : wx
  new_wy = isnan(wy) ? sp.wxwywz.wy : wy
  new_wz = isnan(wz) ? sp.wxwywz.wz : wz
  new_wh = WH(new_w,new_h,new_nhinc,new_nwinc,new_rh,new_rw)
  new_sigmarho = SigmaRho(new_sigma, new_rho)
  new_wxwywz = WxWyWz(new_wx,new_wy,new_wz)
  SegmentParameters(new_wh, new_sigmarho, new_wxwywz)
end

w(sp::SegmentParameters) = sp.wh.w
h(sp::SegmentParameters) = sp.wh.h
nhinc(sp::SegmentParameters) = sp.wh.nhinc
nwinc(sp::SegmentParameters) = sp.wh.nwinc
rh(sp::SegmentParameters) = sp.wh.rh
rw(sp::SegmentParameters) = sp.wh.rw
sigma(sp::SegmentParameters) = sp.sigmarho.sigma
rho(sp::SegmentParameters) = sp.sigmarho.rho
wx(sp::SegmentParameters) = sp.wxwywz.wx
wy(sp::SegmentParameters) = sp.wxwywz.wy
wz(sp::SegmentParameters) = sp.wxwywz.wz

"""
    Segment([name], n1::Node, n2::Node, [parameters::SegmentParameters])
    Segment([name], n1::Node, n2::Node, <keyword arguments>)

`Segment` objects `show` a FastHenry segment command.

Keyword arguments are the same as for `SegmentParameters`.

note: When rotating segments, the vector [wx, wy, wz] will be rotated.  Default 
values will be used if not specified.  wx, wy, wz will show after `transform[!]` is 
called on a `Segment`.
"""
immutable Segment <: Element
  name      :: AutoName
  node1     :: Node 
  node2     :: Node 
  wh        :: WH
  sigmarho  :: SigmaRho
  wxwywz    :: WxWyWz
  function Segment(n, n1::Node, n2::Node, wh::WH, sigmarho::SigmaRho, wxwywz::WxWyWz)
    new_wxwywz = deepcopy(wxwywz)
    initialixe_wxwywz!(n1,n2,new_wxwywz)
    new(AutoName(n), n1, n2, wh, sigmarho, new_wxwywz)
  end
end
Segment(n1::Node, n2::Node; w=NaN, h=NaN, sigma=NaN, rho=NaN,
        wx=0.0, wy=0.0, wz=0.0, nhinc=0, nwinc=0, rh=NaN, rw=NaN) =
            Segment(:null, n1, n2, WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
Segment(name, n1::Node, n2::Node; w=NaN, h=NaN, sigma=NaN, rho=NaN,
        wx=0.0, wy=0.0, wz=0.0, nhinc=0, nwinc=0, rh=NaN, rw=NaN) =
            Segment(name, n1, n2, WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
Segment(n1::Node, n2::Node, sp::SegmentParameters) = 
            Segment(:null, n1, n2, sp.wh, sp.sigmarho, sp.wxwywz)
Segment(name, n1::Node, n2::Node, sp::SegmentParameters) = 
            Segment(name, n1, n2, sp.wh, sp.sigmarho, sp.wxwywz)     

function printfh!(io::IO, pfh::PrintFH, s::Segment)
  println(io,"E",autoname!(pfh,s.name)," N",autoname!(pfh,s.node1.name)," N",autoname!(pfh,s.node2.name)," ")
  printfh!(io,pfh,s.wh)
  printfh!(io,pfh,s.sigmarho)
  printfh!(io,pfh,s.wxwywz)
  return nothing
end

resetiname!(x::Segment) = reset!(x.name)

function wxwywz(p1, p2)
  v1 = p2 - p1
  v2 = [0.0, 0.0, 1.0]
  w = cross(v1,v2)
  if norm(w) < 1e-10  # close to 0
    v2 = [0.0, 1.0, 0.0]
    w = cross(v1,v2)
  end
  w/norm(w,3)
end
function initialixe_wxwywz!(n1::Node, n2::Node, wxwywz::WxWyWz)
  if wxwywz.isdefault
    v1 = n2.xyz - n1.xyz
    v2 = [0.0, 0.0, 1.0]
    w = cross(v1,v2)
    if norm(w) < 1e-10  # close to 0
      v2 = [0.0, 1.0, 0.0]
      w = cross(v1,v2)
    end
    wxwywz.xyz = (w/norm(w,3))
  end
  return nothing
end

function transform!(s::Segment, tm::Array{Float64,2})
  transform!(s.wxwywz,tm)  #  assume nodes are transformed as part of a group
  return nothing
end

function transform(s::Segment, tm::Array{Float64,2})
  news = deepcopy(s)
  transform!(news)
end

function corners(p1, p2, w, h)
  wxyz = wxwywz(p1,p2)
  mp1 = p1+(wxyz.*w)
  mp2 = p1-(wxyz.*w)
  mp3 = p2+(wxyz.*w)
  mp4 = p2-(wxyz.*w)
  hxyz = cross(wxyz,(p2-p1))
  hxyz = hxyz/norm(hxyz,3)
  result = Array(Float64,(3,8))
  result[:,1] = mp1+(hxyz.*h)
  result[:,2] = mp1-(hxyz.*h)
  result[:,3] = mp2-(hxyz.*h)
  result[:,4] = mp2+(hxyz.*h)
  result[:,5] = mp3+(hxyz.*h)
  result[:,6] = mp3-(hxyz.*h)
  result[:,7] = mp4-(hxyz.*h)
  result[:,8] = mp4+(hxyz.*h)
  return result
end

function plotdata!(pd::PlotData, s::Segment)
  p1 = xyz(s.node1)
  p2 = xyz(s.node2)
  c = corners(p1, p2, s.wh.w, s.wh.h)
  s = [(1,2),(2,3),(3,4),(4,1),(5,6),(6,7),(7,8),(8,5),(1,5),(2,6),(3,7),(4,8)]
  for (a,b) in s
      pd.groupcounter += 1
      push!(pd.group,pd.groupcounter,pd.groupcounter)
      push!(pd.marker,:none)
      push!(pd.x,c[1,a],c[1,b])
      push!(pd.y,c[2,a],c[2,b])
      push!(pd.z,c[3,a],c[3,b])
  end
  return nothing
end