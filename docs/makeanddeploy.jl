using Documenter
using FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = FastHenryHelper,
    clean   = true
)

# Deploy docs.
# ============


# We need to install an additional dep, `mkdocs-material`, so provide a custom `deps`.
# custom_deps() = run(`pip install --user pygments mkdocs mkdocs-material`)

deploydocs(
    # options
    repo = "git@github.com:cstook/FastHenryHelper.jl.git"
)
