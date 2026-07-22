# %%

include("../setup.jl")
include("../typeStructures.jl")
include("../model_master.jl")
include("../plottingFuncs.jl")
#using SkipNan
using ExactOptimalTransport,OptimalTransport
using KernelDensity

using SlicedWasserstein
using PhyloTrees
using Phylo
# 1 Adj
# 2 Adp
# 3 Adv
# 4 Conj
# 5 Det
# 6 Noun
# 7 Num
# 8 Pron
# 9 Prt
# 10 Verb
#%% 
meanAndStdInfo = CSV.read("../input/meanAndStdInfo.csv",DataFrame)
outputDir="models/testingDifferentPCS/output_FullADP_23_1931_6PCA"                  
wordTypes_old = ["Adjective","Adposition","Adverb",
                        "Conjunction","Determiner","Noun","Numeral",
                        "Pronoun","Particle","Verb"]
wordTypes = ["Adjective","Adverb",
            "Conjunction","Determiner","Noun","Numeral", 
            "Pronoun","Particle","Verb","Adposition (lex)", "Adposition (sub)", "Adposition (syn)"]
cols = [palette(:default)[i] for i in range(1,length(wordTypes))]
chn1 = deserialize(outputDir*"/out1.jls")
chn2 = deserialize(outputDir*"/out2.jls")
chn3 = deserialize(outputDir*"/out3.jls")
chn4 = deserialize(outputDir*"/out4.jls")
chn5 = deserialize(outputDir*"/out5.jls")
chn6 = deserialize(outputDir*"/out6.jls")
chn_df1 = DataFrames.DataFrame(chn1)
chn_df2 = DataFrames.DataFrame(chn2)
chn_df3 = DataFrames.DataFrame(chn3)
chn_df4 = DataFrames.DataFrame(chn4)
chn_df5 = DataFrames.DataFrame(chn5)
chn_df6 = DataFrames.DataFrame(chn6)
ss_df1  = DataFrames.DataFrame(summarystats(chn1))
ss_df2  = DataFrames.DataFrame(summarystats(chn2))
ss_df3  = DataFrames.DataFrame(summarystats(chn3))
ss_df4  = DataFrames.DataFrame(summarystats(chn4))
ss_df5  = DataFrames.DataFrame(summarystats(chn5))
ss_df6  = DataFrames.DataFrame(summarystats(chn6))
show(stdout,"text/plain",summarystats(chn1))
prob = repeat([1.0/length(chn_df1[!,"a_ws[1]"])], length(chn_df1[!,"a_ws[1]"]))
chndfs  = [chn_df1, chn_df2, chn_df3, chn_df4, chn_df5, chn_df6]
ssdfs   = [ss_df1,  ss_df2,  ss_df3,  ss_df4,  ss_df5,  ss_df6 ]

# %%
function wasserstein_samples(x, y)
    x = sort(x)
    y = sort(y)
    return mean(abs.(x .- y))
end


