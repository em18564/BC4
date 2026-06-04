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


data = [[fullScores[i][j].estimates[1,1] for i in 1:10].±[fullScores[i][j].estimates[1,2] for i in 1:10] for j in 1:4]

l = @layout [a b; c d]

ps = [Plots.plot(
    1:10,
    data[j],
    legend=false,
    marker=:o) for j in 1:4]

Plots.plot(ps[1],ps[2],ps[3],ps[4],layout=l)
# %%


# %%
X = rand(1.0:100.0, 30)
# True data-generating model is second-order polynomial!
Y = @. 3.0 + 2.0 * X + 0.05 * X^2 + rand(Normal(0, 40))
Xₜ = StatsBase.standardize(ZScoreTransform, X)
Yₜ = StatsBase.standardize(ZScoreTransform, Y)

@model function test(X, Y, o) # 'o' is for 'order'
    σ ~ Exponential(1)
    α ~ Normal(0, 1)
    β ~ MvNormal(o, 1)
    μ = α .+ sum(β .* [X.^i for i in 1:o])
    Y ~ MvNormal(μ, σ)
end

# PSIS_LOO
score1 = psis_loo(test(Xₜ, Yₜ, 1), sample(test(Xₜ, Yₜ, 1), NUTS(), 1_000))
score2 = psis_loo(test(Xₜ, Yₜ, 2), sample(test(Xₜ, Yₜ, 2), NUTS(), 1_000))
score3 = psis_loo(test(Xₜ, Yₜ, 3), sample(test(Xₜ, Yₜ, 3), NUTS(), 1_000))
score4 = psis_loo(test(Xₜ, Yₜ, 4), sample(test(Xₜ, Yₜ, 4), NUTS(), 1_000))

plot(
    1:4,
    # get the :cv_elpd and :naive_lpd values for each model
    [[eval(Symbol("score$i")).estimates[1,1] for i in 1:4] [eval(Symbol("score$i")).estimates[2,1] for i in 1:4]],
    labels=["cv_elpd" "naive_lpd"],
    legend=:topleft,
    marker=:o
)
# %%