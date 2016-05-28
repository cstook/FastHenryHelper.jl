export helixnodes

hexlixpoint(radius,pitch,angle)=(radius*cos(angle), radius*sin(angle), pitch*angle/(2π))

"""
        helixnodes(radius, pitch, radians, [radiansperpoint=π/4])

Returns an array of `Node`s in a helix. 
"""
function helixnodes(radius::Float64, pitch::Float64, radians::Float64, radiansperpoint::Float64=π/4)
    numberofpoints = Int(cld(radians,radiansperpoint))+1
    nodes = Array(Node,numberofpoints)
    i = 0
    for angle in 0:radiansperpoint:radians
        i+=1
        nodes[i] = Node(hexlixpoint(radius,pitch,angle)...)
    end
    if i<numberofpoints # end point didn't fall on a multiple of radiansperpoint
        i+=1
        nodes[i] = Node(hexlixpoint(radius,pitch,radians)...)
      end
    return nodes
end
