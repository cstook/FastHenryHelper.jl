export Comment

"""
    Comment(text::AbstractString)

`Comment` objects `show` a FastHenry comment.
"""
immutable Comment <: Element
  text :: AbstractString
end

function Base.show(io::IO, x::Comment; autoname = nothing)
  println(io,"* ",x.text)
end
