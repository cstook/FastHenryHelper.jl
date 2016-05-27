export Default

"""
    Default(;w=NaN, h=NaN, sigma=NaN, rho=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN)
    Default(sp::SegmentParameters)

`Default` objects `show` a .default FastHenry command.
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
