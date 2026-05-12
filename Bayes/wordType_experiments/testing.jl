
#%%
include("setup.jl")
include("typeStructures.jl")
include("model_master.jl")
include("plottingFuncs.jl")

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

# %%
dfTags   = CSV.read("../input/full_tags.csv", DataFrame)
replace!(dfTags.tags, 10 => 5)
CSV.write("../input/full_tags.csv", dfTags)
# %%
dfTags   = CSV.read("../input/full_tags.csv", DataFrame)
wordEncodings = Dict(   0=>"Adjective",1=>"Adposition",2=>"Adverb",
                        3=>"Conjunction",4=>"Determiner",5=>"Noun",6=>"Numeral",
                        7=>"Pronoun",8=>"Particle",9=>"Verb")
tags = dfTags[dfTags.Participant.==1,:].tags
x = [wordEncodings[i] for i in range(0,9)]
y = [counter(tags)[i] for i in range(0,9)]

# %%
color_vec = [palette(:tab10)[i] for i in range(1,10)]

p = PlotlyJS.plot(
    PlotlyJS.bar(x=x, y=y, marker_color=color_vec),
    Layout(title_text="Frequency plot of word types")
)
PlotlyJS.savefig(p,"figs/fx.png")

# %% 
function essRhatDataFrame(folderLoc)
    expParams    = []
    cauchyParams = []
    essScores    = [[],[],[],[]]
    rhatScores   = [[],[],[],[]]
    label = []
    for (root, _, files) in walkdir(folderLoc)
        if(folderLoc!=root)
            foldername = replace(root,folderLoc*"\\" => "" )
            index = findfirst("_",foldername)[1]
            push!(expParams,foldername[1:index-1])
            push!(cauchyParams,foldername[index+1:length(foldername)])

            for i in range(1,4)
                filename = "score"*string(i)*".csv" 
                if(filename in files)
                    s = CSV.read(joinpath.(root, filename),DataFrame)
                    push!(essScores[i],s.ess)
                    push!(rhatScores[i],s.rhat)
                    label = s.label
                else
                    push!(essScores[i],zeros(8))
                    push!(rhatScores[i],zeros(8))
                end
            end
            
        end
        
        #print(joinpath.(root, files),"\n") # files is a Vector{String}, can be empty
    end
    es = hcat(  mapreduce(permutedims, vcat, essScores[1]),
                mapreduce(permutedims, vcat, essScores[2]),
                mapreduce(permutedims, vcat, essScores[3]),
                mapreduce(permutedims, vcat, essScores[4]))
    rh = hcat(  mapreduce(permutedims, vcat, rhatScores[1]),
                mapreduce(permutedims, vcat, rhatScores[2]),
                mapreduce(permutedims, vcat, rhatScores[3]),
                mapreduce(permutedims, vcat, rhatScores[4]))
    colNames = []
    for i in range(1,4)
        colNames = vcat(colNames,[x*"_"*string(i) for x in label])
    end
    df = DataFrames.DataFrame(ExponentialParam=expParams,CauchyParam=cauchyParams)
    for i in range(1,length(colNames))
        df[!,"ess_"*colNames[i]] =es[:,i]
        df[!,"rhat_"*colNames[i]]=rh[:,i]
    end
    return df
end
function essRhatDataFrameSpecifyFilename(folderLoc,filenames)
    expParams    = []
    cauchyParams = []
    essScores    = [[],[],[],[]]
    rhatScores   = [[],[],[],[]]
    label = []
    for filename in filenames
        for (root, _, files) in walkdir(folderLoc)
            if(folderLoc!=root)
                foldername = replace(root,folderLoc*"\\" => "" )
                if foldername == filename
                    index = findfirst("_",foldername)[1]
                    push!(expParams,foldername[1:index-1])
                    push!(cauchyParams,foldername[index+1:length(foldername)])

                    for i in range(1,4)
                        filename = "score"*string(i)*".csv" 
                        if(filename in files)
                            s = CSV.read(joinpath.(root, filename),DataFrame)
                            push!(essScores[i],s.ess)
                            push!(rhatScores[i],s.rhat)
                            label = s.label
                        else
                            push!(essScores[i],zeros(8))
                            push!(rhatScores[i],zeros(8))
                        end
                    end
                end
            end
        end
        
        #print(joinpath.(root, files),"\n") # files is a Vector{String}, can be empty
    end
    es = hcat(  mapreduce(permutedims, vcat, essScores[1]),
                mapreduce(permutedims, vcat, essScores[2]),
                mapreduce(permutedims, vcat, essScores[3]),
                mapreduce(permutedims, vcat, essScores[4]))
    rh = hcat(  mapreduce(permutedims, vcat, rhatScores[1]),
                mapreduce(permutedims, vcat, rhatScores[2]),
                mapreduce(permutedims, vcat, rhatScores[3]),
                mapreduce(permutedims, vcat, rhatScores[4]))
    colNames = []
    for i in range(1,4)
        colNames = vcat(colNames,[x*"_"*string(i) for x in label])
    end
    df = DataFrames.DataFrame(ExponentialParam=expParams,CauchyParam=cauchyParams)
    for i in range(1,length(colNames))
        df[!,"ess_"*colNames[i]] =es[:,i]
        df[!,"rhat_"*colNames[i]]=rh[:,i]
    end
    return df
