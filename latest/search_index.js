var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#FastHenryHelper.jl-1",
    "page": "Home",
    "title": "FastHenryHelper.jl",
    "category": "section",
    "text": "FastHenryHelper.jl assists creating input files for FastFieldSolvers."
},

{
    "location": "install/#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "install/#Installation-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": "FastHenryHelper.jl is currently unregistered.  It can be installed using Pkg.clone.Pkg.clone(\"https://github.com/cstook/FastHenryHelper.jl.git\")The julia documentation section on installing unregistered packages provides more information."
},

{
    "location": "introduction/#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "introduction/#Introduction-to-FastHenryHelper-1",
    "page": "Introduction",
    "title": "Introduction to FastHenryHelper",
    "category": "section",
    "text": "jupyter versionFastHenryHelper assists creating FastHenry input files using julia.  Groups of FastHenry commands can be copied translated and rotated, keeping names unique for the copies.  This simplifies creating input files with repetitive geometries, and reuse of groups of FastHenry commands.note: Note\nThis introduction does not attempt to explain FastHenry.  See the FastHenry User\'s Guide."
},

{
    "location": "introduction/#Loading-the-modules-1",
    "page": "Introduction",
    "title": "Loading the modules",
    "category": "section",
    "text": "using FastHenryHelper\nusing Plots; gr() # using gr() backend for plots, plotly(), plotlyjs() also work."
},

{
    "location": "introduction/#Creating-a-simple-group-1",
    "page": "Introduction",
    "title": "Creating a simple group",
    "category": "section",
    "text": "FastHenry commands are julia types which show their command.  In FastHenryHelper these are all subtypes of the supertype Element.n1 = Node(10,0,0)A name was not specified, so _1 was automatically generated. x, y, and z must always be specified.  Default coordinates are not allowed.A name can be specified as the first parameter.n2 = Node(:abcd,0,0,0)note: Note\nspecifying names is not recommended.  FastHenryHelper will not mutate user provided names to keep them unique when copies are made.Segments connect nodes.  Keyword parameters match the FastHenry keywords.s1 = Segment(n1, n2, w=10, h=20, nwinc=5, nhinc=7)Parameters may also be passed as a SegmentParameters object.sp1 = SegmentParameters(w=10, h=20, nwinc=5, nhinc=7)\ns1 = Segment(n1, n2, sp1)A SegmentParameters object can be created by specifying the parameters that differ from another SegmentParameters object.sp2 = SegmentParameters(sp1,w=5,h=3)\ns2 = Segment(n1, n2, sp2)Elements can be collected into groups.  Auto-generated names are unique within the Group show is called on.  Groups may be transformed (rotated, translated, etc.).  Groups may be nested within each other (Group is a subtype of Element).  g1 = Group([n1,n2,s2])\ng1 = Group(elements = [n1,n2,s2]) # or use keyword argumentLet\'s take a look.plot(g1)\nsavefig(\"intro_plot_1.svg\"); nothing # hide(Image: )Rotate g1 π/4 around y and z axis and translate by 10 along x axis.transformmatrix = ry(π/4) * rz(π/4) * txyz(10,0,0)\ntransform!(g1,transformmatrix)\ng1note: Note\nThe wx, wy, wz vector for the segment has rotated from default and all automatically generated names are unique.Plot after transform.plot(g1)\nsavefig(\"intro_plot_2.svg\"); nothing # hide(Image: )"
},

