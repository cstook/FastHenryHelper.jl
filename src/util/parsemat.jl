# parsemat.jl
# 
# parses impedance matrix output file from FastFieldSolvers
export parsefasthenrymap

"""
result of parsing FastHenry .mat file
"""
type ParseFastHenryMapResult
  "array of port names, index is row number in impedance matrix"
  portnames :: Array{AbstractString,1}
  "list of frequencies at which impedance matrix is computed"
  frequencies :: Array{Float64,1}
  """
  impedance matrix at each frequency.  <br>
  impedance [impedance matrix row : impedance matrix column : frequency]
  """
  impeadance :: Array{Complex{Float64},3}
end

function parsefasthenrymap(io::IO)
  findportname = r"(\d+):.*port name: (\w+)"
  line = readline(io)
  m = match(findportname,line)
  if m==nothing
    throw(ParseError("first line did not start with \"Row\""))
  end
  numberofrows = parse(Int,m.captures[1])
  portnames = Array(AbstractString,numberofrows)
  portnames[numberofrows] = m.captures[2]
  for i in numberofrows-1:-1:1
    line = readline(io)
    m = match(findportname,line)
    if m==nothing
      rowstring = @sprintf("%d",i)
      throw(ParseError("did not find rows line for Row="*rowstring))
    end
    portnames[i] = m.captures[2]
  end
  frequencies = 0
  buffer = IOBuffer()
  impeadancematrix = Array(Complex{Float64},numberofrows,numberofrows)
  while ~eof(io)
    line = readline(io)
    frequencies+=1
    m = match(r"Impedance matrix for frequency = ([\d+-eE.]+) ",line)
    if m==nothing
      throw(ParseError("did not find \"Impedance matrix for frequency = \""))
    end
    frequency = parse(Float64,m.captures[1])
    write(buffer,frequency)
    # read impedance matrix here
    for row in 1:numberofrows
      line = readline(io)
      position = 1
      for column in 1:numberofrows # impedance matrix is square
        m = match(r"([\d+-.eE]+) *([\d+-.eE]+)j",line,position)
        if m==nothing
          throw(ParseError("error parsing impedance matrix"))
        end
        r = parse(Float64,m.captures[1])
        i = parse(Float64,m.captures[2])
        impeadancematrix[row,column]=Complex64(r,i)
        position = m.offset + length(m.match)
      end
    end
    write(buffer,impeadancematrix)
  end
  resultmatrix = Array(Complex{Float64},numberofrows,numberofrows,frequencies)
  frequencymatrix = Array(Float64,frequencies)
  seekstart(buffer)
  for i in 1:frequencies
    frequency = read(buffer,Float64)
    frequencymatrix[i] = frequency
    read!(buffer,impeadancematrix)
    resultmatrix[:,:,i] = impeadancematrix
  end
  ParseFastHenryMapResult(portnames,frequencymatrix,resultmatrix)
end

parsefasthenrymap(filename::AbstractString) = parsefasthenrymap(open(filename,"r"))

"""
    parsefasthenrymap(io::IO)
    parsefasthenrymap(filename::AbstractString)

parses the .mat output file from FastHenry

returns type `ParseFastHenryResult`
"""
parsefasthenrymap
