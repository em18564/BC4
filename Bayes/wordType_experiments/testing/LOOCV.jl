# %%
using DataFrames
using MLBase
using ParetoSmooth
using StatsBase
using StatsPlots
using Turing
using Measurements
include("../setup.jl")
include("../typeStructures.jl")
include("../model_master.jl")
include("../plottingFuncs.jl")
# %%
# %%
outputDirs=["1_baseModel", "2_baseModel_lowerCauchy", "3_baseModel_noLKJintercept",
            "4_baseModel_noLKJ","6_baseModel_renormalised_0.5","6_baseModel_renormalised_1",
            "7_baseModel_0.25","8_tightCauchy_e_0.5","8_tightCauchy_e_0.25","8_tightCauchy_e_1"]


# %%
for outputDir in outputDirs
    fullOD = "models/"*outputDir
    include("../"*fullOD*"/modelDef.jl")
end
# %%
funcs = [model_1,model_2,model_3,model_4,model_6_05,model_6_1,model_7,model_8_05,model_8_025,model_8_1]
# %%

function getPSISScores(modDir,model::Function)
    outputDir = "models/"*modDir
    params    = "/output_FullCF_23_1931"
    chn1 = deserialize(outputDir*params*"/out1.jls")
    chn2 = deserialize(outputDir*params*"/out2.jls")
    chn3 = deserialize(outputDir*params*"/out3.jls")
    chn4 = deserialize(outputDir*params*"/out4.jls")
    chns = [chn1,chn2,chn3,chn4]
    scores = []
    for i in range(1,4)
        df_modified, dfPCA, pc, NUM_PARTICIPANTS, NUM_WORDS,TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean = createVariables([string(i),"4","23","1931","FullCF","0","0","0.5","0.5","1","1"])
        mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)
        push!(scores,psis_loo(mod, chns[i]))
    end
    return scores
end


# %%
fullScores = []
for i in eachindex(outputDirs)
    push!(fullScores,getPSISScores(outputDirs[i],funcs[i]))
end

# %%

fullScores = deserialize("psis.jls")

# %%
gr(size=(1050,500), dpi=300)


data = [[fullScores[i][j].estimates[1,1] for i in 1:length(fullScores)].±[fullScores[i][j].estimates[1,2] for i in 1:length(fullScores)] for j in 1:4]

l = @layout [[grid(2,2)] b{0.27w}]

ps = [Plots.plot(
    1:10,
    data[j],
    legend=false,
    marker=:o,
    ylabel="cv_elpd score",
    xlabel="model number",
    bottom_margin=4mm,
    left_margin=5mm) for j in 1:4]

p2 = Plots.plot(axis=([], false), margin=0Plots.cm)

ftr = text(join([string(o)*": "*outputDirs[o]*"\n" for o in eachindex(outputDirs)]), :black, :left, 10)
annotate!(0, 0.8, ftr)
Plots.plot(ps[1],ps[2],ps[3],ps[4],p2,layout=l,plot_title="CV_ELPD scores of 10 models")
Plots.savefig("figs/modelComparison/CV_ELPD.png")
# %%






outputDirs2=["output_CF_23_1931", "output_DendroCustom_23_1931", "output_Full_23_1931",
            "output_FullCF_23_1931"]

category=["CF", "DendroCustom", "Full",
            "FullCF"]

include("../models/6_baseModel_renormalised_1/modelDef.jl")
function getPSISScores(modDir,model::Function, type,category)
    outputDir = "models/"*modDir
    params    = "/"*type
    chn1 = deserialize(outputDir*params*"/out1.jls")
    chn2 = deserialize(outputDir*params*"/out2.jls")
    chn3 = deserialize(outputDir*params*"/out3.jls")
    chn4 = deserialize(outputDir*params*"/out4.jls")
    chns = [chn1,chn2,chn3,chn4]
    scores = []
    for i in range(1,4)
        df_modified, dfPCA, pc, NUM_PARTICIPANTS, NUM_WORDS,TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols,isPlotting,analyseEssRhat,output_loc,expMean,cauchyMean = createVariables([string(i),"4","23","1931",category,"0","0","0.5","0.5","1","1"])
        mod=model(df_modified.Participant,df_modified.Word,df_modified.Surprisal,df_modified.fullTag,dfPCA[:,pc],expMean,cauchyMean,NUM_TYPES,NUM_PARTICIPANTS)
        push!(scores,psis_loo(mod, chns[i]))
    end
    return scores
end



fullScores = []
for i in eachindex(outputDirs2)
    push!(fullScores,getPSISScores("6_baseModel_renormalised_1",model_6_1,outputDirs2[i],category[i]))
end


# %%

serialize("psis2.jls",fullScores)


# %%

gr(size=(1050,500), dpi=300)


data = [[fullScores[i][j].estimates[1,1] for i in 1:length(fullScores)].±[fullScores[i][j].estimates[1,2] for i in 1:length(fullScores)] for j in 1:4]

l = @layout [[grid(2,2)] b{0.27w}]

ps = [Plots.plot(
    1:4,
    data[j],
    legend=false,
    marker=:o,
    ylabel="cv_elpd score",
    xlabel="model number",
    bottom_margin=4mm,
    left_margin=5mm) for j in 1:4]

p2 = Plots.plot(axis=([], false), margin=0Plots.cm)

ftr = text(join([string(o)*": "*outputDirs2[o]*"\n" for o in eachindex(outputDirs2)]), :black, :left, 10)
annotate!(0, 0.8, ftr)
Plots.plot(ps[1],ps[2],ps[3],ps[4],p2,layout=l,plot_title="CV_ELPD scores of 10 models")
# %% 

Plots.savefig("figs/modelComparison/CV_ELPD2.png")