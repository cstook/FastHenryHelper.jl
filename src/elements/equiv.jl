export Equiv

"""
    Equiv(nodes::Array{Node,1})

`Equiv` objects `show` a FastHenry .equiv command
"""
immutable Equiv <: Element
  nodes :: Array{Node,1}
end
