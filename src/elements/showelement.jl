name(::Element, ::Context) = nothing
function name(x::NamedElements, context::Context)
  if x.name == Symbol("")
    nameincontext = Symbol("_"*string(context.dict[x].autoname))
  else
    nameincontext = x.name
  end
  return nameincontext
end

function Base.show(io::IO, element::Element)
  context = Context(element)
  for e in element
    show(io, e, context)
  end
end

function Base.show(io::IO, n::Node, context::Context; plane = false)
  if plane
    print(io,"+ ")
  end
  print(io, "N")
  print(io, name(n,context), " ")
  if plane
    @printf(io,"(%.9e,%.9e,%.9e)",n.xyz[1],n.xyz[2],n.xyz[3])
  else
    @printf(io,"x=%.9e y=%.9e z=%.9e",n.xyz[1],n.xyz[2],n.xyz[3])
  end
  println(io)
  return nothing
end

function Base.show(io::IO, s::Segment, context::Context)
  print(io,"E")
  print(io, name(s,context))
  print(io," N", name(s.node1,context))
  println(io," N", name(s.node2,context))
  show(io, s.wh)
  show(io, s.sigmarho)
  show(io, s.wxwywz)
  return nothing
end

function Base.show(io::IO ,x::UniformPlane, context::Context)
  print(io,"G")
  println(io,name(x,context))
  @printf(io,"+ x1=%.9e",x.corner1[1])
  @printf(io," y1=%.9e",x.corner1[2])
  @printf(io," z1=%.9e\n",x.corner1[3])
  @printf(io,"+ x2=%.9e",x.corner2[1])
  @printf(io," y2=%.9e",x.corner2[2])
  @printf(io," z2=%.9e\n",x.corner2[3])
  @printf(io,"+ x3=%.9e",x.corner3[1])
  @printf(io," y3=%.9e",x.corner3[2])
  @printf(io," z3=%.9e\n",x.corner3[3])
  @printf(io,"+ thick=%.9e",x.thick)
  print(io," seg1=",x.seg1)
  println(io," seg2=",x.seg2)
  if ~isnan(x.segwid1)
    @printf(io,"+ segwid1=%.9e\n",x.segwid1)
  end
  if ~isnan(x.segwid2)
    @printf(io,"+ segwid2=%.9e\n",x.segwid2)
  end
  if ~isnan(x.sigma)
    @printf(io,"+ sigma=%.9e\n",x.sigma)
  end
  if ~isnan(x.rho)
    @printf(io,"+ rho=%.9e\n",x.rho)
  end
  if x.nhinc>0
    println(io,"+ nhinc=",x.nhinc)
  end
  if x.rh>0
    println(io,"+ rh=",x.rh)
  end
  if ~isnan(x.relx)
    @printf(io,"+ relx=%.9e\n",x.relx)
  end
  if ~isnan(x.rely)
    @printf(io,"+ rely=%.9e\n",x.rely)
  end
  if ~isnan(x.relz)
    @printf(io,"+ relz=%.9e\n",x.relz)
  end
  for node in x.nodes
    show(io,node, autoname=autoname, plane=true)
  end
  for hole in x.holes
    show(io,hole)
  end
  return nothing
end

function Base.show(io::IO, x::External, context::Context)
  print(io, ".external N")
  print(io, name(x.node1,context))
  print(io," N")
  print(io, name(x.node2,context))
  println(io," ",x.portname)
  return nothing
end

function Base.show(io::IO, x::Equiv, context::Context)
  print(io,".equiv")
  for node in x.nodes
    print(io," N",name(node))
  end
  println(io)
  return nothing
end

function Base.show(io::IO, x::Comment, ::Context)
  println(io,"* ",x.text)
end

function Base.show(io::IO, x::Default, ::Context)
  println(io,".default")
  show(io, x.wh)
  show(io, x.sigmarho)
end

function Base.show(io::IO, ::End, ::Context)
  println(io,".end")
end

function Base.show(io::IO, x::Freq, ::Context)
  @printf(io,".freq fmin=%.9e fmax=%.9e",x.min,x.max)
  if ~isnan(x.ndec)
    @printf(io," ndec=%.9e",x.ndec)
  end
  println(io)
  return nothing
end

function Base.show(io::IO, title::Title, ::Context)
  println(io,"* ",title.text)
end

function Base.show(io::IO, x::Units, ::Context)
  println(io,".units ",x.unitname)
  return nothing
end
