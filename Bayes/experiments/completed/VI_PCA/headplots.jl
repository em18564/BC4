using TopoPlots, CairoMakie,Serialization#, GLMakie 
using Makie

topoplot(rand(10), rand(Point2f, 10); contours=(color=:white, linewidth=2), label_scatter=true, bounding_geometry=Rect)
data, positions = TopoPlots.example_data()
proj = deserialize("proj2.jls")
eeg_topoplot(data[:, 340, 1]; positions=positions)

pos2 = [Point(0.5,0.5),
        Point(0.5,0.58),Point(0.58,0.54),Point(0.58,0.46),Point(0.5,0.42),Point(0.42,0.46),Point(0.42,0.54),
        Point(0.58,0.64),Point(0.64,0.60),Point(0.67,0.46),Point(0.63,0.40),Point(0.56,0.37),
        Point(0.44,0.37),Point(0.37,0.40),Point(0.33,0.46),Point(0.36,0.60),Point(0.42,0.64),
        Point(0.5,0.72),
        Point(0.61,0.7),Point(0.7,0.67),Point(0.77,0.62),Point(0.8,0.5),
        Point(0.77,0.38),Point(0.7,0.33),Point(0.61,0.30),
        Point(0.39,0.30),Point(0.3,0.33),Point(0.23,0.38),
        Point(0.2,0.5),Point(0.23,0.62),Point(0.3,0.67),Point(0.39,0.7)
      ]

pos2 = pos2 .- Point(0.5,0.5)
pos  = pos2 .* Point(1.5,2)
#VEOG,HEOG,50,36,49,37,48,38,47,39,46,40,45,41,44,42,34,21,33,22,31,24,30,25,29,26,18,10,16,12,14,1 ,35,8
#   1,   2,34,21,33,22,32,23,31,24,30,25,29,26,28,27,19,10,18,11,17,12,16,13,15,14,9 ,5 ,8 ,6 ,7 ,3 ,20,4
#   1,   2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34
#   0,   0, 1  8 10,12,14,16,18,21,22,24,25,26,29,30,31,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50
elan=[      0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]
lan =[      0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0]
n400=[      1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0]
epnp=[      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]
p600=[      1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0]
pnp =[      1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
vars = [ 54.9, 15.7, 5.5, 4.5, 2.4, 1.9]



function reorder(input)
        output = [input[32],input[34],input[28],input[30],input[31],input[29],input[27],input[18],input[20],input[22],
                  input[24],input[26],input[25],input[23],input[21],input[19],input[17],input[33],input[4],input[6],
                  input[8],input[10],input[12],input[14],input[16],input[15],input[13],input[11],input[9],input[7],
                  input[5],input[3]]
        return output
end
function plotComponent(f,val)
        x = append!([0.0,0.0],proj[:,val])
        return eeg_topoplot(f[2, val],reorder(x); positions=pos,axis=(type=Axis, title="Component " * string(val) * " (" * string(vars[val]) * "%)",aspect=DataAspect(),))
end

function eegPlots(f = Figure(size = (1200, 400)))
        eeg_topoplot(f[1, 1],elan; positions=pos,axis=(type=Axis, title="ELAN",aspect=DataAspect(),))
        eeg_topoplot(f[1, 2],lan;  positions=pos,axis=(type=Axis, title="LAN" ,aspect=DataAspect(),))
        eeg_topoplot(f[1, 3],n400; positions=pos,axis=(type=Axis, title="N400",aspect=DataAspect(),))
        eeg_topoplot(f[1, 4],epnp; positions=pos,axis=(type=Axis, title="EPNP",aspect=DataAspect(),))
        eeg_topoplot(f[1, 5],p600; positions=pos,axis=(type=Axis, title="P600",aspect=DataAspect(),))
        eeg_topoplot(f[1, 6],pnp;  positions=pos,axis=(type=Axis, title="PNP" ,aspect=DataAspect(),))
        plotComponent(f,1)
        plotComponent(f,2)
        plotComponent(f,3)
        plotComponent(f,4)
        plotComponent(f,5)
        plotComponent(f,6)
        f
    end


eegPlots()