{
    "location": "introduction/#Creating-a-Group-with-repetitive-geometry-1",
    "page": "Introduction",
    "title": "Creating a Group with repetitive geometry",
    "category": "section",
    "text": "Create a square loop in the xy plane with a gap at the originn1 = Node(0,-1,0)\nn2 = Node(0,-10,0)\nn3 = Node(10,-10,0)\nn4 = Node(10,10,0)\nn5 = Node(0,10,0)\nn6 = Node(0,1,0)\nsp = SegmentParameters(h=2,w=3)\ns1 = Segment(n1,n2,sp)\ns2 = Segment(n2,n3,sp)\ns3 = Segment(n3,n4,sp)\ns4 = Segment(n4,n5,sp)\ns5 = Segment(n5,n6,sp)\nloop = Group([n1,n2,n3,n4,n5,n6,s1,s2,s3,s4,s5])Take a look.plot(loop)\nsavefig(\"intro_plot_3.svg\"); nothing # hide(Image: )Groups have a dictionary of terminals, nodes which are external connection points, for the group.  In this case n1 and n6 are the terminals.t = terms(loop)\nt[:a] = n1\nt[:b] = n6;loop can be defined more concisely using element and terms keyword arguments and the function  connectnodes.n1 = Node(0,-1,0)\nn2 = Node(0,-10,0)\nn3 = Node(10,-10,0)\nn4 = Node(10,10,0)\nn5 = Node(0,10,0)\nn6 = Node(0,1,0)\nloop = Group(\n  elements = [\n    n1,\n    n2,\n    n3,\n    n4,\n    n5,\n    n6,\n    connectnodes([n1,n2,n3,n4,n5,n6], SegmentParameters(h=2,w=3))...\n  ],\n  terms = Dict(:a=>n1,:b=>n6)\n)Shift loop 5 along x axistransform!(loop,txyz(5,0,0))Create array of 8 loops each rotated π/4 around y axistm = ry(π/4)\nloops = Array{Group}(undef,8)\nfor i in 1:8\n  transform!(loop,tm)\n  loops[i] = deepcopy(loop)\nendCreate a group of the loops.loopsgroup = Group(loops)Take a look.plot(loopsgroup)\nsavefig(\"intro_plot_4.svg\"); nothing # hide(Image: )Define a port for each loop.ex = []\nfor loop in loops\n  push!(ex, External(loop[:a],loop[:b]))  # use terminals we defined\nend\nexternalgroup = Group(ex)Create top level group.eightloops = Group(\n  elements = [\n    Units(\"mm\"),\n    Default(SegmentParameters(sigma=62.1e6*1e-3, nwinc=7, nhinc=5)),\n    loopsgroup,\n    externalgroup,\n    Freq(min=1e-1, max=1e9, ndec=0.05),\n    End()\n  ]\n);\nnothing # hideWrite to file.open(\"eightloops.inp\",\"w\") do io\n  print(io,eightloops)\nendFastHenry was run with \"eightloops.inp\" input file.note: Note\nFastHenryHelper does not call FastHenry.view eightloops.inp.view FastHenry output eightloopsZc.mat.The FastHenry .mat output file can be parsed.result = parsefasthenrymat(\"eightloopsZc.mat\")\nresult.impedance"
},

{
    "location": "introduction/#Group-units-1",
    "page": "Introduction",
    "title": "Group units",
    "category": "section",
    "text": "In addition to the Units type, units may be specified for a Group using the units keyword.  Group units only apply to the elements in the Group.groupunitexample = Group(\n  elements = [\n    Units(\"cm\"),\n    Node(1,0,0),\n    Group(\n      elements = [\n        Node(20,0,0)\n      ],\n      units = Units(\"mm\")\n    ),\n    Node(3,0,0)\n  ]\n)"
},

{
    "location": "examples/#",
    "page": "Examples",
    "title": "Examples",
    "category": "page",
    "text": ""
},

{
    "location": "examples/#Examples-1",
    "page": "Examples",
    "title": "Examples",
    "category": "section",
    "text": ""
},

