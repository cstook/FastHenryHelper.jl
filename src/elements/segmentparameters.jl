

immutable SegmentParameters <: Element
  w :: Float64
  h :: Float64
  sigma :: Float64 
  rho :: Float64
  wx :: Float64 
  wy :: Float64 
  wz :: Float64 
  nhinc :: Float64 
  nwinc :: Float64 
  rh :: Float64 
  rw :: Float64
  function SegmentParameters(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)
    if ~isnan(rho) && ~isnan(sigma)
      throw(ArgumentError("Cannot specify both rho and sigma"))
    end
    return new(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)
  end
end
SegmentParameters(;w=NaN, h=NaN, sigma=NaN, rho=NaN, wx=NaN, wy=NaN, wz=NaN, nhinc=NaN, nwinc=NaN, rh=NaN, rw=NaN) = 
  SegmentParameters(w, h, sigma, rho, wx, wy, wz, nhinc, nwinc, rh, rw)

function printfh(io::IO, x::SegmentParameters)
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
  if ~isnan(x.wx) || ~isnan(x.wy) || ~isnan(x.wz) || ~isnan(x.nhinc) || 
     ~isnan(x.nwinc) || ~isnan(x.rh) || ~isnan(x.rw)
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
    if ~isnan(x.nhinc)
      @printf(io," nhinc=%.6e",x.nhinc) 
    end
    if ~isnan(x.nwinc)
      @printf(io," nwinc=%.6e",x.nwinc) 
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