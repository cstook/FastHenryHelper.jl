export coilcraft1010vsgroup

function coilcraft1010vsgroup(partnumber::String; nhinc=0, nwinc=0, rh=NaN, rw=NaN)
  # Assumes units = mm !!!
  pndict = Dict("1010VS-23NME" => (3.55, 0.65, 1.5*2π),
                "1010VS-46NME" => (3.55, 0.65, 2.5*2π),
                "1010VS-79NME" => (3.55, 0.65, 3.5*2π),
                "1010VS-111ME" => (3.55, 0.65, 4.5*2π),
                "1010VS-141ME" => (3.55, 0.65, 5.5*2π))
  hn = helixnodes(pndict[partnumber]...)
  transform!(hn,txyz(0,0,2.025))
  b1 = Node(xyz(hn[1])[1], -xyz(hn[1])[1], xyz(hn[1])[3])
  b2 = Node(xyz(hn[1])[1], -xyz(hn[1])[1], 0.325)
  b3 = Node(xyz(hn[1])[1], xyz(hn[1])[1], 0.325)
  t1 = Node(xyz(hn[end])[1], xyz(hn[end])[1], xyz(hn[end])[3])
  t2 = Node(xyz(hn[end])[1], xyz(hn[end])[1], 0.325)
  t3 = Node(xyz(hn[end])[1], -xyz(hn[end])[1], 0.325)
  nodes = [b3;b2;b1;hn;t1;t2;t3]
  segments = connectnodes(nodes, SegmentParameters(w=1.7, h=0.6,
                          nhinc=nhinc, nwinc=nwinc, rh=rh, rw=rw))
  Group([nodes;segments],Dict(:a=>b3,:b=>t3))
end