function getDataFromFirstXchains(noChains)
    innerChndfs = chndfs[1:noChains]
    innerSsdfs  = ssdfs[1:noChains]
    wi      = zeros(noChains,length(wordTypes))
    wg      = zeros(noChains,length(wordTypes))
    wistd   = zeros(noChains,length(wordTypes))
    wgstd   = zeros(noChains,length(wordTypes))
    wi_dist = Array{DiscreteNonParametric}(undef,noChains,length(wordTypes))
    wg_dist = Array{DiscreteNonParametric}(undef,noChains,length(wordTypes))
    wi_samples = Array{Vector}(undef,noChains,length(wordTypes))
    wg_samples = Array{Vector}(undef,noChains,length(wordTypes))
    wi_samps2  = Array{Vector}(undef,noChains,length(wordTypes))
    wg_samps2  = Array{Vector}(undef,noChains,length(wordTypes))
    wi_samps3  = Array{Vector}(undef,noChains,length(wordTypes))
    wg_samps3  = Array{Vector}(undef,noChains,length(wordTypes))

    for i in range(1,length(innerSsdfs))
        wordsInt      = [innerSsdfs[i][string.(ss_df1.parameters).=="a_ws["*string(w)*"]","mean"] for w in range(1,length(wordTypes))]
        wordsGrad     = [innerSsdfs[i][string.(ss_df1.parameters).=="b_ws["*string(w)*"]","mean"] for w in range(1,length(wordTypes))]
        wordsIntstd   = [innerSsdfs[i][string.(ss_df1.parameters).=="a_ws["*string(w)*"]","std"] for w in range(1,length(wordTypes))]
        wordsGradstd  = [innerSsdfs[i][string.(ss_df1.parameters).=="b_ws["*string(w)*"]","std"] for w in range(1,length(wordTypes))]
        wordsDistInt  = [DiscreteNonParametric(innerChndfs[i][!,"a_ws["*string(w)*"]"],prob) for w in range(1,length(wordTypes))]
        wordsDistGrad = [DiscreteNonParametric(innerChndfs[i][!,"b_ws["*string(w)*"]"],prob) for w in range(1,length(wordTypes))]
        for j in range(1,length(wordTypes))
            wi[i,j] = wordsInt[j][1]
            wg[i,j] = wordsGrad[j][1]
            wistd[i,j] = wordsIntstd[j][1]
            wgstd[i,j] = wordsGradstd[j][1]
            wi_dist[i,j] = wordsDistInt[j]
            wg_dist[i,j] = wordsDistGrad[j]
            wi_samples[i,j] = innerChndfs[i][!,"a_ws["*string(j)*"]"]
            wg_samples[i,j] = innerChndfs[i][!,"b_ws["*string(j)*"]"]
            wi_samps2[i,j]  = innerChndfs[i][!,"a_ws["*string(j)*"]"].*innerChndfs[i][!,"σ_aw"]
            wg_samps2[i,j]  = innerChndfs[i][!,"b_ws["*string(j)*"]"].*innerChndfs[i][!,"σ_bw"]

            wi_samps3[i,j]  = innerChndfs[i][!,"a_ws["*string(j)*"]"].*innerChndfs[i][!,"σ_aw"]*meanAndStdInfo.std[i]
            wg_samps3[i,j]  = innerChndfs[i][!,"b_ws["*string(j)*"]"].*innerChndfs[i][!,"σ_bw"]*meanAndStdInfo.std[i]
        end
    end
    dists        = vcat(wi_dist,wg_dist)
    samples      = vcat(wi_samples,wg_samples)
    wordVals     = vcat(wi,wg)
    wordVals_std = vcat(wistd,wgstd)
    wordVals_w   = zeros(2*noChains,length(wordTypes))
    samps_2      = vcat(wi_samps2,wg_samps2)
    samps_3      = vcat(wi_samps3,wg_samps3)
    return samps_2,samps_3
end

datasets = [getDataFromFirstXchains(x) for x in 1:6]

# %%
function whiten(row)
    return (row.-mean(row))./std(row)
end
for i in range(1,8)
    wordVals_w[i,:] = whiten(wordVals[i,:])
end


function cosdist(data)
    dist = zeros(length(wordTypes),length(wordTypes))
    for i in range(1,length(wordTypes))
        for j in range(1,length(wordTypes))
            dist[i,j] = cosine_dist(data[:,i],data[:,j])
        end
    end
    return dist
end




function wasDist(data,datastd)
    dist = zeros(length(wordTypes),length(wordTypes))
    for i in range(1,length(wordTypes))
        for j in range(1,length(wordTypes))
            wasdists = zeros(8)
            for distr in range(1,8)
                wasdists[distr]=wasserstein(Normal(data[distr,i],datastd[distr,i]),Normal(data[distr,j],datastd[distr,j]))
            end
            dist[i,j] = norm(wasdists)
            dist[j,i] = norm(wasdists)
        end
    end
    return dist
end

function wasDist2(data)
    weights = fill(1/8, 8)
    dist = zeros(length(wordTypes),length(wordTypes))
    for i in range(1,length(wordTypes))
        for j in range(1,length(wordTypes))
            wasdists = [wasserstein(a,b) for a in data[:,i], b in data[:,j]]
            optimizer = MathOptInterface.instantiate(Clp.Optimizer; with_cache_type=Float64)
            dist[i,j] = emd2(weights, weights, wasdists, optimizer)
            dist[j,i] = dist[i,j]
        end
    end
    return dist