end
filenames = []
for i in range(0.5,20,10)
    for j in range(0.5,20,10)
        push!(filenames,string(i)*"_"*string(j))
    end
end

df =essRhatDataFrameSpecifyFilename("models/exponentials/output_FullCF_12_1931",filenames)
# %%
function getSectionData(section,df,xlabs,ylabs)
    data = zeros(4,length(xlabs),length(ylabs))
    for row in eachrow(df)
        this_x = findall(x->x==row.ExponentialParam, xlabs)[1]
        this_y = findall(x->x==row.CauchyParam, ylabs)[1]
        for i in range(1,4)
            data[i,this_x,this_y] = row[section*"_"*string(i)]
        end
    end
    return data
end
sections    = ["Overall","as","bs","σs","ws","ps","es","σ"]
essSections  = "ess_".*sections
rhatSections = "rhat_".*sections
xlabs = unique(df.ExponentialParam)
ylabs = unique(df.CauchyParam)
essData =  [getSectionData(section,df,xlabs,ylabs) for section in essSections]
rhatData = [getSectionData(section,df,xlabs,ylabs) for section in rhatSections]
maxEss = maximum([maximum(ess) for ess in essData])
minEss = minimum([minimum(ess) for ess in essData])
maxRhat = maximum([maximum(rhat) for rhat in rhatData])
minRhat = minimum([minimum(rhat) for rhat in rhatData])

# %%
function essRhatHeatmaps(section,xlabs,ylabs,min,max,sectionTitle)
    Plots.scalefontsizes()
    Plots.scalefontsizes(2)
    print(min,"-",max,"\n")
    for i in range(1,length(xlabs))
        if(length(xlabs[i])>4)
            xlabs[i]=xlabs[i][1:4]
        end
    end
    for i in range(1,length(ylabs))
        if(length(ylabs[i])>4)
            ylabs[i]=ylabs[i][1:4]
        end
    end

    p = []
    for i in range(1,4)
            if i == 1
                hm = Plots.heatmap(xlabs,
                ylabs, transpose(section[i,:,:]),
                xlabel="exponential mean", ylabel="half-cauchy dispertion",
                left_margin=30mm,
                bottom_margin=20mm,
                right_margin=10mm,
                legend = :none,
                clims = (min,max),
                title = "PC " * string(i))
            else
                hm = Plots.heatmap(xlabs,
                ylabs, transpose(section[i,:,:]),
                xlabel="exponential mean",
                right_margin=10mm,
                bottom_margin=20mm, legend = :none,
                clims = (min,max),
                title = "PC " * string(i))
            end
            
            push!(p,hm)
    end
    labs = (1:10:101, string.(range(min,max,11)))
    for i in range(1,length(labs[2]))
        if length(labs[2][i])>6
            labs[2][i] = labs[2][i][1:6]
        end
    end
    push!(p,Plots.heatmap((0:0.01:1).*ones(101,1), legend=:none, xticks=:none,bottom_margin=20mm,right_margin=20mm,left_margin=20mm, yticks=labs))
    l = @layout [a{0.24w} b{0.24w} c{0.24w} d{0.24w} e]
    myPlot = Plots.plot(p[1],p[2],p[3],p[4], p[5]; layout = l,plot_title=sectionTitle,
                top_margin=10mm)
    gr(size=(4400,1200), dpi=600)
    
    return myPlot

end
essPlots  = [essRhatHeatmaps(innerEssData[1],xlabs,ylabs,minEss,maxEss,innerEssData[2]) for innerEssData in zip(essData,essSections)]
rhatPlots = [essRhatHeatmaps(innerRhatData[1],xlabs,ylabs,minRhat,maxRhat,innerRhatData[2]) for innerRhatData in zip(rhatData,rhatSections)]



# %%
# %%
for essPlot in zip(essSections,essPlots)
    Plots.savefig(essPlot[2],"figs/"*essPlot[1]*".png")
end
for rhatPlot in zip(rhatSections,rhatPlots)
    Plots.savefig(rhatPlot[2],"figs/"*rhatPlot[1]*".png")
end
#%%

df.essAvg = (df.ess_Overall_1+df.ess_Overall_2+df.ess_Overall_3+df.ess_Overall_4)/4
df.rhatAvg = (df.rhat_Overall_1+df.rhat_Overall_2+df.rhat_Overall_3+df.rhat_Overall_4)/4

essMax  = findmax(df.essAvg)
rhatMin = findmin(df.rhatAvg)

df[df.essAvg.==essMax[1],:]

# %%
col1 = unique(df.ExponentialParam)
xs1 = round.(parse.(Float64,unique(df.ExponentialParam)),digits=2)
y = [mean(df[df.ExponentialParam.==x,:].essAvg) for x in col1]
Plots.plot(xs1,y,label="Exponential ESS Avg")

