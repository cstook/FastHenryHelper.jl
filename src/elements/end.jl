type End <: Element
end

function printfh(io::IO, ::End)
  println(io,".end")
end
