using Documenter
using FastFieldSolversHelper
using .FastCap2Helper
using .FastHenry2Helper

# Build docs.
# ===========

makedocs(
    modules = FastFieldSolversHelper.FastHenry2Helper,
    clean   = true
)