{
    "location": "examples/#Example-1:-A-simple-example-from-the-FastHenry-documentation.-1",
    "page": "Examples",
    "title": "Example 1: A simple example from the FastHenry documentation.",
    "category": "section",
    "text": "jupyter versionThis example is a recreation of the example in section 1.2 of \"FastHenry User\'s Guide\" using FastHeneryHelper.load the moduleusing FastHenryHelperCreate a group of FastHenry elements for FastHenry to compute the loop inductance of an L shaped trace over a ground plane with the trace\'s return path through the plane.sp = SegmentParameters(w=8,h=1)\nnin = Node(\"in\",800,800,0)\nnout = Node(\"out\",0,200,0)\nn1 = Node(\"1\",0,200,1.5)\nn2 = Node(800,200,1.5)\nn3 = Node(800,800,1.5)\nexample1 = Group(\n  elements = [\n    Comment(\"A FastHenry example using a reference plane\"),\n    Units(\"mils\"),\n    UniformPlane(\n      x1=0,    y1=0,    z1=0,\n      x2=1000, y2=0,    z2=0,\n      x3=1000, y3=1000, z3=0,\n      thick= 1.2,\n      seg1=20, seg2=20,\n      nodes=[nin, nout]),\n    Default(SegmentParameters(sigma=62.1e6*2.54e-5,nwinc=8, nhinc=1)),\n    n1,\n    n2,\n    n3,\n    Segment(n1,n2,sp),\n    Segment(n2,n3,sp),\n    Equiv([nin,n3]),\n    External(n1,nout),\n    Freq(min=1e-1, max=1e9, ndec=0.05),\n    End()\n    ]\n  )Write example1 to a file.open(\"example1.inp\",\"w\") do io\n    show(io,example1)\nendGroups may be transformed.  To demonstrate, example1 is rotated 90deg around x,y,and z axis.transform!(example1,rx(0.5π)*ry(0.5π)*rz(0.5π))  # must keep plane parallel to xy, xz, or yz planeWrite rotated example1 to a fileopen(\"example1_rotated.inp\",\"w\") do io\n    show(io,example1)\nendcalling push! on a Group will push into the groups elements.# same example, using push!\nexample1 = Group()\npush!(example1,Comment(\"A FastHenry example using a reference plane\"))\npush!(example1,Units(\"mils\"))\nnin = Node(\"in\",800,800,0)\nnout = Node(\"out\",0,200,0)\npush!(example1,UniformPlane(x1=0, y1=0, z1=0, x2=1000, y2=0, z2=0, x3=1000, y3=1000, z3=0,\n    thick= 1.2, seg1=20, seg2=20, nodes=[nin, nout]))\npush!(example1,Default(SegmentParameters(sigma=62.1e6*2.54e-5,nwinc=8, nhinc=1)))\nn1 = Node(\"1\",0,200,1.5)\npush!(example1,n1)\nn2 = Node(800,200,1.5)\npush!(example1,n2)\nn3 = Node(800,800,1.5)\npush!(example1,n3)\nsp = SegmentParameters(w=8,h=1)\npush!(example1,Segment(n1,n2,sp))\npush!(example1,Segment(n2,n3,sp))\npush!(example1,Equiv([nin,n3]))\npush!(example1,External(n1,nout))\npush!(example1,Freq(min=1e-1, max=1e9, ndec=0.05))\npush!(example1,End());\nnothing # hidePlot of example1using Plots; gr()\nplot(example1)\nsavefig(\"example1_plot_1.svg\"); nothing # hide(Image: )"
},

{
    "location": "examples/#Example-2:-Four-square-loops-1",
    "page": "Examples",
    "title": "Example 2: Four square loops",
    "category": "section",
    "text": "jupyter versionThis example demonstrates using groups to simplify repetitive structures.Load the module.using FastHenryHelperCreate a group for one square loop 10mm on a side.n1 = Node(0,0,0)\nn2 = Node(10,0,0)\nn3 = Node(10,10,0)\nn4 = Node(0,10,0)\nn5 = Node(0,1,0) # leave a 1mm gap for the port\nsquareloop = Group(\n    elements=[\n        Comment(\"loop start\"),\n        n1,\n        n2,\n        n3,\n        n4,\n        n5, # leave a 1mm gap for the port\n        connectnodes([n1,n2,n3,n4,n5], SegmentParameters(h=0.5, w=1.5))...,\n        Comment(\"loop end\")\n    ],\n    terms = Dict(:a=>n1,:b=>n5) # ports will be between :a and :b\n)Create an array of four square loops, each one shifted 10mm on z axis.loops = Array{Group}(undef,4)\nz = [0.0, 10.0, 20.0, 30.0]\nfor i in eachindex(loops)\n    loops[i] = transform(squareloop, txyz(0,0,z[i]))\nendCreate the top level group.fourloops = Group(\n    elements=[\n        Comment(\"Four loops 10mm on a side offset by 10mm in z\"),\n        Units(\"mm\"),\n        Comment(\"\"),\n        Comment(\"sigma for copper, 25 filaments per segment\"),\n        Default(sigma=62.1e6*1e-3, nwinc=5, nhinc=5),\n        Comment(\"\"),\n        Comment(\"the loops\"),\n        loops...,\n        Comment(\"\"),\n        Comment(\"define three ports\"),\n        External(loops[3][:b],loops[4][:b],\"port_1\"),\n        External(loops[2][:a],loops[2][:b],\"port_2\"),\n        External(loops[1][:a],loops[1][:b],\"port_3\"),\n        Comment(\"\"),\n        Comment(\"define frequencies\"),\n        Freq(min=1e-1, max=1e9, ndec=0.05),\n        Comment(\"\"),\n        Comment(\"always need end\"),\n        End()\n    ]\n)Plot of fourloopsusing Plots; gr()  # use plotlyjs() or plotly() for interactive plot\nplot(fourloops)\nsavefig(\"example2_fourloops.svg\"); nothing # hide(Image: )Write fourloops to file.open(\"fourloops.inp\",\"w\") do io\n    show(io,fourloops)\nendSee the output file fourloops.inp."
},