end


function wasDist3(data)
    weights = fill(1/8, 8)
    dist = zeros(length(wordTypes),length(wordTypes))
    for i in range(1,length(wordTypes))
        for j in range(1,length(wordTypes))
            wasdists = [wasserstein_samples(a,b) for a in data[:,i], b in data[:,j]]
            optimizer = MathOptInterface.instantiate(Clp.Optimizer; with_cache_type=Float64)
            dist[i,j] = emd2(weights, weights, wasdists, optimizer)
            dist[j,i] = dist[i,j]
        end
    end
    return dist
end


function slicedWasDist(data)
    n = length(data[1,:])
    dist = zeros(n,n)
    for i in range(1,n)
        for j in range(1,n)
            μ = DiscreteMeasure(transpose(stack(data[:,i])))
            ν = DiscreteMeasure(transpose(stack(data[:,j])))
            sot = SOT(μ, ν)
            dist[i,j] = sqrt(sot)
            dist[j,i] = dist[i,j]
        end
    end
    return dist
end



function splitTree(data,structure,quantity)
    if typeof(structure) == Int64
        samps = sample(1:1000,quantity)
        return [data[i,structure][samps] for i in eachindex(data[:,1])]

    else
        d1 = splitTree(data,structure[1],Int64(floor(quantity/2)))
        d2 = splitTree(data,structure[2],Int64(ceil(quantity/2)))
        return [vcat(d1[i],d2[i]) for i in eachindex(data[:,1])]
    end
end
function editStructure(structure,clustPos,clusterDistance,structureWithDistance)
    clustPosSorted = [min(clustPos[1],clustPos[2]),max(clustPos[1],clustPos[2])]
    clust          = [structure[clustPosSorted[1]],structure[clustPosSorted[2]]]
    clustDist      = [structureWithDistance[clustPosSorted[1]],structureWithDistance[clustPosSorted[2]]]
    newStructure   = []
    newStructureWithDistances = []
    
    for item in structure
        push!(newStructure,item)
    end

    for item in structureWithDistance
        push!(newStructureWithDistances,item)
    end

    deleteat!(newStructure,clustPosSorted[1])
    deleteat!(newStructure,clustPosSorted[2]-1)

    deleteat!(newStructureWithDistances,clustPosSorted[1])
    deleteat!(newStructureWithDistances,clustPosSorted[2]-1)

    push!(newStructureWithDistances,(clusterDistance,clustDist))
    push!(newStructure,clust)
    return newStructure,newStructureWithDistances
end

function shrinkTree(data,structure=collect(1:length(wordTypes)),structureWithDistance=structure)
    sortedData = []
    for i in eachindex(structure)
        curData = splitTree(data,structure[i],1000)
        push!(sortedData,curData)
    end
    sortedData = stack(sortedData)
    distances = slicedWasDist(sortedData)
    hc        = hclust(distances, linkage=:ward)
    clustPos  = [-hc.merges[1,1],-hc.merges[1,2]]
    newStructure,newStructureWithDistances = editStructure(structure,clustPos,hc.heights[1],structureWithDistance)
    if length(newStructure) == 1
        return newStructure,newStructureWithDistances
    else
        return shrinkTree(data,newStructure,newStructureWithDistances)
    end
end

function traverseTree(structure)
    tree = NamedBinaryTree()
    createnode!(tree, "root")
    return traverseTree(tree,structure[1],"root")
end
function traverseTree(tree,structure,node)
    b1 = structure[2][1]
    b2 = structure[2][2]
    dist = structure[1]
    if typeof(b1) == Int64
        word =  wordTypes[b1]
        createnode!(tree,word)
        createbranch!(tree, node, word,dist)
    else
        innerBranch = node * "_b1"
        createnode!(tree,innerBranch)
        createbranch!(tree, node, innerBranch, dist-b1[1])
        traverseTree(tree,b1,innerBranch)
    end

    if typeof(b2) == Int64
        word =  wordTypes[b2]
        createnode!(tree,word)
        createbranch!(tree, node, word,dist)
    else
        innerBranch = node * "_b2"
        createnode!(tree,innerBranch)
        createbranch!(tree, node, innerBranch, abs(dist-b2[1]))
        traverseTree(tree,b2,innerBranch)
    end

    return tree
