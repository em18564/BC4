using TopoPlots, CairoMakie#, GLMakie 

topoplot(rand(10), rand(Point2f, 10); contours=(color=:white, linewidth=2), label_scatter=true, bounding_geometry=Rect)
data, positions = TopoPlots.example_data()
proj = deserialize("proj.jls")
eeg_topoplot(data[:, 340, 1]; positions=positions)

pos2 = [Point(0.5,0.5),
        Point(0.5,0.6),Point(0.58,0.54),Point(0.58,0.46),Point(0.5,0.4),Point(0.42,0.46),Point(0.42,0.54),
        Point(0.58,0.66),Point(0.64,0.62),Point(0.65,0.46),Point(0.63,0.40),Point(0.59,0.36),
        Point(0.41,0.36),Point(0.37,0.40),Point(0.35,0.46),Point(0.36,0.62),Point(0.42,0.66),
        Point(0.5,0.7),
        Point(0.61,0.68),Point(0.7,0.65),Point(0.77,0.6),Point(0.8,0.5)]
    