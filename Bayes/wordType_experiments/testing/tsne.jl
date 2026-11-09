using TSne, Statistics, MLDatasets

# %%
rescale(A; dims=1) = (A .- mean(A, dims=dims)) ./ max.(std(A, dims=dims), eps())

alldata, allabels = MNIST.traindata(Float64);


data = reshape(permutedims(alldata[:, :, 1:500], (3, 1, 2)),
               500, size(alldata, 1)*size(alldata, 2));
# Normalize the data, this should be done if there are large scale differences in the dataset
X = rescale(data, dims=1);

Y = tsne(X, 2, 50, 1000, 20.0);

using Plots
theplot = Plots.scatter(Y[:,1], Y[:,2], marker=(2,2,:circle,stroke(0)), color=Int.(allabels[1:size(Y,1)]))
#Plots.pdf(theplot, "myplot.pdf")
# %%
allData = stack(stack(fullDataPoints))

N = 20
sampleIndexes = sample(1:8000, N, replace = false)
data = reshape(permutedims(allData[:, :, sampleIndexes], (3, 2, 1)),
               N*size(allData, 2), size(allData, 1));
labels = repeat(wordTypesWithGram,Int(size(data,1)/length(wordTypesWithGram)))
X = rescale(data, dims=1);
Y = tsne(X, 2, 0, 1000, 30.0);
# %%
plt = Plots.plot()
for wordType in wordTypesWithGram
    indexes = findall(x->x==wordType,labels)
    plt = Plots.scatter!(Y[indexes,1], Y[indexes,2], marker=(2,2,:circle,stroke(0)),label=wordType)
end
Plots.savefig(plt,"figs/tsne.png")




# %%
using MultivariateStats
theme(:ggplot2)

allData = stack(stack(fullDataPoints))
reshape(permutedims(allData[:, :, 1:500], (3, 1, 2)),
               500, size(allData, 1)*size(allData, 2))
wordTypesWithGramShort = [
    "Adj"
    "Adv"
    "Con"
    "Num"
    "Pron"
    "Part"
    "Verb"
    "Adp Le"
    "Adp Su"
    "Adp Sy"
    "Adp Ad"
    "Det S"
    "Det DO"
    "Det IO"
    "Nou S"
    "Nou DO"
    "Nou IO"
]
a = mean(allData,dims=3)[:,:,1]#
b = std(allData,dims=3)[:,:,1]
comb = fit(PCA, a; maxoutdim=3)
comb2 = fit(PCA, b; maxoutdim=3)
xs = predict(comb,a)[1,:]
stdxs = predict(comb2,b)[1,:]
stdys = predict(comb2,b)[2,:]
stdzs = predict(comb2,b)[3,:]
ys = predict(comb,a)[2,:]
zs = predict(comb,a)[3,:]
plt = Plots.scatter(xs,ys,legend=false)
for i in eachindex(wordTypesWithGramShort)
    plt = annotate!(xs[i], ys[i]-0.03, text(wordTypesWithGramShort[i], :center, 5),camera = (5, 15))
    # θ = range(0, 2π, length = 100)
    # ellipse_x = xs[i] .+ 1.0 * stdxs[i] .* cos.(θ)
    # ellipse_y = ys[i] .+ 1.0 * stdys[i] .* sin.(θ)
    # Plots.plot!(ellipse_x, ellipse_y, seriestype=:shape, fillalpha=0.1, c=:orange)
end
plt

# %%

# Sample data: x, mean (μ), and standard deviation (σ)
x = randn(100) .+ 2.0
y = 0.5 .* x .+ randn(100)

# 2. Calculate mean and standard deviation
mx, my = mean(x), mean(y)
sx, sy = std(x), std(y)

# 3. Create parametric points for a 1-SD oval (or 2-SD by multiplying sx, sy by 2)
θ = range(0, 2π, length = 100)
ellipse_x = mx .+ 1.0 * sx .* cos.(θ)
ellipse_y = my .+ 1.0 * sy .* sin.(θ)

# 4. Plot scatter data and overlay the oval
Plots.scatter(x, y, label="Data", alpha=0.6)


# %%
reorganisedData = stack(vcat(fullDataPoints...))

M = fit(PCA,reorganisedData ;maxoutdim=2)

# xPoints = []
# yPoints = []
# stdsx = []
# stdsy = []
# for i in eachindex(wordTypesWithGramShort)
#     pred = predict(M,reorganisedData[:,1+(8000*(i-1)):8000*i])
#     xs = pred[1,:]
#     ys = pred[2,:]
#     push!(xPoints,mean(xs))
#     push!(yPoints,mean(ys))
#     push!(stdsx,std(xs))
#     push!(stdsy,std(ys))
# end
# 


means = predict(M,a)
vars  = predict(M,b)

plt = Plots.scatter(means[1,:],means[2,:],legend=false,size=(800,800),xlims=(-1.6,1),ylims=(-0.9,0.8),xlabel="PC1 of posterior samples (37.8% variance)",ylabel="PC2 of posterior samples (29.7% variance)")
for i in eachindex(wordTypesWithGramShort)
    plt = annotate!(means[1,i], means[2,i]-0.02, text(wordTypesWithGramShort[i], :center, 7))
    θ = range(0, 2π, length = 100)
    ellipse_x = means[1,i] .+ 1.0 * vars[1,i] .* cos.(θ)
    ellipse_y = means[2,i] .+ 1.0 * vars[2,i] .* sin.(θ)
    plt = Plots.plot!(ellipse_x, ellipse_y, seriestype=:shape, fillalpha=0.05, c=:orange)
end
plt
Plots.savefig("PCofSamples.png")