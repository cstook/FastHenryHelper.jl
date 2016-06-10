export Comment

"""
    Comment(text::AbstractString)

`Comment` objects `show` a FastHenry comment.
"""
immutable Comment <: Element
  text :: AbstractString
end

function printfh!(io::IO, ::PrintFH, x::Comment)
  println(io,"* ",x.text)
end

