export Equiv

"""
    Equiv(nodes::Array{Node,1})

`Equiv` objects `show` a FastHenry .equiv command
"""
struct Equiv <: Element
  nodes :: Array{Node,1}
end
