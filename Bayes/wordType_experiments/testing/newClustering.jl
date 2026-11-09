# %%
using Pkg
Pkg.add(["Clustering", "DataFrames", "Plots", "Distances"]) # Install necessary packages
using Clustering
using DataFrames
using Plots
using Distances
using Random
#adjustedFullDataPoints = [vcat(fullDataPoints[i][5:17],fullDataPoints[i][1:4]) for i in eachindex(fullDataPoints)]
linkages = [:single,:average,:complete,:ward]
function coClusterMatrix(dataPonts,k)
    distances = zeros(17,17)
    fullAssginment = zeros(Int,length(fullDistances),17)
    for i in range(1,length(fullDistances))
        distance_matrix = fullDistances[i]
        dataMatrix = hcat(dataPonts[i]...)
        # tree = hclust(distance_matrix, linkage=linkage)
        # cluster_assignments = cutree(tree, k=k)
        cluster_assignments = kmeans(dataMatrix,k).assignments
        fullAssginment[i,:].=cluster_assignments
        for a in range(1,17)
            for b in range(1,17)
                if(cluster_assignments[a] != cluster_assignments[b])
                    distances[a,b]+=1/length(fullDistances)
                end
            end
        end
    end
    
    return distances,fullAssginment
    
    
end


function coClusterMatrixDBSCAN(k,minNeigh)
    distances = zeros(17,17)
    for i in range(1,4000)
        result = dbscan(hcat(fullDataPoints[i]...), k; min_neighbors=minNeigh)
        clusterScores = zeros(Int, 17)
        for cluster in eachindex(result.clusters)
            for id in result.clusters[cluster].core_indices
                clusterScores[id] = cluster
            end
        end
        for a in range(1,17)
            for b in range(1,17)
                if(clusterScores[a] != clusterScores[b])
                    distances[a,b]+=1/4000
                end
            end
        end
    end
    return distances
end
# %%
for link in linkages
    distances = ([coClusterMatrix(fullDataPoints,k)[1] for k in range(2,16)])
    tree = hclust(mean(distances), linkage=link)
    Plots.plot(tree,xticks=(tree.order,wordTypesWithGram),xrotation=90,bottom_margin=10mm)
    Plots.savefig("link_"*string(link)*".png")
end
# %%
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
listOfDistsAndAssign = [coClusterMatrix(fullDataPoints,k) for k in range(2,16)]
l = @layout [
    a{0.2h}
    grid(5,3)
]
listOfDists = [listOfDistsAndAssign[i][1] for i in range(1,length(listOfDistsAndAssign))]
innerAssignments = [listOfDistsAndAssign[i][2] for i in range(1,length(listOfDistsAndAssign))]



tree = hclust(mean(listOfDists), linkage=:ward)
listOfPlots = [Plots.plot(tree,xticks=(1:17,wordTypesWithGram[tree.order]),xrotation=90,bottom_margin=10mm,title="Pooled Clusters")]
for dist in eachindex(listOfDists)
    tree = hclust(listOfDists[dist], linkage=:ward)
    push!(listOfPlots,Plots.plot(tree,xticks=(1:17,wordTypesWithGramShort[tree.order]),xrotation=90,bottom_margin=10mm,title = string(dist+1)*" clusters"))
end
Plots.plot(listOfPlots...; layout=l, size = (1200, 1900))
Plots.savefig("combClust2.png")

# %%
data = rand(2, 100) * 10

# Run DBSCAN (radius = 1.5, min_neighbors = 5)
result = dbscan(hcat(fullDataPoints[2]...), 1.25; min_neighbors=3)

println("Number of clusters: ", length(result.clusters))
println("Cluster sizes: ", [c.size for c in result.clusters])

# %%
using Distances
using NearestNeighbors
using Plots
# 1. Sample data (n points, d dimensions)
avgK = zeros(17)
Xfull = [hcat(fullDataPoints[i]...) for i in eachindex(fullDataPoints)]
for i in eachindex(Xfull)
    X = Xfull[i]
    # 2. Choose k (e.g., k = 4, which is minPts = 4 for DBSCAN)
    k = 4
    tree = KDTree(X)
    idxs, dists = knn(tree, X, k, true) 
    k_distances = [d[k] for d in dists]
    sorted_k_dists = sort(k_distances)
    avgK+=sorted_k_dists/length(Xfull)
end


# 5. Plot the k-distance graph to find the "elbow"
Plots.plot(avgK, 
     xlabel = "Sorted Points",
     ylabel = "k value",
     label = "k-distance graph",
     legend = :topleft)

# %%
d = coClusterMatrixDBSCAN(1.25,5)
t2 = hclust(d,linkage=:ward)
Plots.plot(t2,xticks=(1:length(wordTypesWithGram),wordTypesWithGram),xrotation=90,bottom_margin=10mm,title="dbscan Clusters")


# %%

groundTruthAssignments = [cutree(hclust(listOfDists[k-1],linkage=:ward),k=k) for k in range(2,16)]
aris = zeros(15,8000)

for i in range(1,15)
    for j in range(1,8000)
        aris[i,j] = randindex(innerAssignments[i][j,:], groundTruthAssignments[i])[1]
    end
end
# %%
histPlots = []
means = [mean(aris[i,:]) for i in range(1,15)]
for i in range(1,15)
    push!(histPlots,Plots.histogram(aris[i,:],title="ARIs: "* string(i+1) *" clusters",bins=100,label=false,xlim=(minimum(aris),1)))
    histPlots[i] = vline!([mean(aris[i,:])], color=:red, linewidth=2, linestyle=:dash, label="Mean: " * string(round(means[i],digits=3)))
end
Plots.plot(histPlots...,layout=grid(5,3),size=(1200,900))
Plots.savefig("figs/aris.png")

# %%

combined = (means/sum(means)).*listOfDists
l = @layout [
    a{0.2h}
    grid(5,3)
]
tree = hclust(sum(combined), linkage=:ward)
listOfPlots = [Plots.plot(tree,xticks=(tree.order,wordTypesWithGram),xrotation=90,bottom_margin=10mm,title="Pooled Clusters scaled by mean ARI scores")]
for dist in eachindex(listOfDists)
    tree = hclust(listOfDists[dist], linkage=:ward)
    push!(listOfPlots,Plots.plot(tree,xticks=(tree.order,wordTypesWithGramShort),xrotation=90,bottom_margin=10mm,title = string(dist+1)*" clusters"))
end
Plots.plot(listOfPlots...; layout=l, size = (1200, 1900))

#Plots.savefig("combinedClustering3.png")

# %%
