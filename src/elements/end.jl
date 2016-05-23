type End <: Element
end

function printfh(io::IO, ::End)
  print(io,".end")
end
