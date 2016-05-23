immutable Title <: Element
  string :: String
end

function printfh(io::IO, title::Title)
  print(io,"* ",title.string)
end
