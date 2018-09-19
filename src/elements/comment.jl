export Comment

"""
    Comment(text::AbstractString)

`Comment` objects `show` a FastHenry comment.
"""
struct Comment <: Element
  text :: String
end
