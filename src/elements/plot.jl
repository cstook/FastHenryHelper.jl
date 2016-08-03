# produce a wireframe using Plots
import Plots: plot

type PlotData
  title :: AbstractString
  x :: Array{Float64,1}
  y :: Array{Float64,1}
  z :: Array{Float64,1}
  group :: Array{Int,1}
  marker :: Array{Symbol,1}
  markercolor :: Array{Symbol,1}
  markeralpha :: Array{Float64,1}
  markersize :: Array{Float64,1}
  markerstrokewidth :: Array{Float64,1}
  linecolor :: Array{Symbol,1}
  groupcounter :: Int
  PlotData() = new("",[],[],[],[],[],[],[],[],[],[],0)
end

immutable PlotElementParameters
  marker :: Symbol
  markercolor :: Symbol
  markeralpha :: Float64
  markersize :: Float64
  markerstrokewidth :: Float64
  linecolor :: Symbol
end
immutable PlotScheme
  node :: PlotElementParameters
  segment :: PlotElementParameters
  plane :: PlotElementParameters
  planenode :: PlotElementParameters
  invisiblenode :: PlotElementParameters
end
const plotelementparameters_node=          (:circle,:red,0.3,3.0,0.1, :blue)
const plotelementparameters_segment=       (:none,  :red,0.3,3.0,0.1, :blue)
const plotelementparameters_plane=         (:none,  :red,0.3,3.0,0.1, :green)
const plotelementparameters_planenode=     (:circle,:red,0.3,3.0,0.1, :green)
const plotelementparameters_invisiblenode= (:cross, :red,0.0,0.0,0.0, :blue)
const defaultplotscheme = PlotScheme(plotelementparameters_node,
                              plotelementparameters_segment,
                              plotelementparameters_plane,
                              plotelementparameters_planenode,
                              plotelementparameters_invisiblenode)

function Base.push!(pd::PlotData, xyz::Array{Float64,1})
  push!(pd.x, xyz[1])
  push!(pd.x, xyz[2])
  push!(pd.x, xyz[3])
  return nothing
end

function Base.push!(pd::PlotData, pep::PlotElementParameters)
  push!(pd.marker,            pep.marker)
  push!(pd.markercolor,       pep.markercolor)
  push!(pd.markeralpha,       pep.markeralpha)
  push!(pd.markersize,        pep.markersize)
  push!(pd.markerstrokewidth, pep.markerstrokewidth)
  push!(pd.linecolor,         pep.linecolor)
  return nothing
end

function pushgroupcounter!(pd::PlotData; incerment::Int=0)
  pd.groupcounter +=  incerment
  push!(pd.group,pd.groupcounter)
  return nothing
end

# push! a group with a single marker into PlotData
function pushmarkergroup!(pd::PlotData,
                          xyz::Array{Float64,1},
                          pep::PlotElementParameters)
  pushgroupcounter!(pd, incerment=1)
  push!(pd,xyz)
  push!(pd,pep)
  return nothing
end

# force same scale on all axis with invisible markers in corners
function pointsatlimits!(pd::PlotData, ps::PlotScheme)
  xlims = [minimum(pd.x) maximum(pd.x)]
  ylims = [minimum(pd.y) maximum(pd.y)]
  zlims = [minimum(pd.z) maximum(pd.z)]
  xcenter = (xlims[1]+xlims[2])/2.0
  ycenter = (ylims[1]+ylims[2])/2.0
  zcenter = (zlims[1]+zlims[2])/2.0
  range = maximum([xlims[2]-xlims[1] ylims[2]-ylims[1] zlims[2]-zlims[1]])
  pushmarkergroup!(pd,
                  [xcenter+range/2.0,ycenter+range/2.0,zcenter+range/2.0],
                  ps.invisiblenode)
  pushmarkergroup!(pd,
                  [xcenter-range/2.0,ycenter-range/2.0,zcenter-range/2.0],
                  ps.invisiblenode)
end

function plot(e::Element, ps::PlotScheme = defaultplotscheme)
  pd = plotdata(e,ps)
  pointsatlimits!(pd,ps)
  plot(pd.x, pd.y, pd.z, group=pd.group,
    title = pd.title,
    legend = false,
    linecolor = transpose(pd.linecolor),
    marker=transpose(pd.marker),
    markercolor = transpose(pd.markercolor),
    markeralpha = transpose(pd.markeralpha),
    markersize = transpose(pd.markersize),
    markerstrokewidth = transpose(pd.markerstrokewidth))
end

function plotdata(element::Element,ps::PlotScheme)
  pd = PlotData()
  pd.title = ""  # need to fix later
  pd.groupcounter = 0
  cd = contextdict(element)
  for e in element
    appendplotdata!(pd,e,cd)
  end
  return pd
end

appendplotdata!(::PlotData, ::Element, ::Dict{Element,Context}, ::PlotScheme)
  = nothing
function appendplotdata!(pd::PlotData,
                         element::Node,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  return nothing
end
function appendplotdata!(pd::PlotData,
                         element::Segment,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  return nothing
end
function appendplotdata!(pd::PlotData,
                         element::UniformPlane,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  return nothing
end
function appendplotdata!(pd::PlotData,
                         corners::Array{Float64,2},
                         ps::PlotScheme)
  return nothing
end

function corners(element::Segment, cd::Dict{Element,Context})
end
function corners(element::Uniformplane, cd::Dict{Element,Context})
end
