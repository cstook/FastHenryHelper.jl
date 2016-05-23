immutable Comment <: Element
  text :: String
end

function printfh(io::IO, x::Comment)
  println(io,"* ",x.text)
end

