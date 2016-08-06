export Units

"""
    Units(unitname::AbstractString)

`Units` objects `show` a FastHenry .units command.
"""
immutable Units <: Element
  unitname :: AbstractString
  Units() = new("") # flag for internal use only
  function Units(x)
    if ~issubset(Set([x]),Set(["km", "m", "cm", "mm", "um", "in", "mils"]))
      throw(ArgumentError("valid units are km, m, cm, mm, um, in, mils"))
    end
    new(x)
  end
end

Base.(:(==))(x::Units, y::Units) = x.unitname == y.unitname
