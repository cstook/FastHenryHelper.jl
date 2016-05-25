export Default

immutable Default <: Element
  sp :: SegmentParameters
end

function printfh!(io::IO, pfh::PrintFH, x::Default)
  print(io,".default ")
  printfh!(io, pfh, x.sp)
end
