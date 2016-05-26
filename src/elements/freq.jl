export Freq

immutable Freq <: Element
  min :: Float64
  max :: Float64
  ndec :: Float64
  function Freq(min, max, ndec)
    if min>max
      throw(ArgumentError("max must be >= min"))
    end
    if min<0 || max<0 || ndec<0
      throw(ArgumentError("all parameters must be >0"))
    end
    if isnan(max)
      throw(ArgumentError("must specify max frequency"))
    end
    return new(min,max,ndec)
  end
end

Freq(min,max) = Freq(min,max,NaN)
Freq(;min=0, max=NaN, ndec=NaN) = Freq(min,max,ndec)

function printfh!(io::IO, ::PrintFH, x::Freq)
  @printf(io,".freq fmin=%.9e fmax=%.9e",x.min,x.max) 
  if ~isnan(x.ndec)
    @printf(io," ndec=%.9e",x.ndec)
  end
  println(io)
  return nothing
end
