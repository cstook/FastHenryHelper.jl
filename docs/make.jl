push!(LOAD_PATH,"..")
using Documenter
using FastHenryHelper
# wait(Timer(1)) # why do I need this?

const PAGES = [
  "Home" => "index.md",
  "Installation" => "install.md",
  "Introduction" => "introduction.md",
  "Examples" => "examples.md",
  "Public API" => "public.md",
]

makedocs(
  modules = [FastHenryHelper],
  doctest   = "doctest" in ARGS,
  linkcheck = "linkcheck" in ARGS,
  clean   = true,
  format = "pdf" in ARGS ? :latex : :html,
  build = "site",
  sitename = "FastHenryHelper.jl",
  authors = "Chris Stook",
  doctest = true,
  pages = PAGES,
  html_prettyurls = "deploy" in ARGS,
)

if "deploy" in ARGS
  fake_travis = "C:/Users/Chris/fake_travis_FastHenryHelper.jl"
  if isfile(fake_travis)
    include(fake_travis)
  end
  deploydocs(
    repo = "github.com/cstook/FastHenryHelper.jl.git",
    target = "site",
    branch = "gh-pages",
    latest = "master",
    osname = "linux",
    julia  = "0.7",
    deps = nothing,
    make = nothing,
  )
end
