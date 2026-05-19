# %%

include("../setup.jl")
include("../typeStructures.jl")
include("../model_master.jl")
include("../plottingFuncs.jl")
using SkipNan
using ExactOptimalTransport
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
#%% 




outputDir="models/exponentials/output_Full_23_1931"
wordTypes = ["Adjective","Adposition","Adverb",
                        "Conjunction","Determiner","Noun","Numeral",
                        "Pronoun","Particle","Verb"]
cols = [palette(:tab10)[i] for i in range(1,10)]
chn1 = deserialize(outputDir*"/out1.jls")
chn2 = deserialize(outputDir*"/out2.jls")
chn3 = deserialize(outputDir*"/out3.jls")
chn4 = deserialize(outputDir*"/out4.jls")
chn_df1 = DataFrames.DataFrame(chn1)
chn_df2 = DataFrames.DataFrame(chn2)
chn_df3 = DataFrames.DataFrame(chn3)
chn_df4 = DataFrames.DataFrame(chn4)
ss_df1  = DataFrames.DataFrame(summarystats(chn1))
ss_df2  = DataFrames.DataFrame(summarystats(chn2))
ss_df3  = DataFrames.DataFrame(summarystats(chn3))
ss_df4  = DataFrames.DataFrame(summarystats(chn4))
show(stdout,"text/plain",summarystats(chn1))


# %%
ssdfs = [ss_df1,ss_df2,ss_df3,ss_df4]
wi = zeros(4,10)
wg = zeros(4,10)
wistd = zeros(4,10)
wgstd = zeros(4,10)
for i in range(1,length(ssdfs))
    wordsInt  = [ssdfs[i][string.(ss_df1.parameters).=="a_ws["*string(w)*"]","mean"] for w in range(1,10)]
    wordsGrad = [ssdfs[i][string.(ss_df1.parameters).=="b_ws["*string(w)*"]","mean"] for w in range(1,10)]
    wordsIntstd  = [ssdfs[i][string.(ss_df1.parameters).=="a_ws["*string(w)*"]","std"] for w in range(1,10)]
    wordsGradstd = [ssdfs[i][string.(ss_df1.parameters).=="b_ws["*string(w)*"]","std"] for w in range(1,10)]
    for j in range(1,10)
        wi[i,j] = wordsInt[j][1]
        wg[i,j] = wordsGrad[j][1]
        wistd[i,j] = wordsIntstd[j][1]
        wgstd[i,j] = wordsGradstd[j][1]

    end
end
wordVals = vcat(wi,wg)
wordVals_std = vcat(wistd,wgstd)
wordVals_w = zeros(8,10)
function whiten(row)
    return (row.-mean(row))./std(row)
end
for i in range(1,8)
    wordVals_w[i,:] = whiten(wordVals[i,:])
end


function cosdist(data)
    dist = zeros(10,10)
    for i in range(1,10)
        for j in range(1,10)
            dist[i,j] = cosine_dist(data[:,i],data[:,j])
        end
    end
    return dist
end




function wasDist(data,datastd)
    dist = zeros(10,10)
    for i in range(1,10)
        for j in range(1,10)
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






function dendrogram(distances,link,ylab,xlab)
    
    hc = hclust(distances, linkage=link)
    xlabs = [wordTypes[i] for i in hc.order]
    
    return Plots.plot(hc,xticks=(1:10,xlabs),
                ylabel=ylab,
                xlabel=xlab,
                right_margin=10mm,
                left_margin=30mm,
                bottom_margin=20mm,
                top_margin=10mm)

end
types = [:single,:average,:complete,:ward]
ds = []
for i in range(1,length(types))
    t = types[i]
    ylab1 = ""
    ylab2 = ""
    ylab3 = ""
    if i == 1
        ylab1 = "base"
        ylab2 = "whitened"
        ylab3 = "wasserstein distance"
    end
    d1 = dendrogram(cosdist(wordVals),t,ylab1,"")
    d2 = dendrogram(cosdist(wordVals_w),t,ylab2,"")
    d3 = dendrogram(wasDist(wordVals,wordVals_std),t,ylab3,String(t))
    ds = vcat(ds,d1,d2,d3)
end
gr(size=(5000,3200), dpi=300)

p = Plots.plot( ds[1],ds[4],ds[7],ds[10],
                ds[2],ds[5],ds[8],ds[11],
                ds[3],ds[6],ds[9],ds[12],
            layout = grid(3, 4))

Plots.savefig(p,"figs/wordType/fullDendrogram.png")