{
    "location": "examples/#Example-3:-Via-connection-between-plane-and-segment-1",
    "page": "Examples",
    "title": "Example 3: Via connection between plane and segment",
    "category": "section",
    "text": "jupyter versionThis example demonstrates the use of viagroup and planeconnect functions.Load the module.using FastHenryHelperConstants for a 63mil PCB with 1oz copper.  Copper thickness is made much thicker than 1oz copper to make planes more visible in the plots.const height = 1.6      # 63mil PCB\nconst cu_sigma = 5.8e4\n# const cu_thick = 0.035  # 1oz copper\nconst cu_thick = 0.5    # exaggerate thicknessCreate a function which returns a Group with all the elements of the FastHenry input file.function via_connection_example(height, cu_thick)\n  t = Comment(\"via connection to plane example\")\n  u = Units(\"mm\")\n\n  # create a via with 16 segments\n  # botequiv = false will allow each segment\n  # to connect to the plane separately\n  via = viagroup(radius=2, height=height, h=cu_thick, nhinc = 1,\n  sigma=cu_sigma, n=16, topequiv = true, botequiv = false)\n\n  # move via into position\n  transform!(via, txyz(3.0,5.0,0.0))\n\n  top_port_node = Node(10,5,0)\n  # via[:top] is a node in the center of the top of the via.  It\n  # is equiv to the ring of nodes at the top of the via segments.\n  topseg = Segment(via[:top], top_port_node, h=cu_thick, w=1.5)\n\n\n  # create a line of nodes along what will be the right side of the plane\n  bot_port = Array{Node}(undef,50)\n  y = 0.0\n  for i in eachindex(bot_port)\n    bot_port[i] = Node(10.0,y,-height)\n    y += 0.2\n  end\n\n  # short the line of vias.  This will be one terminal of the external port.\n  bot_port_equiv = Equiv(bot_port)\n\n  # planeconnect retuns a deepcopy of the nodes, and a group of equiv\'s to\n  # connect them to the original nodes.\n  # via[:allbot] is an array of the 16 nodes around the bottom on the via\n  (bot_plane_nodes,bot_plane_nodes_equiv_group) = planeconnect(via[:allbot])\n\n  # create a plane with 100x100 segments.\n  # nodes connect to the external port and the bottom of the via\n  botplane = UniformPlane(\n    x1= 0.0, y1= 0.0, z1=-height,\n    x2= 0.0, y2=10.0, z2=-height,\n    x3=10.0, y3=10.0, z3=-height,\n    thick = cu_thick,\n    seg1=100, seg2=100,\n    sigma = cu_sigma,\n    nhinc = 5,\n    nodes = [bot_plane_nodes;bot_port]\n	)\n\n  # define the external port between the two lines of nodes\n  ex = External(top_port_node,bot_port[1])\n\n  # just want low frequency\n  f = Freq(min=0.1, max=1e9, ndec=0.05)\n\n  e = End() # always need an end\n\n  # return a group of the element we want for our FastHenry input file\n  Group([t; u; via;\n         top_port_node; topseg;\n         botplane; bot_plane_nodes_equiv_group;\n         bot_port_equiv; top_port_node;\n         ex; f; e])\nendCall the function with PCB height and copper thickness.example3 = via_connection_example(height, cu_thick);\nnothing # hidePlot of example3using Plots; gr()\nplot(example3)\nsavefig(\"example3.svg\"); nothing # hide(Image: )Write results to a file.io = open(\"via_to_plane.inp\",\"w+\")\nshow(io,example3)\nclose(io)See the output file viatoplane.inp.See the .mat file produced by FastHenry viatoplane.mat."
},

