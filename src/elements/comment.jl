export Comment

"""
    Comment(text::String)

`Comment` objects `show` a FastHenry comment.
"""
immutable Comment <: Element
  text :: String
end

function printfh!(io::IO, ::PrintFH, x::Comment)
  println(io,"* ",x.text)
end

