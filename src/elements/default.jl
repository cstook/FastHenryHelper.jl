export Default

"""
    Default(<keyword arguments>)
    Default(parameters::SegmentParameters)

`Default` objects `show` a .default FastHenry command.

**Keyword Arguments**

- `w`               -- segment width
- `h`               -- segment height
- `sigma`           -- conductivity 
- `rho`             -- resistivity
- `nhinc`, `nwinc`  -- integer number of filaments in height and width
- `rh`, `rw`        -- ratio in the height and width
"""
immutable Default <: Element
  wh        :: WH
  sigmarho  :: SigmaRho
end
Default(;w=NaN, h=NaN, sigma=NaN, rho=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
    Default(WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho))
Default(sp::SegmentParameters) = Default(sp.wh, sp.sigmarho)

function printfh!(io::IO, pfh::PrintFH, x::Default)
  println(io,".default ")
  printfh!(io, pfh, x.wh)
  printfh!(io, pfh, x.sigmarho)
end

function plotdata!(pd::PlotData, d::Default)
  pd.default_w = d.wh.w
  pd.default_h = d.wh.h
  return nothing
end