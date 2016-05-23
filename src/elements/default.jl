
immutable Default <: Element
  sp :: SegmentParameters
end

function printfh(io::IO, x::Default)
  print(io,".Default ")
  printfh(io,x.sp)
end
