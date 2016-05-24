type End <: Element
end

function printfh!(io::IO, ::PrintFH, ::End)
  println(io,".end")
end
