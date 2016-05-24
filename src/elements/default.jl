
immutable Default <: Element
  sp :: SegmentParameters
end

function printfh!(io::IO, ::PrintFH, x::Default)
  print(io,".Default ")
  printfh!(io,x.sp,a)
end
