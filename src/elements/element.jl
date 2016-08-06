export Element
"""
Subtypes of `Element` `show` FastHenry commands.

Geometric transformations can be preformed on elements with `transform`.
Elements which require a name will automatically generate unique names if
no name is provided.  Groups of elements are elements.
"""
abstract Element

# elements
include("title.jl")
include("node.jl")
include("segment.jl")
include("units.jl")
include("default.jl")
include("external.jl")
include("freq.jl")
include("equiv.jl")
include("end.jl")
include("uniformdiscretizedplanes.jl")
include("comment.jl")
include("group.jl")

# context experiment
include("context.jl")

# functions for elements
include("transform.jl")
include("traversetree.jl")
include("showelement.jl")
include("mesh.jl")
include("plot.jl")
