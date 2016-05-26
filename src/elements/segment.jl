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
    @printf(io," sigma=%.6e",x.sigma) 
  end
  if ~isnan(x.rho)
    @printf(io," rho=%.6e",x.rho) 
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
      @printf(io," wx=%.6e",x.xyz[1]) 
    end
    if ~isnan(x.xyz[2])
      @printf(io," wy=%.6e",x.xyz[2]) 
    end
    if ~isnan(x.xyz[3])
      @printf(io," wz=%.6e",x.xyz[3]) 
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
    @printf(io," w=%.6e",x.w)
  end
  if ~isnan(x.h)
    @printf(io," h=%.6e",x.h) 
  end
  if x.nhinc>0
    print(io," nhinc=",x.nhinc) 
  end
  if x.nwinc>0
    print(io," nwinc=",x.nwinc) 
  end
  if ~isnan(x.rh)
    @printf(io," rh=%.6e",x.rh) 
  end
  if ~isnan(x.rw)
    @printf(io," rw=%.6e",x.rw) 
  end
  println(io)
  return nothing
end

immutable SegmentParameters
  wh        :: WH
  sigmarho  :: SigmaRho
  wxwywz    :: WxWyWz
end
SegmentParameters(;w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=0.0, wy=0.0, wz=0.0,
                  nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
  SegmentParameters(WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho), WxWyWz(wx,wy,wz))

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