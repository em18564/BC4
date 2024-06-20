using TSne, Statistics, MLDatasets,CSV,DataFrames
df     = CSV.read("../../input/dfHierarchical.csv", DataFrame)
dfTags = CSV.read("../../input/full_tags.csv", DataFrame)
PCA_3  = CSV.read("../../input/dfPCA_3.csv", DataFrame)
PCA_4  = CSV.read("../../input/dfPCA_4.csv", DataFrame)
df[!,"tags"] = dfTags[!,"tags"]


dfWord = filter(row -> row.Participant==0, df)[:,"Word"]
dfTags = filter(row -> row.Participant==0, dfTags)
dfTags = dfTags[!,"tags"]
data = Matrix(select(df, ([:"ELAN", :"LAN",:"N400",:"EPNP",:"P600",:"PNP",:"tags"])))
Xtr_l    = transpose(data[1:2:end,:])
Xtr      = Xtr_l[1:6,:]
Ytr      = (Xtr_l[7,:])


rescale(Xtr; dims=1) = (Xtr .- mean(Xtr, dims=dims)) ./ max.(std(Xtr, dims=dims), eps())

alldata, allabels = MNIST.traindata(Float64);

# # Normalize the data, this should be done if there are large scale differences in the dataset
X = transpose(rescale(Xtr, dims=1));

Y = tsne(X, 2, 50, 1000, 20.0);

# using Plots
theplot = scatter(Y[:,1], Y[:,2], marker=(2,2,:auto,stroke(0)), color=Int.(Ytr[1:size(Y,1)]))
Plots.pdf(theplot, "myplot.pdf")
