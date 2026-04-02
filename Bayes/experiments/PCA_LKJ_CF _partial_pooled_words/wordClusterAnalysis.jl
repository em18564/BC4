# %%
# using Random
using StatsBase
using Distributions
using StatsPlots
using StatsFuns
using Logging

using Turing
using CSV
using DataFrames
using Plots
using MCMCDiagnosticTools
using MCMCChains
using Serialization
using PlotlyJS
using Images, FileIO
using Clustering
using Measures
using DataStructures
# using Plots
# using Gadfly
# import Cairo, Fontconfig
# %%


df = CSV.read("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/usedDF.csv",DataFrame)
chn1 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/out1.jls")
chn2 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/out2.jls")
chn3 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/out3.jls")
chn4 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/out4.jls")
chn_df1 = DataFrames.DataFrame(chn1)
chn_df2 = DataFrames.DataFrame(chn2)
chn_df3 = DataFrames.DataFrame(chn3)
chn_df4 = DataFrames.DataFrame(chn4)

gr(size=(1800,800), dpi=600)
chns = [chn1,chn2,chn3,chn4]
plts = []
colNames = String.(Vector(DataFrames.DataFrame(summarystats(chns[1]; append_chains=true)).parameters))

as    = vcat(   findall(x -> startswith(x, "a_ws"), colNames),
                findall(x -> startswith(x, "a_wts"), colNames),
                findall(x -> startswith(x, "a_ps"), colNames),
                findall(x -> startswith(x, "a_e"), colNames))
alabs = vcat(   filter(x -> startswith(x, "a_ws"), colNames),
                filter(x -> startswith(x, "a_wts"), colNames),
                filter(x -> startswith(x, "a_ps"), colNames),
                filter(x -> startswith(x, "a_e"), colNames))
alabs = map(x -> startswith(x, "a_ws") ? "Word" :
                 startswith(x, "a_wts") ? "Word-Type" :
                 startswith(x, "a_ps") ? "Participant" : 
                 startswith(x, "a_e") ? "Intercept" : x, alabs)
bs    = vcat(   findall(x -> startswith(x, "b_ws"), colNames),
                findall(x -> startswith(x, "b_wts"), colNames),
                findall(x -> startswith(x, "b_ps"), colNames),
                findall(x -> startswith(x, "b_e"), colNames))
blabs = vcat(   filter(x -> startswith(x, "b_ws"), colNames),
                filter(x -> startswith(x, "b_wts"), colNames),
                filter(x -> startswith(x, "b_ps"), colNames),
                filter(x -> startswith(x, "b_e"), colNames))
blabs = map(x -> startswith(x, "b_ws") ? "Word" :
                 startswith(x, "b_wts") ? "Word-Type" : 
                 startswith(x, "b_ps") ? "Participant" : 
                 startswith(x, "b_e") ? "Intercept" : x, blabs)
σs    = vcat(   findall(x -> startswith(x, "σ"), colNames))
σlabs = vcat(   filter(x -> startswith(x, "σ"), colNames))
σlabs = map(x -> startswith(x, "σ_awt") ? "Word-Type" :
                 startswith(x, "σ_bwt") ? "Word-Type" :
                 startswith(x, "σ_aw") ? "Word" :
                 startswith(x, "σ_bw") ? "Word" :
                 startswith(x, "σ_ap") ? "Participant" : 
                 startswith(x, "σ_bp") ? "Participant" : 
                 startswith(x, "σ_ae") ? "Intercept" :
                 startswith(x, "σ_be") ? "Intercept" : x, σlabs)

for i in range(1,4)

    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][as],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][as],xlabel = "R-hat",ylabel = "ess (as)",title="PC " * string(i),group=alabs)
    push!(plts,myplot)
    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][bs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][bs],xlabel = "R-hat",ylabel = "ess (bs)",group=blabs)
    push!(plts,myplot)
    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][σs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][σs],xlabel = "R-hat",ylabel = "ess (σs)",group=σlabs)
    push!(plts,myplot)
end

essRhat = Plots.plot(   plts[1],plts[4],plts[7],plts[10],
                        plts[2],plts[5],plts[8],plts[11],
                        plts[3],plts[6],plts[9],plts[12]
                        ,layout=grid(3,4),left_margin=15mm,bottom_margin=15mm
                        ,plot_title="EssRhat partially pooled with word type (262 unique words, 3 participants)")
Plots.savefig(essRhat,"PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withWT/essRhat.png")

















# %%

df = CSV.read("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/usedDF.csv",DataFrame)
chn1 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/out1.jls")
chn2 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/out2.jls")
chn3 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/out3.jls")
chn4 = deserialize("PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/out4.jls")
chn_df1 = DataFrames.DataFrame(chn1)
chn_df2 = DataFrames.DataFrame(chn2)
chn_df3 = DataFrames.DataFrame(chn3)
chn_df4 = DataFrames.DataFrame(chn4)
# %%
gr(size=(1800,800), dpi=600)
chns = [chn1,chn2,chn3,chn4]
plts = []
colNames = String.(Vector(DataFrames.DataFrame(summarystats(chns[1]; append_chains=true)).parameters))

