export Comment

"""
    Comment(text::AbstractString)

`Comment` objects `show` a FastHenry comment.
"""
immutable Comment <: Element
  text :: AbstractString
end
