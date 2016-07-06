export End

"""
    End()

`End` objects `show` a FastHenry .end command.
"""
type End <: Element
end

function Base.show(io::IO, ::End, autoname = nothing)
  println(io,".end")
end
