export Title

"""
    Title(text::String)

`Title` objects `show` a FastHenry title.  Same as comment.
"""
immutable Title <: Element
  text :: String
end

function printfh!(io::IO, ::PrintFH, title::Title)
  println(io,"* ",title.text)
end
