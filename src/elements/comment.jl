immutable Comment <: Element
  text :: String
end

function printfh(io::IO, x::Comment, ::AutoName)
  println(io,"* ",x.text)
end

