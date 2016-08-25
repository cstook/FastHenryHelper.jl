using Documenter
using FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = FastHenryHelper,
  #  clean   = true,
    format = Documenter.Formats.HTML,
    sitename = "FastHenryHelper",
    pages = [
    "Home" => "index.md"
    ]
)
