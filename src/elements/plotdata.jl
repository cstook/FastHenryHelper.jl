import Plots: plot

type PlotData
  title :: AbstractString
  x :: Array{Float64,1}
  y :: Array{Float64,1}
  z :: Array{Float64,1}
  group :: Array{Int,1}
  default_h :: Float64
  default_w :: Float64
  marker :: Array{Symbol,1}
  markercolor :: Array{Symbol,1}
  markeralpha :: Array{Float64,1}
  markersize :: Array{Float64,1}
  markerstrokewidth :: Array{Float64,1}
  groupcounter :: Int
  PlotData() = new("",[],[],[],[],NaN,NaN,[],[],[],[],[],0)
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
    linecolor = :blue,
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
  # mode segments into pd
  for segmentdata in vd.segmentdataarray
    push!(pd, segmentdata)
  end
  return pd
end

function Base.push!(pd::PlotData, nodedata::NodeData)
  pd.groupcounter += 1
  push!(pd.group,pd.groupcounter)
  push!(pd.marker,:circle)
  push!(pd.markercolor, :red)
  push!(pd.markeralpha, 0.3)
  push!(pd.markersize, 3.0)
  push!(pd.markerstrokewidth, 0.1)
  push!(pd.x, nodedata.xyz[1])
  push!(pd.y, nodedata.xyz[2])
  push!(pd.z, nodedata.xyz[3])
  return nothing
end

function Base.push!(pd::PlotData, segmentdata::SegmentData)
  c = corners(pd,segmentdata)
  t = [(1,2,3,4,1,5,6,7,8,5),(2,6),(3,7),(4,8)]
  for g in t
    pd.groupcounter += 1
    push!(pd.marker,:none)
    push!(pd.markercolor, :red)
    push!(pd.markeralpha, 0.3)
    push!(pd.markersize, 1.0)
    push!(pd.markerstrokewidth, 0.1)
    for p in g
      push!(pd.group,pd.groupcounter)
      push!(pd.x,c[1,p])
      push!(pd.y,c[2,p])
      push!(pd.z,c[3,p])
    end
  end
  return nothing
end

function corners(pd::PlotData, s::SegmentData)
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



#=


function plotdata(e::Element)
  pd = PlotData()
  plotdata!(pd,e)
  return pd
end

function plotdata!(pd::PlotData, d::Default)
  pd.default_w = d.wh.w
  pd.default_h = d.wh.h
  return nothing
end

function plotdata!(pd::PlotData, group::Group)
  for i in eachindex(group.elements)
    plotdata!(pd,group.elements[i])
  end
  return nothing
end

function plotdata!(pd::PlotData, n::Node)
  pd.groupcounter += 1
  push!(pd.group,pd.groupcounter)
  push!(pd.marker,:circle)
  push!(pd.markercolor, :red)
  push!(pd.markeralpha, 0.3)
  push!(pd.markersize, 3.0)
  push!(pd.markerstrokewidth, 0.1)
  push!(pd.x, n.xyz[1])
  push!(pd.y, n.xyz[2])
  push!(pd.z, n.xyz[3])
  return nothing
end

function corners(pd::PlotData, s::Segment)
  w = isnan(s.wh.w) ? pd.default_w : s.wh.w
  h = isnan(s.wh.h) ? pd.default_h : s.wh.h
  p1 = xyz(s.node1)
  p2 = xyz(s.node2)
  wxyz = s.wxwywz.xyz
  mp1 = p1+(wxyz.*w/2)
  mp2 = p1-(wxyz.*w/2)
  mp3 = p2+(wxyz.*w/2)
  mp4 = p2-(wxyz.*w/2)
  hxyz = cross(wxyz,(p2-p1))
  hxyz = hxyz/norm(hxyz,3)
  result = Array(Float64,(3,8))
  result[:,1] = mp1+(hxyz.*h/2)
  result[:,2] = mp1-(hxyz.*h/2)
  result[:,3] = mp2-(hxyz.*h/2)
  result[:,4] = mp2+(hxyz.*h/2)
  result[:,5] = mp3+(hxyz.*h/2)
  result[:,6] = mp3-(hxyz.*h/2)
  result[:,7] = mp4-(hxyz.*h/2)
  result[:,8] = mp4+(hxyz.*h/2)
  return result
end

function plotdata!(pd::PlotData, seg::Segment)
  c = corners(pd,seg)
  t = [(1,2,3,4,1,5,6,7,8,5),(2,6),(3,7),(4,8)]
  for g in t
    pd.groupcounter += 1
    push!(pd.marker,:none)
    push!(pd.markercolor, :red)
    push!(pd.markeralpha, 0.3)
    push!(pd.markersize, 1.0)
    push!(pd.markerstrokewidth, 0.1)
    for p in g
      push!(pd.group,pd.groupcounter)
      push!(pd.x,c[1,p])
      push!(pd.y,c[2,p])
      push!(pd.z,c[3,p])
    end
  end
  return nothing
end

function plotdata!(pd::PlotData, title::Title)
  if length(pd.title) == 0
    pd.title = title.text
  end
  return nothing
end
=#
