struct ElementContext
  default :: Default
  units :: Units
  autoname :: Int
end
ElementContext() = ElementContext(Default(), Units(), 0)

const ContextDict = Dict{Element,ElementContext}

struct Context
  dict :: ContextDict
  firstunits :: Units
  title :: String
end
function Context(element::Element)
  recursioncheck(element)
  Context(contextdict(element),firstunits(element),title(element))
end

const NamedElements = Union{Node,Segment,UniformPlane}

function firstunits(element::Element)
  result = Units()
  for e in traverseTree(element)
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
  previouselementcontext = ElementContext()
  for e in traverseTree(element)
    previouselementcontext = appendelementcontext!(cd,previouselementcontext,e)
  end
  return cd
end

function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::Default)
  newelementcontext = ElementContext(x, pec.units, pec.autoname)
  cd[x] = newelementcontext
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::Units)
  newelementcontext = ElementContext(pec.default, x, pec.autoname)
end
function appendelementcontext_!(cd::ContextDict, pec::ElementContext, x::NamedElements)
  if ~haskey(cd,x)
    if x.name == Symbol("")
      newelementcontext = ElementContext(pec.default, pec.units, pec.autoname+1)
    else
      newelementcontext = pec
    end
    cd[x] = newelementcontext
    return newelementcontext
  else
    return pec
  end
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::Node)
  appendelementcontext_!(cd,pec,x)
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::Segment)
  pec = appendelementcontext_!(cd,pec,x)
  pec = appendelementcontext_!(cd,pec,x.node1)
  pec = appendelementcontext_!(cd,pec,x.node2)# store default wxyz here?
  if x.wxwywz.isdefault
    node1_xyz1 = x.node1.xyz1
    node2_xyz1 = x.node2.xyz1 * segmentnodescaleratio(x,cd)
    v1 = node1_xyz1[1:3] - node2_xyz1[1:3]
    normalize!(v1)
    v2 = [0.0, 0.0, 1.0]
    w = cross(v1,v2)
    if norm(w) < 1e-10  # close to 0
      v2 = [0.0, 1.0, 0.0]
      w = cross(v1,v2)
    end
    x.wxwywz.xyz[1:3] = normalize(w)
  end
  return pec
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::UniformPlane)
  pec = appendelementcontext_!(cd,pec,x)
  for node in x.nodes
    pec = appendelementcontext_!(cd,pec,node)
  end
  pec
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::Equiv)
  for node in x.nodes
    pec = appendelementcontext_!(cd,pec,node)
  end
  pec
end
function appendelementcontext!(cd::ContextDict, pec::ElementContext, x::External)
  pec = appendelementcontext_!(cd,pec,x.node1)
  pec = appendelementcontext_!(cd,pec,x.node2)
end
appendelementcontext!(::ContextDict, pec::ElementContext, ::Element) = pec

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
  result = Array{Float64}(undef,4)
  result[1:3] = node.xyz1[1:3]*scale
  result[4] = 1.0
  return result
end

function xyz1(node::Node, context::Context)
  scale = scaletofirstunits(node,context)
  xyz1(node, scale)
end
function segmentnodescaleratio(segment::Segment, cd::ContextDict)
  if haskey(cd,segment.node1)
    scale1 = tometers[cd[segment.node1].units.unitname]
  else
    scale1 = tometers[cd[segment].units.unitname]
  end
  if haskey(cd,segment.node2)
    scale2 = tometers[cd[segment.node2].units.unitname]
  else
    scale2 = tometers[cd[segment].units.unitname]
  end
  return scale2/scale1
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

#wxyz(segment::Segment, ::Context) = segment.wxwywz.xyz
# todo: wxyz should return a normalized vector perp to length vector in context
# just a warning?
# todoing...

function wxyz(segment::Segment, context::Context)
  wxyz_ = segment.wxwywz.xyz
  if ~segment.wxwywz.isdefault
    (n1,n2) = nodes_xyz1(segment,context)
    lxyz = n2[1:3] - n1[1:3]
    if dot(lxyz,segment.wxwywz.xyz)>1e-9
      wxyz_ = cross(cross(lxyz,segment.wxwywz.xyz),lxyz)
      normalize!(wxyz_)
      @warn "wx,wy,wz not perpendicular to segment length" is=segment.wxwywz.xyz should_be=wxyz_
    end
  end
  return wxyz_
end


function corners_xyz1_thick(uniformplane::UniformPlane, context::Context)
  scale = scaletofirstunits(uniformplane,context)
  c1 = Array{Float64}(undef,4)
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
  if length(uniformplane.nodes)!=0
    scale = scaletofirstunits(uniformplane,context)
  end
  f(i) = xyz1(uniformplane.nodes[i],scale) #plane nodes should not be in context
  ntuple(f, length(uniformplane.nodes))
end

function title(e1::Element)
  for e2 in traverseTree(e1)
    return title_(e2)
  end
  return ""
end
title_(::Element) = ""
title_(x::Comment) = x.text

recursioncheck(element::Element) = recursioncheck!(element, Dict{Group,Group}())
recursioncheck!(::Element,::Dict{Group,Group}) = nothing
function recursioncheck!(group::Group, recursioncheckdict::Dict{Group,Group})
  if haskey(recursioncheckdict,group)
    throw(ErrorException("recursion not allowed"))
  end
  recursioncheckdict[group] = group
  for element in group.elements
    recursioncheck!(element, recursioncheckdict)
  end
  delete!(recursioncheckdict, group)
  return nothing
end
