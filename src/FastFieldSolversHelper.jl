"""
Main module

Helps creating input files for FastFieldSolvers.

You must include a submodule, for example:
```julia
using .FastCapHelper
using .FastHenryHelper
"""
module FastFieldSolversHelper

export FastHenryHelper, FastCapHelper

include("FastHenryHelper.jl")
include("FastCapHelper.jl")


end # module
