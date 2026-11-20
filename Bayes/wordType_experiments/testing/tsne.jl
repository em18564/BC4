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
StatsPlots.theme(:ggplot2)

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
    "Verb Lex"
    "Verb Aux"
    "Adp Lex"
    "Adp Sub"
    "Adp Syn"
    "Adp Adv"
    "Det S"
    "Det DO"
    "Det IO"
    "Nou S"
    "Nou DO"
    "Nou IO"
]
a = StatsBase.mean(allData,dims=3)[:,:,1]#
b = StatsBase.std(allData,dims=3)[:,:,1]
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

M = fit(PCA,reorganisedData)
theme(:ggplot2)

default(
    titlefont = 24,
    guidefont = 24,     # x and y axis labels (xlabel/ylabel)
    tickfont = 16,      # axis tick numbers
    legendfont = 16
)
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
colIds = [
                    "#871a56","#a285ff",                                    # Adj Adv
                    "#ffe314","#f7bd7e","#ff5488","#f46200",                # Conj Num Prn Part
                    "#7e007f","#d730d9",                                    # Verbs (purples)
                    "#00bcc5","#017eed","#2400bb","#002b58",                # Adp (blueus)
                    "#72ff77","#72b800","#004617",                          # Dets (greens)
                    "#ff5e62","#be0016","#770014",                          # Nouns (reds)
                ]
cols = parse.(RGB, colIds)

means = predict(M,a)
vars  = predict(M,b)
plt = Plots.scatter()
for i in eachindex(wordTypesWithGramShort)
    θ = range(0, 2π, length = 100)
    ellipse_x = means[1,i] .+ 1.0 * vars[1,i] .* cos.(θ)
    ellipse_y = means[2,i] .+ 1.0 * vars[2,i] .* sin.(θ)
    plt = Plots.plot!(ellipse_x, ellipse_y, seriestype=:shape, fillalpha=0.3, c=cols[i],lw=0)
end

mapping = Dict(
    1=> weighted_color_mean(0.5,cols[1],cols[2]),
    2=> weighted_color_mean(0.5,cols[1],cols[2]),
    7=> weighted_color_mean(0.5,cols[7],cols[8]),
    8=> weighted_color_mean(0.5,cols[7],cols[8]),
    16=>cols[17],
    17=>cols[17],
    18=>cols[17],
)

# for i in eachindex(wordTypesWithGramShort)
    
#     if i in keys(mapping)
#         θ = range(0, 2π, length = 100)
#         ellipse_x = means[1,i] .+ 1.0 * vars[1,i] .* cos.(θ)
#         ellipse_y = means[2,i] .+ 1.0 * vars[2,i] .* sin.(θ)
#         plt = Plots.plot!(ellipse_x, ellipse_y, seriestype=:shape, fillalpha=0.0, linecolor=mapping[i]*0.5,lw=1.5)
#     end
    
# end
for i in eachindex(wordTypesWithGramShort)
    plt = annotate!(means[1,i]+0.015, means[2,i]+0.015, text(wordTypesWithGramShort[i], :left, 16,rotation =45))
end
plt = Plots.scatter!(   means[1,:],
                        means[2,:],
                        legend=false,
                        size=(1700,1700),
                        xlims=(-1.75,1.05),
                        ylims=(-1.5,1.3),
                        xticks=range(-1.5,1,6),
                        yticks=range(-1.5,1,6),
                        xminorticks=5,
                        yminorticks=5,
                        xlabel="PC1 of Posterior Samples (37.8% Variance)",
                        ylabel="PC2 of Posterior Samples (29.7% Variance)",
                        c=:black,
                        left_margin=7mm,
                        bg_inside   = "#E5ECF6")

plt
Plots.savefig("PCofSamples1.png")


# %%
theme(:ggplot2)
default(
    titlefont = 28,
    guidefont = 24,     # x and y axis labels (xlabel/ylabel)
    tickfont = 16,      # axis tick numbers
    legendfont = 16
)
xs = filtered
ys = StatsBase.mean(b,dims=1)[1,:]

plt2 = Plots.scatter(  xs,
                ys,
                xlims=(0, 370),
                ylims=(0, 0.265),
                xticks=range(0,350,8),
                yticks=range(0,0.25,6),
                xminorticks=5,
                yminorticks=5,
                c=cols,
                legend=false,
                bg_inside   = "#E5ECF6",
                size=(1800,1200),
                markersize=8,
                xlabel="Frequency of Word",
                ylabel="Mean Standard Deviation of Posterior Effect",
                left_margin=10mm,
                bottom_margin=8mm)
Plots.savefig("figs/meanStdEffectFX.png")


# %%
l = Matrix(CSV.read("loadings.csv",DataFrames.DataFrame,header=false))


allData2 = stack(stack(fullDataPoints2))
reshape(permutedims(allData2[:, :, 1:500], (3, 1, 2)),
               500, size(allData2, 1)*size(allData2, 2))

a2 = StatsBase.mean(allData2,dims=3)[:,:,1]#
b2 = StatsBase.std(allData2,dims=3)[:,:,1]



a1 = a2[Int.(range(1,6,6)),:]
a2 = a2[Int.(range(7,12,6)),:]

b1 = b2[Int.(range(1,6,6)),:]
b2 = b2[Int.(range(7,12,6)),:]
StatsPlots.theme(:ggplot2)
default(
    titlefont = 24,
    guidefont = 24,     # x and y axis labels (xlabel/ylabel)
    tickfont = 16,      # axis tick numbers
    legendfont = 16
)

pcint    = l*a1
pcgrad   = l*a2

pcint_v  = abs.(l*b1)
pcgrad_v = abs.(l*b2)
times = [150,350,400,500,600,650]
meanAndStd = Matrix(CSV.read("../../input/initScaledMeanStd.csv",DataFrames.DataFrame,header=false))



pcint  = (pcint.*meanAndStd[:,2]).+meanAndStd[:,1]
pcgrad = (pcgrad.*meanAndStd[:,2]).+meanAndStd[:,1]

pcint_v  = (pcint_v.*meanAndStd[:,2])
pcgrad_v = (pcgrad_v.*meanAndStd[:,2])




plots = []

for i in range(1,18)
    plt = Plots.hline([0], color=:black, label=false,bottom_margin=30mm,left_margin=30mm,title=wordTypes[i])
    plt = Plots.plot!(  times,
                        pcint[:,i],
                        bg_inside   = "#E5ECF6",
                        legend=false,
                        xlims=(150,650),
                        ylims=(-5,5),
                        ribbon =pcint_v,
                        fillalpha = 0.2,
                        c=:red,
                        xlabel="Time Post Stimulus (ms)",
                        ylabel="ERP Effect (R=Int, G=Grad)")
                        

    plt = Plots.plot!(  times,
                        pcgrad[:,i],
                        c=:green,
                        ribbon =pcint_v,
                        fillalpha = 0.25)
    

    push!(plots,plt)
end

Plots.plot(plots...,layout=grid(3,6),size=(4500,2200),right_margin=20mm)
Plots.savefig("figs/timeFrame.png")

# %%

