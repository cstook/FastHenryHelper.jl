using Documenter
using FastFieldSolversHelper
using .FastCapHelper
using .FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = FastFieldSolversHelper.FastHenryHelper,
    clean   = true
)
