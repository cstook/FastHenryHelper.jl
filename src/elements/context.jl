immutable ElementContext
  default :: Default
  units :: Units
  autoname :: Int
end
ElementContext() = ElementContext(Default(), Units(), 0)

typealias ContextDict Dict{Element,ElementContext}

immutable Context
  dict :: ContextDict
  firstunits :: Units
  title :: ASCIIString
end
Context(element::Element) = Context(
                              contextdict(element),
                              firstunits(element),
                              title(element))

function firstunits(element::Element)
  result = Units()
  for e in element
    if firstunits_(e) != nothing
      result =  firstunits_(e)
      break
    end
  end
  return result
end
firstunits_(::Element) = nothing
firstunits_(units::Units) = units

function contextdict(element::Element)
  cd = ContextDict()
  ec = ElementContext()
  for e in element
    ec = elementcontext(ec,e)
    cd[e] = ec
  end
  return cd
end

function elementcontext(ec::ElementContext, x::Default)
  ElementContext(x, ec.units, ec.autoname)
end
function elementcontext(ec::ElementContext, x::Units)
  ElementContext(ec.default, x, ec.autoname)
end
function elementcontext(ec::ElementContext, x::Union{Node,Segment,UniformPlane})
  if x.name == Symbol("")
    return ElementContext(ec.default, ec.units, ec.autoname+1)
  else
    return ec
  end
end
elementcontext(ec::ElementContext, ::Element) = ec

# methods using Context return values in the first unit of their group

const tometers = Dict("km"  =>1e3,
                      "m"   =>1.0,
                      "cm"  =>1e-2,
                      "mm"  =>1e-3,
                      "um"  =>1e-6,
                      "in"  =>2.54e-2,
                      "mils"=>2.54e-5,
                      ""    =>1.0)  # meters is default

function scaletofirstunits(x::Element, context::Context)
  tometers[context.dict[x].units.unitname] /
    tometers[context.firstunits.unitname]
end

function xyz1(node::Node, scale::Float64)
  result = Array(Float64,4)
  result[1:3] = node.xyz[1:3]*scale
  result[4] = 1
  return result
end

function xyz1(node::Node, context::Context)
  scale = scaletofirstunits(node,context)
  xyz1(node, scale)
end

function nodes_xyz1(segment::Segment, context::Context)
  scale = scaletofirstunits(segment,context)
  if haskey(context.dict,segment.node1)
    node1_xyz1 = xyz1(segment.node1,context)
  else
    node1_xyz1 = xyz1(segment.node1,scale)
  end
  if haskey(context.dict,segment.node2)
    node2_xyz1 = xyz1(segment.node2,context)
  else
    node2_xyz1 = xyz1(segment.node2,scale)
  end
  return (node1_xyz1, node2_xyz1)
end

function width_height(segment::Segment, context::Context)
  scale = scaletofirstunits(segment,context)
  if isnan(segment.wh.w) || isnan(segment.wh.h)
    scaledefault = scaletofirstunits(context.dict[segment].default,context)
  end
  if isnan(segment.wh.w)
    width = context.dict[segment].default.wh.w * scaledefault
  else
    width = segment.wh.w * scale
  end
  if isnan(segment.wh.h)
    height = context.dict[segment].default.wh.h * scaledefault
  else
    height = segment.wh.h * scale
  end
  return (width, height)
end

function wxyz(segment::Segment, context::Context)
  if segment.wxwywz.isdefault
    (node1_xyz1, node2_xyz1) = nodes_xyz1(segment, context)
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

function corners_xyz1_thick(uniformplane::UniformPlane, context::Context)
  scale = scaletofirstunits(uniformplane,context)
  c1 = Array(Float64,4)
  c2 = similar(c1)
  c3 = similar(c1)
  c1[1:3] = uniformplane.corner1[1:3] * scale
  c2[1:3] = uniformplane.corner2[1:3] * scale
  c3[1:3] = uniformplane.corner3[1:3] * scale
  c1[4] = 1.0
  c2[4] = 1.0
  c3[4] = 1.0
  thick = uniformplane.thick * scale
  (c1,c2,c3,thick)
end

function nodes_xyz1(uniformplane::UniformPlane, context::Context)
  scale = scaletofirstunits(uniformplane,context)
  f(i) = xyz1(uniformplane.nodes[i],scale) #plane nodes should not be in context
  ntuple(f, length(uniformplane.nodes))
end

function title(element::Element)
  state = start(element)
  if ~done(element,state)
    (e,state) = next(element, state)
    return title_(e)
  else
    return ""
  end
end
title_(::Element) = ""
title_(x::Title) = x.text