{
    "location": "examples/#Example-4:-Use-of-rectangulararray-1",
    "page": "Examples",
    "title": "Example 4: Use of rectangulararray",
    "category": "section",
    "text": "jupyter versionA 2x3 array of via\'s is produced using rectangulararray and is connected to a plane.  This example does not create a complete FastHenry file.Load the modules.using FastHenryHelper\nusing Plots;gr()\nnothing # hideCreate a single via at the origin.Parameter height is the height of the via and h is the thickness of the copper plating (height of the vias segments).  Parameters topequiv and botequiv determine if the ring of nodes and the center node are connected with an equiv command.  The default setting true is used so the center node (:top or :bot) can connect to a segment.  To connect to a plane, topequiv and / or  botequiv should be set to false so :alltop and / or :allbot can connect to the plane.  via = viagroup(radius=5, height=7, h=3, n=8, topequiv = false, botequiv = false);\nnothing # hideCreate a Group of six vias.As its second parameter, transform can accept an iterable returning 4x4 matrices and returns a Group containing deepcopies of the Element modified by each 4x4 transformation matrix.  If the Element is a Group, the returned Groups terminal dictionary will have the same keys as Group passed as a parameter.  The values will be an array of all the Nodes with corresponding keys.  In other words, the terminals of the returned Group will connect all the Groups in parallel.  This behavior is intended to make it easy to connect planes with arrays of vias.six_vias = transform(via,  rectangulararray([20,40,60],[10,30]));\nnothing # hideCreate objects needed to connect to plane.planeconnect returns a tuple of two objects needed to connect to a plane.  In this case, plane_nodes is a deepcopy of nodes six_vias[:alltop] and equiv_group connects the corresponding nodes in plane_nodes and six_vias[:alltop].(plane_nodes, equiv_group) = planeconnect(six_vias[:alltop]);\nnothing # hideCreate the plane.plane = UniformPlane(\n        x1=80.0, y1= 80.0, z1=0.0,\n        x2= 0.0, y2= 80.0, z2=0.0,\n        x3= 0.0, y3= 0.0, z3=0.0,\n        thick = 1,\n        seg1=100, seg2=100,\n        nodes = plane_nodes);\nnothing # hideCreate a Group with all elements.example4 = Group([six_vias;plane;equiv_group]);\nnothing # hidePlot of example4plot(example4)\nsavefig(\"example4.svg\"); nothing # hide(Image: )"
},

{
    "location": "public/#",
    "page": "Public API",
    "title": "Public API",
    "category": "page",
    "text": ""
},

{
    "location": "public/#FastHenryHelper-Public-API-1",
    "page": "Public API",
    "title": "FastHenryHelper Public API",
    "category": "section",
    "text": "CurrentModule = FastHenryHelper"
},

