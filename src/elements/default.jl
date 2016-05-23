
immutable Default <: Element
  sp :: SegmentParameters
end

function printfh(io::IO, x::Default, a::AutoName)
  print(io,".Default ")
  printfh(io,x.sp,a)
end
