"""
Helps creating input files for FastFieldSolvers.

You must include a submodule, for example:
```julia
using .FastCap2Helper
using .FastHenry2Helper
"""
module FastFieldSolversHelper

export FastHenry2Helper, FastCap2Helper

include("FastHenry2Helper.jl")
include("FastCap2Helper.jl")

end # module
