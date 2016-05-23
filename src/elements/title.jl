immutable Title <: Element
  string :: String
end

function printfh(io::IO, title::Title)
  println(io,"* ",title.string)
end
