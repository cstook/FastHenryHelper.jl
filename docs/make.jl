using Documenter
using FastFieldSolversHelper
using .FastCapHelper
using .FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = [FastFieldSolversHelper,
               FastFieldSolversHelper.FastHenryHelper,
               FastFieldSolversHelper.FastCapHelper],
    clean   = true
)
