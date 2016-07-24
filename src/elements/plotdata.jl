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

plotdata!(::PlotData, ::Element) = nothing

function pointsatlimits!(pd::PlotData)
  xlims = [minimum(pd.x) maximum(pd.x)]
  ylims = [minimum(pd.y) maximum(pd.y)]
  zlims = [minimum(pd.z) maximum(pd.z)]
  xcenter = (xlims[1]+xlims[2])/2.0
  ycenter = (ylims[1]+ylims[2])/2.0
  zcenter = (zlims[1]+zlims[2])/2.0
  range = maximum([xlims[2]-xlims[1] ylims[2]-ylims[1] zlims[2]-zlims[1]])
  pd.groupcounter +=1
  push!(pd.group, pd.groupcounter)
  push!(pd.marker, :cross)
  push!(pd.markercolor, :red)
  push!(pd.markeralpha, 0.0)
  push!(pd.markersize, 0.0)
  push!(pd.markerstrokewidth, 0.0)
  push!(pd.linecolor, :blue)            # line color
  push!(pd.x, xcenter+range/2.0)
  push!(pd.y, ycenter+range/2.0)
  push!(pd.z, zcenter+range/2.0)
  pd.groupcounter +=1
  push!(pd.group, pd.groupcounter)
  push!(pd.marker, :cross)
  push!(pd.markercolor, :red)
  push!(pd.markeralpha, 0.0)
  push!(pd.markersize, 0.0)
  push!(pd.markerstrokewidth, 0.0)
  push!(pd.linecolor, :blue)            # line color
  push!(pd.x, xcenter-range/2.0)
  push!(pd.y, ycenter-range/2.0)
  push!(pd.z, zcenter-range/2.0)
end

function plot(e::Element)
  pd = PlotData(e)
  # pointsatlimits!
  # attempts to force xlims = ylims = zlims
  pointsatlimits!(pd)
  plot(pd.x, pd.y, pd.z, group=pd.group,
    title = pd.title,
    legend = false,
    linecolor = transpose(pd.linecolor),                # line color
    marker=transpose(pd.marker),
    markercolor = transpose(pd.markercolor),
    markeralpha = transpose(pd.markeralpha),
    markersize = transpose(pd.markersize),
    markerstrokewidth = transpose(pd.markerstrokewidth))
end

function PlotData(e::Element)
  pd = PlotData()
  vd = VisualizeData(e)
  todisplayunit!(vd)
  pd.title = vd.title
  pd.groupcounter = 0
  # move nodes into pd
  for nodedata in vd.nodedataarray
    push!(pd,nodedata)
  end
  # move segments into pd
  for segmentdata in vd.segmentdataarray
    push!(pd, segmentdata)
  end
  # move planes into pd
  for planedata in vd.planedataarray
    push!(pd, planedata)
  end
  return pd
end

function Base.push!(pd::PlotData, nodedata::NodeData; markercolor = :red)
  push!(pd, nodedata.xyz, markercolor=markercolor)
  return nothing
end

function Base.push!(pd::PlotData, xyz::Array{Float64,1}; markercolor = :red)
  pd.groupcounter += 1
  push!(pd.group,pd.groupcounter)
  push!(pd.marker,:circle)
  push!(pd.markercolor, markercolor)
  push!(pd.markeralpha, 0.3)
  push!(pd.markersize, 3.0)
  push!(pd.markerstrokewidth, 0.1)
  push!(pd.linecolor, :blue)            # line color
  push!(pd.x, xyz[1])
  push!(pd.y, xyz[2])
  push!(pd.z, xyz[3])
  return nothing
end

linecolor(::SegmentData) = :blue
linecolor(::PlaneData) = :green

function Base.push!(pd::PlotData, data::Union{SegmentData,PlaneData})
  c = corners(data)
  t = [(1,2,3,4,1,5,6,7,8,5),(2,6),(3,7),(4,8)]
  for g in t
    pd.groupcounter += 1
    push!(pd.marker,:none)
    push!(pd.markercolor, :red)
    push!(pd.markeralpha, 0.3)
    push!(pd.markersize, 1.0)
    push!(pd.markerstrokewidth, 0.1)
    push!(pd.linecolor, linecolor(data))            # line color
    for p in g
      push!(pd.group,pd.groupcounter)
      push!(pd.x,c[1,p])
      push!(pd.y,c[2,p])
      push!(pd.z,c[3,p])
    end
  end
  addplanenodes(pd,data)
  return nothing
end

addplanenodes(::PlotData, ::SegmentData) = nothing
function addplanenodes(pd::PlotData, planedata::PlaneData)
  for i in 1:size(node_xyz(planedata))[2]
    push!(pd, node_xyz(planedata)[:,i], markercolor=:green)
  end
  return nothing
end

function corners(p::PlaneData)
  htp = halfthickperp(p)
  c = Array(Float64,(3,8))
  c4 = wxyz(p) + c1(p)
  c[:,1] = c1(p) - htp
  c[:,2] = c2(p) - htp
  c[:,3] = c3(p) - htp
  c[:,4] = c4 - htp
  c[:,5] = c1(p) + htp
  c[:,6] = c2(p) + htp
  c[:,7] = c3(p) + htp
  c[:,8] = c4 + htp
  return c
end

function corners(s::SegmentData)
  mp1 = s.n1xyz+(s.wxyz.*s.width/2)
  mp2 = s.n1xyz-(s.wxyz.*s.width/2)
  mp3 = s.n2xyz+(s.wxyz.*s.width/2)
  mp4 = s.n2xyz-(s.wxyz.*s.width/2)
  hxyz = cross(s.wxyz,(s.n2xyz-s.n1xyz))
  hxyz = hxyz/norm(hxyz,3)
  result = Array(Float64,(3,8))
  result[:,1] = mp1+(hxyz.*s.height/2)
  result[:,2] = mp1-(hxyz.*s.height/2)
  result[:,3] = mp2-(hxyz.*s.height/2)
  result[:,4] = mp2+(hxyz.*s.height/2)
  result[:,5] = mp3+(hxyz.*s.height/2)
  result[:,6] = mp3-(hxyz.*s.height/2)
  result[:,7] = mp4-(hxyz.*s.height/2)
  result[:,8] = mp4+(hxyz.*s.height/2)
  return result
end
