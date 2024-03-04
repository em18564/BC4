using Random
using Turing
using Turing: Variational

using Turing
using CSV
using DataFrames

using Serialization
using MultivariateStats
using Plots
elan=[      0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]
lan =[      0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0]
n400=[      1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0]
epnp=[      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]
p600=[      1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0]
pnp =[      1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
df_full = CSV.read("../../input/dfEEG.csv", DataFrame)
df = select(df_full, Not([:"Participant", :"Tag",:"Word",:"EEG1",:"EEG2"]))
df_lab = unique(select(df_full, ([:"Participant", :"Tag",:"Word"])))
df_labels = Vector(df_lab[:, :Tag])
M = fit(ICA, transpose(Matrix(df)),6)

Yte = predict(M, transpose(Matrix(df)))
df_PCA = df_full
# df_PCA = df_full
# #go through PCA in detail and get basic idea, interpret, plot by word type of scatter, check loo against normalisation.
PCs = transpose(Yte)
#ICA
#scatter(Yte[1,:],Yte[2,:])
df_PCA[!,"PC_1"] = PCs[:,1]
df_PCA[!,"PC_2"] = PCs[:,2]
df_PCA[!,"PC_3"] = PCs[:,3]
df_PCA[!,"PC_4"] = PCs[:,4]
df_PCA[!,"PC_5"] = PCs[:,5]
df_PCA[!,"PC_6"] = PCs[:,6]
CSV.write("../../input/dfICA.csv", df_PCA)
df_PCA[!,"PC_1"] = (df_PCA[:,:PC_1] .- mean(df_PCA[:,:PC_1]))./std(df_PCA[:,:PC_1])
df_PCA[!,"PC_2"] = (df_PCA[:,:PC_2] .- mean(df_PCA[:,:PC_2]))./std(df_PCA[:,:PC_2])
df_PCA[!,"PC_3"] = (df_PCA[:,:PC_3] .- mean(df_PCA[:,:PC_3]))./std(df_PCA[:,:PC_3])
df_PCA[!,"PC_4"] = (df_PCA[:,:PC_4] .- mean(df_PCA[:,:PC_4]))./std(df_PCA[:,:PC_4])
df_PCA[!,"PC_5"] = (df_PCA[:,:PC_5] .- mean(df_PCA[:,:PC_5]))./std(df_PCA[:,:PC_5])
df_PCA[!,"PC_6"] = (df_PCA[:,:PC_6] .- mean(df_PCA[:,:PC_6]))./std(df_PCA[:,:PC_6])
CSV.write("../../input/dfICANorm.csv", df_PCA)

cont = Yte[:,df_labels.==0]
func = Yte[:,df_labels.==1]
Plots.scatter(transpose(M.W),label = ["ELAN" "LAN" "N400" "EPNP" "P600" "PNP"],title="ICA Components")
function dPrime(i)
    return (mean(cont[i,:]) - mean(func[i,:]))/var([cont[i,:]; func[i,:]])
end

# scatter(cont[1,:],cont[2,:],label="cont",title="ICA")
# scatter!(func[1,:],func[2,:],label="func")

# ELAN = Yte[1,:]
# LAN  = Yte[2,:]
# N400 = Yte[3,:]
# EPNP = Yte[4,:]
# P600 = Yte[5,:]
# PNP  = Yte[6,:]
# p = scatter(ELAN[1,:],ELAN[2,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
# scatter!(LAN[1,:],LAN[2,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
# scatter!(N400[1,:],N400[2,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
# scatter!(EPNP[1,:],EPNP[2,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
# scatter!(P600[1,:],P600[2,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
# scatter!(PNP[1,:],PNP[2,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

# plot(p,xlabel="PC1",ylabel="PC2",zlabel="PC3")

# p2 = scatter(ELAN[1,:],ELAN[2,:],marker=:circle,linewidth=0,label="ELAN")
# scatter!(LAN[1,:],LAN[2,:],marker=:circle,linewidth=0,label="LAN")
# scatter!(N400[1,:],N400[2,:],marker=:circle,linewidth=0,label="N400")
# scatter!(EPNP[1,:],EPNP[2,:],marker=:circle,linewidth=0,label="EPNP")
# scatter!(P600[1,:],P600[2,:],marker=:circle,linewidth=0,label="P600")
# scatter!(PNP[1,:],PNP[2,:],marker=:circle,linewidth=0,label="PNP")

# plot(p2,xlabel="PC1",ylabel="PC2")

# p3 = scatter(ELAN[1,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
# scatter!(LAN[1,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
# scatter!(N400[1,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
# scatter!(EPNP[1,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
# scatter!(P600[1,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
# scatter!(PNP[1,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

# plot(p3,xlabel="PC1",ylabel="PC3")

# p4 = scatter(ELAN[2,:],ELAN[3,:],marker=:circle,linewidth=0,label="ELAN")
# scatter!(LAN[2,:],LAN[3,:],marker=:circle,linewidth=0,label="LAN")
# scatter!(N400[2,:],N400[3,:],marker=:circle,linewidth=0,label="N400")
# scatter!(EPNP[2,:],EPNP[3,:],marker=:circle,linewidth=0,label="EPNP")
# scatter!(P600[2,:],P600[3,:],marker=:circle,linewidth=0,label="P600")
# scatter!(PNP[2,:],PNP[3,:],marker=:circle,linewidth=0,label="PNP")

# plot(p4,xlabel="PC2",ylabel="PC3")


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