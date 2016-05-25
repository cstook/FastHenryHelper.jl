export Default

immutable Default <: Element
  sp :: SegmentParameters
end

function printfh!(io::IO, pfh::PrintFH, x::Default)
  print(io,".Default ")
  printfh!(io, pfh, x.sp)
end
