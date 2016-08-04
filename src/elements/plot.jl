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
const plotelementparameters_node=
  PlotElementParameters(:circle,:red,0.3,3.0,0.1, :blue)
const plotelementparameters_segment=
  PlotElementParameters(:none,  :red,0.3,3.0,0.1, :blue)
const plotelementparameters_plane=
  PlotElementParameters(:none,  :red,0.3,3.0,0.1, :green)
const plotelementparameters_planenode=
  PlotElementParameters(:circle,:red,0.3,3.0,0.1, :green)
const plotelementparameters_invisiblenode=
  PlotElementParameters(:cross, :red,0.0,0.0,0.0, :blue)
const defaultplotscheme = PlotScheme(plotelementparameters_node,
                              plotelementparameters_segment,
                              plotelementparameters_plane,
                              plotelementparameters_planenode,
                              plotelementparameters_invisiblenode)

function Base.push!(pd::PlotData, xyz::Array{Float64,1})
  push!(pd.x, xyz[1])
  push!(pd.y, xyz[2])
  push!(pd.z, xyz[3])
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

function plotdata(element::Element,ps::PlotScheme = defaultplotscheme)
  pd = PlotData()
  pd.title = title(element)
  pd.groupcounter = 0
  cd = contextdict(element)
  for e in element
    appendplotdata!(pd,e,cd,ps)
  end
  return pd
end

appendplotdata!(::PlotData, ::Element, ::Dict{Element,Context}, ::PlotScheme) =
  nothing
function appendplotdata!(pd::PlotData,
                         node::Node,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  pushmarkergroup!(pd, xyz1(node,cd), ps.node)
  return nothing
end
function appendplotdata!(pd::PlotData,
                         segment::Segment,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  appendplotdata!(pd, corners(segment,cd), ps.segment)
  return nothing
end
function appendplotdata!(pd::PlotData,
                         plane::UniformPlane,
                         cd::Dict{Element,Context},
                         ps::PlotScheme)
  appendplotdata!(pd, corners(plane,cd), ps.plane)
  pep = ps.planenode
  for xyz1 in nodes_xyz1(plane,cd)
    pushmarkergroup!(pd, xyz1, pep)
  end
  return nothing
end
function appendplotdata!(pd::PlotData,
                         corners::Array{Float64,2},
                         pep::PlotElementParameters)
  t = [(1,2,3,4,1,5,6,7,8,5),(2,6),(3,7),(4,8)]
  for g in t
    pd.groupcounter += 1
    push!(pd,pep)
    for p in g
      push!(pd.group,pd.groupcounter)
      push!(pd,corners[:,p])
    end
  end
  return nothing
end

function corners(segment::Segment, cd::Dict{Element,Context})
  (w,h) = width_height(segment,cd)
  (n1_xyz1,n2_xyz1) = nodes_xyz1(segment,cd)
  n1_xyz = n1_xyz1[1:3]
  n2_xyz = n2_xyz1[1:3]
  widthvector = wxyz(segment,cd)
  widthvector = widthvector / norm(widthvector,3)
  mp1 = n1_xyz+(widthvector.*w/2)
  mp2 = n1_xyz-(widthvector.*w/2)
  mp3 = n2_xyz+(widthvector.*w/2)
  mp4 = n2_xyz-(widthvector.*w/2)
  lengthvector = n2_xyz-n1_xyz
  heightvector = cross(widthvector,lengthvector)
  heightvector = heightvector/norm(heightvector,3)
  c = Array(Float64,(3,8))
  c[:,1] = mp1+(heightvector.*h/2)
  c[:,2] = mp1-(heightvector.*h/2)
  c[:,3] = mp2-(heightvector.*h/2)
  c[:,4] = mp2+(heightvector.*h/2)
  c[:,5] = mp3+(heightvector.*h/2)
  c[:,6] = mp3-(heightvector.*h/2)
  c[:,7] = mp4-(heightvector.*h/2)
  c[:,8] = mp4+(heightvector.*h/2)
  return c
end
function corners(plane::UniformPlane, cd::Dict{Element,Context})
  (c1,c2,c3,thick) = corners_xyz1_thick(plane,cd)
  widthvector = c3[1:3] - c2[1:3]
  lengthvector = c1[1:3] - c2[1:3]
  perpvector = cross(widthvector,lengthvector)
  halfthickperpvector = perpvector * (0.5*thick/norm(perpvector,3))
  c = Array(Float64,(3,8))
  c4 = widthvector + c1[1:3]
  c[:,1] = c1[1:3] - halfthickperpvector
  c[:,2] = c2[1:3] - halfthickperpvector
  c[:,3] = c3[1:3] - halfthickperpvector
  c[:,4] = c4 - halfthickperpvector
  c[:,5] = c1[1:3] + halfthickperpvector
  c[:,6] = c2[1:3] + halfthickperpvector
  c[:,7] = c3[1:3] + halfthickperpvector
  c[:,8] = c4 + halfthickperpvector
  return c
end
