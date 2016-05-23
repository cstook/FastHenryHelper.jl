immutable Title <: Element
  text :: String
end

function printfh(io::IO, title::Title, ::AutoName)
  println(io,"* ",title.text)
end