{
    "location": "public/#Index-1",
    "page": "Public API",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "public/#FastHenryHelper.Element",
    "page": "Public API",
    "title": "FastHenryHelper.Element",
    "category": "type",
    "text": "Subtypes of Element show FastHenry commands.\n\nGeometric transformations can be preformed on elements with transform. Elements which require a name will automatically generate unique names if no name is provided.  Groups of elements are elements.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.transform",
    "page": "Public API",
    "title": "FastHenryHelper.transform",
    "category": "function",
    "text": "transform(element, transformation_matrix)\ntransform!(element, transformation_matrix)\n\nTransform (rotate, translate, scale, etc...) a element by 4x4 transform matrix  tm.\n\nTransform will modify the coordinates of Elements and the wx, wy, and wz  parameters of Segment.  transform of a Segment will not modify its Nodes.  transform a Group containing the Nodes and Segment instead.  Typically  transform would only be applied to Group objects.\n\ntransform(element, transformation_matrix_list)\n\nReturn a Group of copies of element transformed by each matrix in transformation_matrix_list.\n\nIf the element is a Group, the terms of the returned group has the same keys as element, but the values are arrays of Nodes of all the copies of elements.  In other words, the elements are electricaly in parallel.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.rx",
    "page": "Public API",
    "title": "FastHenryHelper.rx",
    "category": "function",
    "text": "rx(α) = [1      0       0     0;\n         0    cos(α)  sin(α)  0;\n         0   -sin(α)  cos(α)  0;\n         0      0       0     1]\n\nRotation matrix for angle α around x axis.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.ry",
    "page": "Public API",
    "title": "FastHenryHelper.ry",
    "category": "function",
    "text": "ry(β) = [cos(β)   0    -sin(β)  0;\n           0      1       0     0;\n         sin(β)   0     cos(β)  0;\n           0      0       0     1]\n\nRotation matrix for angle β around y axis.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.rz",
    "page": "Public API",
    "title": "FastHenryHelper.rz",
    "category": "function",
    "text": "rz(γ) = [cos(γ) sin(γ) 0  0;\n        -sin(γ) cos(γ) 0  0;\n          0       0    1  0;\n          0       0    0  1]\n\nRotation matrix for angle γ around z axis.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.txyz",
    "page": "Public API",
    "title": "FastHenryHelper.txyz",
    "category": "function",
    "text": "txyz(p,q,r) = [1.0 0.0 0.0  p;\n               0.0 1.0 0.0  q;\n               0.0 0.0 1.0  r;\n               0.0 0.0 0.0 1.0]\n\nTranslation matrix.  Translate a coordinate by adding [p,q,r]\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.scalexyz",
    "page": "Public API",
    "title": "FastHenryHelper.scalexyz",
    "category": "function",
    "text": "scalexyz(p,q,r) = [ p  0.0 0.0 0.0;\n                   0.0  q  0.0 0.0;\n                   0.0 0.0  r  0.0;\n                   0.0 0.0 0.0 1.0]\n\nScale matrix.  Scale a coordinate [x, y, z] by [p, q, r].\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Node",
    "page": "Public API",
    "title": "FastHenryHelper.Node",
    "category": "type",
    "text": "Node([name],x,y,z)\nNode(xyz::Array{Float64,1})\n\nNode objects show a FastHenry node command.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.xyz",
    "page": "Public API",
    "title": "FastHenryHelper.xyz",
    "category": "function",
    "text": "xyz(n::Node)\n\nReturn the coordinate of a node.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Segment",
    "page": "Public API",
    "title": "FastHenryHelper.Segment",
    "category": "type",
    "text": "Segment([name], n1::Node, n2::Node, [parameters::SegmentParameters])\nSegment([name], n1::Node, n2::Node, <keyword arguments>)\n\nSegment objects show a FastHenry segment command.\n\nKeyword arguments are the same as for SegmentParameters.\n\nnote: When rotating segments, the vector [wx, wy, wz] will be rotated.  Default values will be used if not specified.  wx, wy, wz will show after transform[!] is called on a Segment.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.SegmentParameters",
    "page": "Public API",
    "title": "FastHenryHelper.SegmentParameters",
    "category": "type",
    "text": "SegmentParameters(<keyword arguments>)\nSegmentParameters(parameters::SegmentParameters, <keyword arguments>)\n\nObject to hold parameters for Segment and Default\n\nKeyword Arguments\n\nw               – segment width\nh               – segment height\nsigma           – conductivity\nrho             – resistivity\nwx, wy, wz  – segment orientation.  vector pointing along width of segment\'s cross section.\nnhinc, nwinc  – integer number of filaments in height and width\nrh, rw        – ratio in the height and width\n\nThe second form replaces values in parameters with any keyword parameters present.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Default",
    "page": "Public API",
    "title": "FastHenryHelper.Default",
    "category": "type",
    "text": "Default(<keyword arguments>)\nDefault(parameters::SegmentParameters)\n\nDefault objects show a .default FastHenry command.\n\nKeyword Arguments\n\nw               – segment width\nh               – segment height\nsigma           – conductivity\nrho             – resistivity\nnhinc, nwinc  – integer number of filaments in height and width\nrh, rw        – ratio in the height and width\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.External",
    "page": "Public API",
    "title": "FastHenryHelper.External",
    "category": "type",
    "text": "External(n1::Node, n2::Node, [portname::AbstractString])\n\nExternal objects show a FastHenry .external command.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.End",
    "page": "Public API",
    "title": "FastHenryHelper.End",
    "category": "type",
    "text": "End()\n\nEnd objects show a FastHenry .end command.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Equiv",
    "page": "Public API",
    "title": "FastHenryHelper.Equiv",
    "category": "type",
    "text": "Equiv(nodes::Array{Node,1})\n\nEquiv objects show a FastHenry .equiv command\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Freq",
    "page": "Public API",
    "title": "FastHenryHelper.Freq",
    "category": "type",
    "text": "Freq(min, max, [ndec])\nFreq(<keyword arguments>)\n\nFreq objects show a FastHenry .freq command.\n\nKeyword arguments are min, max, ndec.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Group",
    "page": "Public API",
    "title": "FastHenryHelper.Group",
    "category": "type",
    "text": "Group([elements [, terms[, units]]])\nGroup(<keyword arguments>)\n\nGroup objects show FastHenry commands of their elements.\n\nKeyword Arguments\n\nelements    – Array of Element\'s\nterms       – Dict{Symbol,Node} # connections to the Group\nunits       – Units used for the Group\n\nGroups may be nested.  Automatic name generation will create a name for each Element in the Group and all subgroups as needed when show is called.  Generated names start with an underscore.  Do not use these names for user named elements.\n\ngetindex, setindex!, and merge! operate on terms. push!, pop!, pushfirst!, popfirst!, append!, prepend! operate on elements.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.elements",
    "page": "Public API",
    "title": "FastHenryHelper.elements",
    "category": "function",
    "text": "elements(g::Group)\nelements!(g::Group, e::Element)\n\nGet and set elements field in a Group.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.terms",
    "page": "Public API",
    "title": "FastHenryHelper.terms",
    "category": "function",
    "text": "terms(g::Group)\nterms!(g::Group, p::Dict{Symbol,Node})\n\nGet and set the terms field in a Group.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Comment",
    "page": "Public API",
    "title": "FastHenryHelper.Comment",
    "category": "type",
    "text": "Comment(text::AbstractString)\n\nComment objects show a FastHenry comment.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Units",
    "page": "Public API",
    "title": "FastHenryHelper.Units",
    "category": "type",
    "text": "Units(unitname::String)\n\nUnits objects show a FastHenry .units command.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.UniformPlane",
    "page": "Public API",
    "title": "FastHenryHelper.UniformPlane",
    "category": "type",
    "text": "UniformPlane(<keyword arguments>)\n\nUniformPlane objects show a FastHenry uniform discretized plane command.\n\nKeyword Arguments\n\nname              – plane name\nx1,y1,z1      – coordinate of first corner\nx2,y2,z2      – coordinate of second corner\nx3,y3,z3      – coordinate of third corner\nthick             – segment thickness\nseg1,seg2       – number of segments along each side of plane\nsegwid1,segwid2 – segment width\nsigma,rho       – specify conductivity or resistivity\nnhinc             – integer number of filaments\nrh                – filament ratio\nrelx,rely,relz– see FastHenry documentation\nnodes             – Array of Node connection points to plane\nholes             – Array of Hole (Point, Rect, or Circle)\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Hole",
    "page": "Public API",
    "title": "FastHenryHelper.Hole",
    "category": "type",
    "text": "Subtypes of Hole are holes in a plane.\n\nSubtypes\n\nPoint\nRect\nCircle\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Point",
    "page": "Public API",
    "title": "FastHenryHelper.Point",
    "category": "type",
    "text": "Point(x, y, z)\nPoint(<keyword arguments>)\n\nPoint objects are used for point holes in a UniformPlane.\n\nKeyword arguments are x, y, z.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Rect",
    "page": "Public API",
    "title": "FastHenryHelper.Rect",
    "category": "type",
    "text": "Rect(x1, y1, z1, x2, y2, z2)\nRect(<keyword arguments>)\n\nRect objects are used for rectangular holes in a UniformPlane.\n\nKeyword arguments are x1, y1, z1, x2, y2, z2.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.Circle",
    "page": "Public API",
    "title": "FastHenryHelper.Circle",
    "category": "type",
    "text": "Circle(x, y, z, r)\nCircle(<keyword arguments>)\n\nCircle objects are used for circular holes in a UniformPlane.\n\nKeyword arguments are x, y, z, r.\n\n\n\n\n\n"
},

