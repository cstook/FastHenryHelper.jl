export Default

immutable Default <: Element
  sp :: SegmentParameters
  Default(sp) = new(deepcopy(sp))
end

function printfh!(io::IO, pfh::PrintFH, x::Default)
  print(io,".default ")
  printfh!(io, pfh, x.sp)
end
