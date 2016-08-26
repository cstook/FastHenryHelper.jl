using Documenter
using FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = FastHenryHelper,
    clean   = true,
    format = Documenter.Formats.HTML,
    sitename = "FastHenryHelper",
    pages = [
    "Home" => "index.md",
    "Installation" => "install.md",
    "Introduction" => "introduction.md"
  #  "Examples" => "examples.md",
  #  "Public API" => "public.md"
    ]
)
