type End <: Element
end

function printfh(io::IO, ::End, ::AutoName)
  println(io,".end")
end