as    = vcat(   findall(x -> startswith(x, "a_ws"), colNames),
                findall(x -> startswith(x, "a_ps"), colNames),
                findall(x -> startswith(x, "a_e"), colNames))
alabs = vcat(   filter(x -> startswith(x, "a_ws"), colNames),
                filter(x -> startswith(x, "a_ps"), colNames),
                filter(x -> startswith(x, "a_e"), colNames))
alabs = map(x -> startswith(x, "a_ws") ? "Word" :
                 startswith(x, "a_ps") ? "Participant" : 
                 startswith(x, "a_e") ? "Intercept" : x, alabs)
bs    = vcat(   findall(x -> startswith(x, "b_ws"), colNames),
                findall(x -> startswith(x, "b_ps"), colNames),
                findall(x -> startswith(x, "b_e"), colNames))
blabs = vcat(   filter(x -> startswith(x, "b_ws"), colNames),
                filter(x -> startswith(x, "b_ps"), colNames),
                filter(x -> startswith(x, "b_e"), colNames))
blabs = map(x -> startswith(x, "b_ws") ? "Word" :
                 startswith(x, "b_ps") ? "Participant" : 
                 startswith(x, "b_e") ? "Intercept" : x, blabs)
σs    = vcat(   findall(x -> startswith(x, "σ"), colNames))
σlabs = vcat(   filter(x -> startswith(x, "σ"), colNames))
σlabs = map(x -> startswith(x, "σ_aw") ? "Word" :
                 startswith(x, "σ_bw") ? "Word" :
                 startswith(x, "σ_ap") ? "Participant" : 
                 startswith(x, "σ_bp") ? "Participant" : 
                 startswith(x, "σ_ae") ? "Intercept" :
                 startswith(x, "σ_be") ? "Intercept" : x, σlabs)

for i in range(1,4)

    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][as],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][as],xlabel = "R-hat",ylabel = "ess (as)",title="PC " * string(i),group=alabs)
    push!(plts,myplot)
    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][bs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][bs],xlabel = "R-hat",ylabel = "ess (bs)",group=blabs)
    push!(plts,myplot)
    myplot = Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"][σs],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"][σs],xlabel = "R-hat",ylabel = "ess (σs)",group=σlabs)
    push!(plts,myplot)
end

essRhat = Plots.plot(   plts[1],plts[4],plts[7],plts[10],
                        plts[2],plts[5],plts[8],plts[11],
                        plts[3],plts[6],plts[9],plts[12]
                        ,layout=grid(3,4),left_margin=15mm,bottom_margin=15mm
                        ,plot_title="EssRhat partially pooled without word type (262 unique words, 3 participants)")
Plots.savefig(essRhat,"PCA_LKJ_CF _partial_pooled_words/noLKJ/output_withoutWT/essRhat.png")











# %%
uwords = maximum(df.uniqueWordId)
df1 = DataFrame(summarystats(chn1))[!,["parameters","mean"]]
df2 = DataFrame(summarystats(chn2))[!,["parameters","mean"]]
df3 = DataFrame(summarystats(chn3))[!,["parameters","mean"]]
df4 = DataFrame(summarystats(chn4))[!,["parameters","mean"]]
wordDataset = DataFrame(word=1:uwords,  a1=df1[2:2+uwords-1,:].mean,b1=df1[uwords+3:2+2*uwords,:].mean,
                                        a2=df2[2:2+uwords-1,:].mean,b2=df2[uwords+3:2+2*uwords,:].mean,
                                        a3=df3[2:2+uwords-1,:].mean,b3=df3[uwords+3:2+2*uwords,:].mean,
                                        a4=df4[2:2+uwords-1,:].mean,b4=df4[uwords+3:2+2*uwords,:].mean)

x = transpose(Matrix(wordDataset)[:,2:9])
y = Matrix(wordDataset)[:,1]
nclusters = 2
R = kmeans(x, nclusters; maxiter=200, display=:iter)
a = assignments(R) # get the assignments of points to clusters
c = counts(R) # get the cluster sizes
M = R.centers # get the cluster centers
mapping = df[!,["uniqueWordId","fullTag"]]
sort!(mapping)
mapping = unique(mapping)
pairs = DataFrame(predicted=a,actual=mapping.fullTag)
sort!(pairs)
# 0 Adj
# 1 Adp
# 2 Adv
# 3 Conj
# 4 Det
# 5 Noun
# 6 Num
# 7 Pron
# 8 Prt
# 9 Verb
# 10 X
vals = zeros(nclusters,11)
for i in range(1,nclusters)
    c = counter(pairs[pairs.predicted .== i, :].actual)
    for k in keys(c)
        vals[i,k+1] = c[k]
    end
end
ctg = repeat(["Adj", "Avp", "Adv", "Conj", "Det", "Noun", "Num", "Pron", "Prt", "Verb", "X"], inner = nclusters)

groupedbar(vals, bar_position = :stack, bar_width=0.7, group = ctg)
