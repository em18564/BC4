using Random
using Turing
using Turing: Variational

using Turing
using CSV
using DataFrames

using Serialization
using MultivariateStats
using Plots
using RDatasets
df_full = CSV.read("../../input/dfHierarchicalNorm.csv", DataFrame)
df = df_full[:, [:ELAN, :LAN, :N400, :EPNP, :P600, :PNP]]
M = fit(PCA, transpose(Matrix(df)))
Yte = predict(M, Matrix(df))
Xr = reconstruct(M, Yte)

ELAN = Yte[:,1]
LAN  = Yte[:,2]
N400 = Yte[:,3]
EPNP = Yte[:,4]
P600 = Yte[:,5]
PNP  = Yte[:,6]
p = scatter(ELAN[1,:],ELAN[2,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
scatter!(LAN[1,:],LAN[2,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
scatter!(N400[1,:],N400[2,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
scatter!(EPNP[1,:],EPNP[2,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
scatter!(P600[1,:],P600[2,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
scatter!(PNP[1,:],PNP[2,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

plot(p,xlabel="PC1",ylabel="PC2",zlabel="PC3")

p2 = scatter(ELAN[1,:],ELAN[2,:],marker=:circle,linewidth=0,label="ELAN")
scatter!(LAN[1,:],LAN[2,:],marker=:circle,linewidth=0,label="LAN")
scatter!(N400[1,:],N400[2,:],marker=:circle,linewidth=0,label="N400")
scatter!(EPNP[1,:],EPNP[2,:],marker=:circle,linewidth=0,label="EPNP")
scatter!(P600[1,:],P600[2,:],marker=:circle,linewidth=0,label="P600")
scatter!(PNP[1,:],PNP[2,:],marker=:circle,linewidth=0,label="PNP")

plot(p2,xlabel="PC1",ylabel="PC2")

p3 = scatter(ELAN[1,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
scatter!(LAN[1,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
scatter!(N400[1,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
scatter!(EPNP[1,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
scatter!(P600[1,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
scatter!(PNP[1,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

plot(p3,xlabel="PC1",ylabel="PC3")

p4 = scatter(ELAN[2,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
scatter!(LAN[2,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
scatter!(N400[2,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
scatter!(EPNP[2,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
scatter!(P600[2,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
scatter!(PNP[2,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

plot(p4,xlabel="PC2",ylabel="PC3")


# iris = dataset("datasets", "iris")

# # split half to training set
# Xtr = Matrix(iris[1:2:end,1:4])'
# Xtr_labels = Vector(iris[1:2:end,5])

# # split other half to testing set
# Xte = Matrix(iris[2:2:end,1:4])'
# Xte_labels = Vector(iris[2:2:end,5])

# M = fit(PCA, Xtr; maxoutdim=3)

# Yte = predict(M, Xte)

# Xr = reconstruct(M, Yte)

# setosa = Yte[:,Xte_labels.=="setosa"]
# versicolor = Yte[:,Xte_labels.=="versicolor"]
# virginica = Yte[:,Xte_labels.=="virginica"]

# p = scatter(setosa[1,:],setosa[2,:],setosa[3,:],marker=:circle,linewidth=0)
# scatter!(versicolor[1,:],versicolor[2,:],versicolor[3,:],marker=:circle,linewidth=0)
# scatter!(virginica[1,:],virginica[2,:],virginica[3,:],marker=:circle,linewidth=0)
# plot!(p,xlabel="PC1",ylabel="PC2",zlabel="PC3")