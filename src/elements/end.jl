export End

"""
    End()

`End` objects `show` a FastHenry .end command.
"""
type End <: Element
end

function printfh!(io::IO, ::PrintFH, ::End)
  println(io,".end")
end
