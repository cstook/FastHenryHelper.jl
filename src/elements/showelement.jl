type AutoName
  namedict :: Dict{Element,Symbol}
  namecounter :: Int
  AutoName() =new(Dict(),0)
end

function Base.show(io::IO, element::Element)
  autoname = AutoName()
  for e in element
    show(io,e,autoname=autoname)
  end
end

function update!(autoname :: AutoName, e::Element)
  if ~haskey(autoname.namedict,e)
    if e.name == Symbol("")
      autoname.namecounter += 1
      autoname.namedict[e] = Symbol("_$(autoname.namecounter)")
    else
      autoname.namedict[e] = e.name
    end
  end
end