col2 = unique(df.CauchyParam)
xs2 = round.(parse.(Float64,unique(df.CauchyParam)),digits=2)
y = [mean(df[df.CauchyParam.==x,:].essAvg) for x in col2]
Plots.plot!(xs2,y,label="Cauchy ESS Avg")
Plots.savefig("figs/essLinePlot.png")

y = [mean(df[df.ExponentialParam.==x,:].rhatAvg) for x in col1]
Plots.plot(xs1,y,label="Exponential Rhat Avg")

y = [mean(df[df.CauchyParam.==x,:].rhatAvg) for x in col2]
Plots.plot!(xs2,y,label="Cauchy Rhat Avg")
Plots.savefig("figs/rhatLinePlot.png")


# %%
Plots.heatmap(sort(xs2),sort(xs1),
                xlabel="exponential mean",
                ylabel="half-cauchy dispertion",
                (reshape(df.essAvg,(10,10))),
                title = "Overall Ess Avg")
Plots.savefig("figs/overallEssAvg.png")

Plots.heatmap(xs2,xs1,
                xlabel="exponential mean",
                ylabel="half-cauchy dispertion",
                (reshape(df.rhatAvg,(10,10))),
                title = "Overall Rhat Avg")
Plots.savefig("figs/overallRhatAvg.png")

#%%







outputDir="models/exponentials/output_FullCF_12_1931/0.1_0.8631578947368421"
outputDir2="models/halfNorms/output_FullCF_23_1931"
wordTypes = ["Adjective","Noun","Verb","Adverb","Function"]
cols = ["#3D9970", "#FF4136", "#FF851B","#4040FF","#7D0DC3"]
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

plotGraphs(outputDir,wordTypes,cols)

# %%
ssdfs = [ss_df1,ss_df2,ss_df3,ss_df4]
wi = zeros(4,5)
wg = zeros(4,5)
for i in range(1,length(ssdfs))
    wordsInt  = [ssdfs[i][string.(ss_df1.parameters).=="a_ws["*string(w)*"]","mean"] for w in range(1,5)]
    wordsGrad = [ssdfs[i][string.(ss_df1.parameters).=="b_ws["*string(w)*"]","mean"] for w in range(1,5)]
    for j in range(1,5)
        wi[i,j] = wordsInt[j][1]
        wg[i,j] = wordsGrad[j][1]
    end
end
wordVals = vcat(wi,wg)


distances = zeros(5,5)

for i in range(1,5)
    for j in range(1,5)
        distances[i,j] = cosine_dist(wordVals[:,i],wordVals[:,j])
    end
end


# %%
hc = hclust(distances, linkage=:single)
xlabs = [wordTypes[i] for i in hc.order]
Plots.plot(hc,xticks=(1:5,xlabs))
Plots.savefig("figs/dendrogram.png")


# %%
dfTags   = CSV.read("../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../input/dfPCANorm_corrected.csv", DataFrame)
df[!,"fullTag"] = dfTags#

NUM_TYPES,df_modified,wordTypes,cols = processTypeStructure(df,"FullCF")
df_modified.Participant= df_modified.Participant.+1
df_modified.fullTag= df_modified.fullTag.+1

seenData = subset(df_modified, :Participant => ByRow(<(13)))
unseenData = subset(df_modified, :Participant => ByRow(>=(13)))
#%%
function m(mydf, paramName)
    return mydf[string.(mydf.parameters).==paramName,"mean"]
end

function mod(mydf,participant,tag,surprisal)
    a_w  = m(mydf,"a_ws["*string(tag)*"]")[1]
    a_p  = m(mydf,"a_ps["*string(participant)*"]")[1]
    a_e  = m(mydf,"a_e")[1]

    b_w  = m(mydf,"b_ws["*string(tag)*"]")[1]
    b_p  = m(mydf,"b_ps["*string(participant)*"]")[1]
    b_e  = m(mydf,"b_e")[1]

    σ_aw = m(mydf,"σ_aw")[1]
    σ_ap = m(mydf,"σ_ap")[1]
    σ_bw = m(mydf,"σ_bw")[1]
    σ_bp = m(mydf,"σ_bp")[1]

    return a_w*σ_aw + a_p*σ_ap + a_e + ((b_w*σ_bw + b_p*σ_bp + b_e) * surprisal)
end
score = 0
for row in eachrow(unseenData)
    PCS = [row.PC_1,row.PC_2,row.PC_3,row.PC_4]
    predictedTags = zeros(4,5)
    for j in range(1,4)
        for tag in range(1,5)
            predictedTags[j,tag] =mod(ssdfs[j],row.Participant,tag,row.Surprisal)
        end
        
    end
    predTagsDists = zeros(5)
    for tag in range(1,5)
        predTagsDists[tag] = cosine_dist(PCS,predictedTags[:,tag])
    end
    if(row.fullTag==findmin(predTagsDists)[2])
        score+=1
    end
end
print(score/nrow(unseenData))