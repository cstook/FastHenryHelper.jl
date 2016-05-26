export Default

immutable Default <: Element
  sp :: SegmentParameters
  function Default(sp)
    if ~isnan(sp.wx)
      throw(ArgumentError("cannot specify default wx"))
    end
    if ~isnan(sp.wy)
      throw(ArgumentError("cannot specify default wy"))
    end
    if ~isnan(sp.wz)
      throw(ArgumentError("cannot specify default wz"))
    end
    new(deepcopy(sp))
  end
end

function printfh!(io::IO, pfh::PrintFH, x::Default)
  print(io,".default ")
  printfh!(io, pfh, x.sp)
end