{
    "location": "public/#Elements-1",
    "page": "Public API",
    "title": "Elements",
    "category": "section",
    "text": "Element\ntransform\nrx\nry\nrz\ntxyz\nscalexyz\nNode\nxyz\nSegment\nSegmentParameters\nDefault\nExternal\nEnd\nEquiv\nFreq\nGroup\nelements\nterms\nComment\nUnits\nUniformPlane\nHole\nPoint\nRect\nCircle"
},

{
    "location": "public/#FastHenryHelper.connectnodes",
    "page": "Public API",
    "title": "FastHenryHelper.connectnodes",
    "category": "function",
    "text": "connectnodes(nodes::Array{Node,1}, [parameters::SegmentParameters])\n\nReturns an array of Segments connecting Nodes.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.helixnodes",
    "page": "Public API",
    "title": "FastHenryHelper.helixnodes",
    "category": "function",
    "text": "    helixnodes(radius, pitch, radians, [radiansperpoint=π/4])\n\nReturns an array of Nodes in a helix.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.viagroup",
    "page": "Public API",
    "title": "FastHenryHelper.viagroup",
    "category": "function",
    "text": "viagroup(radius, height, n, [parameters::SegmentParameters [,topequiv [,botequiv]]])\nviagroup(<keyword arguments>)\n\nReturns a Group of Segments for the barrel of a via.\n\nKeyword Arguments\n\nradius          – radius of via\nheight          – height of via\nh               – thickness of copper plating\nn               – number of segment around via\nsigma,rho     – specify conductivity or resistivity\nnhinc           – number of filaments per segment\nrh              – ratio of filament width\ntopequiv        – include .equiv for all top nodes.  default = true\nbotequiv        – include .equiv for all bot nodes.  default = true\n\nTerminals are in the center labeled :top and :bot.  Only SegmentParameters which match keyword arguments are used.  Specify n=0 to bypass via (.equiv top bot). Terminals :alltop and :allbot are arrays of all top and bottom nodes.  :alltop, :allbot, topequiv, and botequiv are intended for connections to planes.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.coilcraft1010vsgroup",
    "page": "Public API",
    "title": "FastHenryHelper.coilcraft1010vsgroup",
    "category": "function",
    "text": "coilcraft1010vsgroup(partnumber, <keyword arguments>)\n\nReturns a Group for a Coilcraft 1010VS series inductor.\n\nPart Numbers\n\n1010VS-23NME\n1010VS-46NME\n1010VS-79NME\n1010VS-111ME\n1010VS-141ME\n\nKeyword Arguments\n\nnhinc, nwinc  – integer number of filaments in height and width\nrh, rw        – ratio in the height and width\n\nTerminals are :a and :b.\n\n\n\n\n\n"
},

