export Default

immutable Default <: Element
  wh        :: WH
  sigmarho  :: SigmaRho
end
Default(;w=NaN, h=NaN, sigma=NaN, rho=NaN, nhinc=0, nwinc=0, rh=NaN, rw=NaN) = 
    Default(WH(w,h,nhinc,nwinc,rh,rw), SigmaRho(sigma,rho))

function printfh!(io::IO, pfh::PrintFH, x::Default)
  print(io,".default ")
  printfh!(io, pfh, x.wh)
  printfh!(io, pfh, x.sigmarho)
end
