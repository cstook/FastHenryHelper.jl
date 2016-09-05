using Documenter
using FastHenryHelper

# Build docs.
# ===========

makedocs(
    modules = [FastHenryHelper],
    clean   = true,
    format = Documenter.Formats.HTML,
    sitename = "FastHenryHelper.jl",
    doctest = true,
    pages = [
    "Home" => "index.md",
    "Installation" => "install.md",
    "Introduction" => "introduction.md",
    "Examples" => "examples.md",
    "Public API" => "public.md"
    ]
)
println("**************** DONE *********************")
wait(Timer(5))