end

# function dendrogram(distances,link,ylab,xlab)
    
#     hc = hclust(distances, linkage=link)
#     xlabs = [wordTypes[i] for i in hc.order]
    
#     return Plots.plot(hc,xticks=(1:length(wordTypes),xlabs),
#                 ylabel=ylab,
#                 xlabel=xlab,
#                 right_margin=10mm,
#                 left_margin=30mm,
#                 bottom_margin=20mm,
#                 top_margin=10mm,size=(900,500))

# end
# types = [:single,:average,:complete,:ward]
# ds = []
# for i in range(1,length(types))
#     t = types[i]
#     ylab1 = ""
#     ylab2 = ""
#     ylab3 = ""
#     ylab4 = ""
#     ylab5 = ""
#     if i == 1
#         ylab1 = "base"
#         ylab2 = "whitened"
#         ylab3 = "wasserstein distance (of normals)"
#         ylab4 = "wasserstein distance (of raw sampled data * sigma w)"
#         ylab5 = "sliced-wasserstein distance"
#     end
#     d1 = dendrogram(cosdist(wordVals),t,ylab1,"")
#     d2 = dendrogram(cosdist(wordVals_w),t,ylab2,"")
#     d3 = dendrogram(wasDist(wordVals,wordVals_std),t,ylab3,String(t))
#     d4 = dendrogram(wasDist3(samps_2),t,ylab4,String(t))
#     d5 = dendrogram(slicedWasDist(samps_2),t,ylab5,String(t))
#     ds = vcat(ds,d1,d2,d3,d4,d5)
# end


# p = Plots.plot( ds[1],ds[6], ds[11],ds[16],
#                 ds[2],ds[7], ds[12],ds[17],
#                 ds[3],ds[8], ds[13],ds[18],
#                 ds[4],ds[9], ds[14],ds[19],
#                 ds[5],ds[10],ds[15],ds[20],
#             layout = grid(5, 4),size=(5000,4000))

# Plots.savefig(p,"figs/wordType/fullDendrogram.png")
# %%
# distances = slicedWasDist(samps_2)

#dendrogram(slicedWasDist(samps_2),:ward,"Sliced-Wasserstein L2 distance","Word-type")



# %%
structure,structure_d = shrinkTree(samps_2)
tree = traverseTree(structure_d)
plt = Plots.plot(tree, treetype=:dendrogram)
Plots.savefig(plt,"figs/wordType/dendro_joined_ADP.png")


structure,structure_d = shrinkTree(samps_3)
tree = traverseTree(structure_d)
plt = Plots.plot(tree, treetype=:dendrogram)
Plots.savefig(plt,"figs/wordType/dendro_joined_ADP_unwhitened.png")

# %%
plts = []
for i in range(1,6)
    println(i)
    println("______")
    println("First Struct")
    _,structure_d   = shrinkTree(datasets[i][1])
    println("Second Struct")
    _,structure_d_uw = shrinkTree(datasets[i][2])
    tree = traverseTree(structure_d)
    tree_uw = traverseTree(structure_d_uw)

    if i == 6
        plt = Plots.plot(tree, treetype=:dendrogram,ylabel=string(i)*" Principal Components",xlabel="Whitened")
        plt_uw = Plots.plot(tree_uw, treetype=:dendrogram,xlabel="Unwhitened")
    else
        plt = Plots.plot(tree, treetype=:dendrogram,ylabel=string(i)*" Principal Components")
        plt_uw = Plots.plot(tree_uw, treetype=:dendrogram)
    end
    
    push!(plts,[plt,plt_uw])
end

# %%

p = Plots.plot( ds[1],ds[6], ds[11],ds[16],
                ds[2],ds[7], ds[12],ds[17],
                ds[3],ds[8], ds[13],ds[18],
                ds[4],ds[9], ds[14],ds[19],
                ds[5],ds[10],ds[15],ds[20],
            layout = grid(5, 4),size=(5000,4000))

Plots.savefig(p,"figs/wordType/fullDendrogram_withUnwhitened.png")


# %%

