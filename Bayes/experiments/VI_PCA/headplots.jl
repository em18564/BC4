using TopoPlots, CairoMakie
using GLMakie, 

topoplot(rand(10), rand(Point2f, 10); contours=(color=:white, linewidth=2), label_scatter=true, bounding_geometry=Rect)
data, positions = TopoPlots.example_data()
proj = deserialize("proj.jls")
eeg_topoplot(data[:, 340, 1]; positions=positions)