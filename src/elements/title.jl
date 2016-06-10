export Title

"""
    Title(text::AbstractString)

`Title` objects `show` a FastHenry title.  Same as comment.
"""
immutable Title <: Element
  text :: AbstractString
end

function printfh!(io::IO, ::PrintFH, title::Title)
  println(io,"* ",title.text)
end

function plotdata!(pd::PlotData, title::Title)
  if length(pd.title) == 0
    pd.title = title.text
  end
  return nothing
end