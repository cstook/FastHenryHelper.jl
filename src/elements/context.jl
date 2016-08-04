export contextdict

immutable Context
  default :: Default
  units :: Units
  autoname :: Int
  firstunits :: Units
end
Context() = Context(Default(), Units("m"), 0, Units())

function contextdict(element::Element)
  cd = Dict{Element,Context}()
  c = Context()
  for e in element
    c = context(c,e)
    cd[e] = c
  end
  return cd
end

function context(c::Context, x::Default)
  Context(x, c.units, c.autoname, c.firstunits)
end
function context(c::Context, x::Units)
  if c.firstunits == Units()
    Context(c.default, x, c.autoname, x)
  else
    Context(c.default, x, c.autoname, c.firstunits)
  end
end
function context(c::Context, x::Union{Node,Segment,UniformPlane})
  if x.name == Symbol("")
    return Context(c.default, c.units, c.autoname+1 , c.firstunits)
  else
    return c
  end
end
context(c::Context, ::Element) = c

# methods using Context return values in the first unit of their group

const tometers = Dict("km"  =>1e3,
                      "m"   =>1.0,
                      "cm"  =>1e-2,
                      "mm"  =>1e-3,
                      "um"  =>1e-6,
                      "in"  =>2.54e-2,
                      "mils"=>2.54e-5,
                      ""    =>1.0)

function scaletofirstunits(x::Element, cd::Dict{Element,Context})
  tometers[cd[x].units.unitname] / tometers[cd[x].firstunits.unitname]
end

function xyz1(node::Node, scale::Float64)
  result = Array(Float64,4)
  result[1:3] = node.xyz[1:3]*scale
  result[4] = 1
  return result
end

function xyz1(node::Node, cd::Dict{Element,Context})
  scale = scaletofirstunits(node,cd)
  xyz1(node, scale)
end

function nodes_xyz1(segment::Segment, cd::Dict{Element,Context})
  scale = scaletofirstunits(segment,cd)
  if haskey(cd,segment.node1)
    node1_xyz1 = xyz1(segment.node1,cd)
  else
    node1_xyz1 = xyz1(segment.node1,scale)
  end
  if haskey(cd,segment.node2)
    node2_xyz1 = xyz1(segment.node2,cd)
  else
    node2_xyz1 = xyz1(segment.node2,scale)
  end
  return (node1_xyz1, node2_xyz1)
end

function width_height(segment::Segment, cd::Dict{Element,Context})
  scale = scaletofirstunits(segment,cd)
  if isnan(segment.wh.w) || isnan(segment.wh.h)
    scaledefault = scaletofirstunits(cd[segment].default,cd)
  end
  if isnan(segment.wh.w)
    width = cd[segment].default.wh.w * scaledefault
  else
    width = segment.wh.w * scale
  end
  if isnan(segment.wh.h)
    height = cd[segment].default.wh.h * scaledefault
  else
    height = segment.wh.h * scale
  end
  return (width, height)
end

function wxyz(segment::Segment, cd::Dict{Element,Context})
  if segment.wxwywz.isdefault
    (node1_xyz1, node2_xyz1) = nodes_xyz1(segment, cd)
    v1 = node1_xyz1[1:3] - node2_xyz1[1:3]
    v2 = [0.0, 0.0, 1.0]
    w = cross(v1,v2)
    if norm(w) < 1e-10  # close to 0
      v2 = [0.0, 1.0, 0.0]
      w = cross(v1,v2)
    end
    return (w/norm(w,3))
  else
    return segment.wxwywz.xyz
  end
end

function corners_xyz1_thick(uniformplane::UniformPlane, cd::Dict{Element,Context})
  scale = scaletofirstunits(uniformplane,cd)
  c1 = Array(Float64,4)
  c2 = similar(c1)
  c3 = similar(c1)
  c1[1:3] = uniformplane.corner1[1:3] * scale
  c2[1:3] = uniformplane.corner2[1:3] * scale
  c3[1:3] = uniformplane.corner3[1:3] * scale
  thick = uniformplane.thick * scale
  (c1,c2,c3,thick)
end

function nodes_xyz1(uniformplane::UniformPlane, cd::Dict{Element,Context})
  scale = scaletofirstunits(uniformplane,cd)
  f(i) = xyz1(uniformplane.nodes[i],scale) #plane nodes should not be in cd
  ntuple(f, length(uniformplane.nodes))
end

function title(element::Element)
  state = start(element)
  (e,state) = next(element, state)
  title_(e)
end
title_(::Element) = ""
title_(x::Title) = x.text
