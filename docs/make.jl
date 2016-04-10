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

# Deploy docs.
# ============
#=

# We need to install an additional dep, `mkdocs-material`, so provide a custom `deps`.
custom_deps() = run(`pip install --user pygments mkdocs mkdocs-material`)

deploydocs(
    # options
    deps = custom_deps,
    repo = "https://github.com/cstook/LTspice.jl"
)
=#