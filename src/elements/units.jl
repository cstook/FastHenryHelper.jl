export Units

"""
    Units(unitname::AbstractString)

`Units` objects `show` a FastHenry .units command.
"""
immutable Units <: Element
  unitname :: AbstractString
  function Units(x)
    if ~issubset(Set([x]),Set(["km", "m", "cm", "mm", "um", "in", "mils"]))
      throw(ArgumentError("valid units are km, m, cm, mm, um, in, mils"))
    end
    new(x)
  end
end

function Base.show(io::IO, x::Units, autoname = nothing)
  println(io,".units ",x.unitname)
  return nothing
end
