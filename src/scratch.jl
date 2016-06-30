using FastHenryHelper

n1 = Node(1,1,1)
n2 = Node(2,2,2)
s = Segment(n1, n2, h=1, w=3)
g = Group([n1,n2,s])

for e in (g)
  println(typeof(e))
end
println("Done")
