
immutable Units <: Element
  unitname :: String
  function Units(x)
    if ~issubset(Set([x]),Set(["km", "m", "cm", "mm", "um", "in", "mils"]))
      throw(ArgumentError("valid units are km, m, cm, mm, um, in, mils"))
    end
    new(x)
  end
end

function printfh(io::IO, x::Units)
  println(io,".units ",x.unitname)
  return nothing
end