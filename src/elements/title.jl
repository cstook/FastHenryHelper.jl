immutable Title <: Element
  text :: String
end

function printfh(io::IO, title::Title)
  println(io,"* ",title.text)
end