{
    "location": "public/#Groups-and-Arrays-1",
    "page": "Public API",
    "title": "Groups and Arrays",
    "category": "section",
    "text": "connectnodes\nhelixnodes\nviagroup\ncoilcraft1010vsgroup"
},

{
    "location": "public/#FastHenryHelper.rectangulararray",
    "page": "Public API",
    "title": "FastHenryHelper.rectangulararray",
    "category": "function",
    "text": "rectangulararray(x[,y[,z]])\nrectangulararray(<keyword arguments>)\n\nUsed with transform to create rectangular arrays of elements.\n\nrectangulararray returns a iterable object which returns a sequence of transformation matrices, which when passed to transform will produce a rectangular array of elements.  x, y, and z are iterable objects which specify the offsets along the x, y, and z axis.  Unspecified arguments are zero.\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.planeconnect",
    "page": "Public API",
    "title": "FastHenryHelper.planeconnect",
    "category": "function",
    "text": "planeconnect(nodes::Array{Node,1})\nplaneconnect(node::Node)\n\nProvides objects needed to connect to a plane.\n\nReturns a tuple of a deepcopy of the nodes passed and a group of Equiv objects  connecting the nodes passed to the nodes returned.\n\n(planenodearray, equivgroup) = planeconnect(nodearray)\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.parsefasthenrymat",
    "page": "Public API",
    "title": "FastHenryHelper.parsefasthenrymat",
    "category": "function",
    "text": "parsefasthenrymat(io::IO)\nparsefasthenrymat(filename::AbstractString)\n\nparses the .mat output file from FastHenry\n\nreturns type ParseFastHenryResult\n\n\n\n\n\n"
},

{
    "location": "public/#FastHenryHelper.ParseFastHenryMatResult",
    "page": "Public API",
    "title": "FastHenryHelper.ParseFastHenryMatResult",
    "category": "type",
    "text": "ParseFastHenryMatResult\n\nResult of parsing FastHenry .mat file.\n\nFields\n\nportnames    – array of port names, index is row number in impedance matrix\nfrequencies  – frequencies at which impedance matrix is computed\nimpedance    – impedance matrix at each frequency. impedance[row, col, frequency]\n\n\n\n\n\n"
},

{
    "location": "public/#Utility-1",
    "page": "Public API",
    "title": "Utility",
    "category": "section",
    "text": "rectangulararray\nplaneconnect\nparsefasthenrymat\nParseFastHenryMatResult"
},

]}
