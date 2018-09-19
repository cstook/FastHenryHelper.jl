export Segment, SegmentParameters

struct SigmaRho
  sigma :: Float64
  rho   :: Float64
  function SigmaRho(sigma,rho)
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
    new(sigma,rho)
  end
end
SigmaRho(;sigma = NaN, rho=NaN) = SigmaRho(sigma,rho)
function Base.show(io::IO, x::SigmaRho)
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

mutable struct WxWyWz
  xyz :: Array{Float64,1}
  isdefault :: Bool
  function WxWyWz(wx, wy, wz)
    if norm([wx,wy,wz])<1e-9
      throw(ArgumentError("norm([wx,wy,wz])<1e-9"))
    end
    new([wx,wy,wz],isnan(wx) && isnan(wy) && isnan(wz))
  end
end
WxWyWz(;wx=NaN, wy=NaN, wz=NaN) =
  WxWyWz(wx,wy,wz)

function Base.show(io::IO, x::WxWyWz)
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

struct WH
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
function Base.show(io::IO, x::WH)
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
struct SegmentParameters
  wh        :: WH
  sigmarho  :: SigmaRho
  wxwywz    :: WxWyWz
end
SegmentParameters(;w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=NaN, wy=NaN, wz=NaN,
                  nhinc=0, nwinc=0, rh=NaN, rw=NaN) =
  SegmentParameters(WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
function SegmentParameters(sp::SegmentParameters; w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=NaN,
                           wy=NaN, wz=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN)
  new_w = isnan(w) ? sp.wh.w : w
  new_h = isnan(h) ? sp.wh.h : h
  new_nhinc = nhinc==0 ? sp.wh.nhinc : nhinc
  new_nwinc = nwinc==0 ? sp.wh.nwinc : nwinc
  new_rh = isnan(rh) ? sp.wh.rh : rh
  new_rw = isnan(rw) ? sp.wh.rw : rw
  new_sigma = isnan(sigma) ? sp.sigmarho.sigma : sigma
  new_rho = isnan(rho) ? sp.sigmarho.rho : rho
  new_wx = isnan(wx) ? sp.wxwywz.xyz[1] : wx
  new_wy = isnan(wy) ? sp.wxwywz.xyz[2] : wy
  new_wz = isnan(wz) ? sp.wxwywz.xyz[3] : wz
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
wx(sp::SegmentParameters) = sp.wxwywz.xyz[1]
wy(sp::SegmentParameters) = sp.wxwywz.xyz[2]
wz(sp::SegmentParameters) = sp.wxwywz.xyz[3]
wxyz(sp::SegmentParameters) = sp.wxwywz.xyz

"""
    Segment([name], n1::Node, n2::Node, [parameters::SegmentParameters])
    Segment([name], n1::Node, n2::Node, <keyword arguments>)

`Segment` objects `show` a FastHenry segment command.

Keyword arguments are the same as for `SegmentParameters`.

note: When rotating segments, the vector [wx, wy, wz] will be rotated.  Default
values will be used if not specified.  wx, wy, wz will show after `transform[!]` is
called on a `Segment`.
"""
struct Segment <: Element
  name      :: Symbol
  node1     :: Node
  node2     :: Node
  wh        :: WH
  sigmarho  :: SigmaRho
  wxwywz    :: WxWyWz
  function Segment(n, n1::Node, n2::Node, wh::WH, sigmarho::SigmaRho, wxwywz::WxWyWz)
    new_wxwywz = deepcopy(wxwywz)
#    initialixe_wxwywz!(n1,n2,new_wxwywz)
    new(Symbol(n), n1, n2, wh, sigmarho, new_wxwywz)
  end
end
Segment(n1::Node, n2::Node; w=NaN, h=NaN, sigma=NaN, rho=NaN,
        wx=NaN, wy=NaN, wz=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) =
            Segment(Symbol(""), n1, n2, WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
Segment(name, n1::Node, n2::Node; w=NaN, h=NaN, sigma=NaN, rho=NaN,
        wx=NaN, wy=NaN, wz=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) =
            Segment(name, n1, n2, WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))
Segment(n1::Node, n2::Node, sp::SegmentParameters) =
            Segment(Symbol(""), n1, n2, sp.wh, sp.sigmarho, sp.wxwywz)
Segment(name, n1::Node, n2::Node, sp::SegmentParameters) =
            Segment(name, n1, n2, sp.wh, sp.sigmarho, sp.wxwywz)
