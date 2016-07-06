export Title

"""
    Title(text::AbstractString)

`Title` objects `show` a FastHenry title.  Same as comment.
"""
immutable Title <: Element
  text :: AbstractString
end

function Base.show(io::IO, title::Title; autoname = nothing)
  println(io,"* ",title.text)
end
