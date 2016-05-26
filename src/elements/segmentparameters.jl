export SegmentParameters

type SegmentParameters <: Element
  w :: Float64
  h :: Float64
  sigma :: Float64 
  rho :: Float64
  wx :: Float64 
  wy :: Float64 
  wz :: Float64 
  nhinc :: Int 
  nwinc :: Int 
  rh :: Float64 
  rw :: Float64
  function SegmentParameters(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
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
    return new(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)
  end
end
SegmentParameters(;w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=NaN, wy=NaN, wz=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
  SegmentParameters(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)

function printfh!(io::IO, ::PrintFH, x::SegmentParameters)
  if ~isnan(x.w)
    @printf(io," w=%.6e",x.w)
  end
  if ~isnan(x.h)
    @printf(io," h=%.6e",x.h) 
  end
  if ~isnan(x.sigma)
    @printf(io," sigma=%.6e",x.sigma) 
  end
  if ~isnan(x.rho)
    @printf(io," rho=%.6e",x.rho) 
  end
  println(io)
  if ~isnan(x.wx) || ~isnan(x.wy) || ~isnan(x.wz) || x.nhinc!=0 || 
     x.nwinc!=0 || ~isnan(x.rh) || ~isnan(x.rw)
     print(io, "+ ")
    if ~isnan(x.wx)
      @printf(io," wx=%.6e",x.wx) 
    end
    if ~isnan(x.wy)
      @printf(io," wy=%.6e",x.wy) 
    end
    if ~isnan(x.wz)
      @printf(io," wz=%.6e",x.wz) 
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
  end
  return nothing
end