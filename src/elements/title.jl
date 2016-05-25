export Title

immutable Title <: Element
  text :: String
end

function printfh!(io::IO, ::PrintFH, title::Title)
  println(io,"* ",title.text)
end
