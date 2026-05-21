# %%

include("../setup.jl")
include("../typeStructures.jl")
include("../model_master.jl")
include("../plottingFuncs.jl")
using SkipNan

# %%


outputDirs=["1_baseModel", "2_baseModel_lowerCauchy", "3_baseModel_noLKJintercept",
            "4_baseModel_noLKJ","6_baseModel_renormalised",
            "7_baseModel_0.25","8_tightCauchy_e_0.5","8_tightCauchy_e_0.25","8_tightCauchy_e_1"]
function getessRhats(outputName)
    outputDir = "models/"*outputName*"/output_FullCF_23_1931"
    chn1 = deserialize(outputDir*"/out1.jls")
    chn2 = deserialize(outputDir*"/out2.jls")
    chn3 = deserialize(outputDir*"/out3.jls")
    chn4 = deserialize(outputDir*"/out4.jls")

    ss_df1  = DataFrames.DataFrame(summarystats(chn1))
    ss_df2  = DataFrames.DataFrame(summarystats(chn2))
    ss_df3  = DataFrames.DataFrame(summarystats(chn3))
    ss_df4  = DataFrames.DataFrame(summarystats(chn4))
    ess  = hcat(ss_df1.ess_bulk,   ss_df2.ess_bulk,    ss_df3.ess_bulk,    ss_df4.ess_bulk)
    rhat = hcat(ss_df1.rhat,       ss_df2.rhat,        ss_df3.rhat,        ss_df4.rhat)
    return ess,rhat
end

function getDistinctScores(outputName)
    outputDir = "models/"*outputName*"/output_FullCF_23_1931"
    chn1 = deserialize(outputDir*"/out1.jls")
    chn2 = deserialize(outputDir*"/out2.jls")
    chn3 = deserialize(outputDir*"/out3.jls")
    chn4 = deserialize(outputDir*"/out4.jls")

    ss_df1  = DataFrames.DataFrame(summarystats(chn1))
    ss_df2  = DataFrames.DataFrame(summarystats(chn2))
    ss_df3  = DataFrames.DataFrame(summarystats(chn3))
    ss_df4  = DataFrames.DataFrame(summarystats(chn4))
    ess  = hcat(ss_df1.ess_bulk,   ss_df2.ess_bulk,    ss_df3.ess_bulk,    ss_df4.ess_bulk)
    rhat = hcat(ss_df1.rhat,       ss_df2.rhat,        ss_df3.rhat,        ss_df4.rhat)
    return ess,rhat
end


allEss  = []
allRhat = []
for od in outputDirs
    ess,rhat = getessRhats(od)
    push!(allEss,ess)
    push!(allRhat,rhat)
end


# %%
function getBar(i, xbase, mean, max, min)

    offset = (-0.3, -0.1,0.1, 0.3)[i] 

    bar = PlotlyJS.bar(
        x = xbase,
        y = mean,
        name = "PC " * string(i),

        error_y = attr(
            type = "data",
            symmetric = false,
            array = max,
            arrayminus = min,
            visible = true
        )
    )

    labels1 = PlotlyJS.scatter(
        x = xbase .+ offset,
        y = mean .+ max .*1.01,
        mode = "text",
        text = round.(mean .+ max, digits=2),
        textposition = "top center",
        showlegend = false,
        textfont = attr(
        size = 8
        )
    )
    labels2 = PlotlyJS.scatter(
        x = xbase .+ offset,
        y = (mean .- min).-((mean).*0.07).+0.04,
        mode = "text",
        text = round.(mean .- min, digits=2),
        textposition = "top center",
        showlegend = false,
        textfont = attr(
        size = 8
    )
    )

    return bar, labels1,labels2
end


function barPlot(data,mytitle)
    means = zeros((length(data),4))
    maxs  = zeros((length(data),4))
    mins  = zeros((length(data),4))
    for i in range(1,length(data))
        for j in range(1,4)
            curData=skipnan(data[i][:,j])
            means[i,j] = mean(curData)
            maxs[i,j]  = maximum(curData)-mean(curData)
            mins[i,j]  = mean(curData)-minimum(curData)
        end     
    end
    xbase = 1:length(outputDirs)

    bars = [
        getBar(i, xbase, means[:,i], maxs[:,i], mins[:,i])
        for i in 1:4
    ]

    layout = Layout(
        barmode = "group",
        xaxis = attr(
            tickvals = xbase,
            ticktext = outputDirs
        ),
        title=mytitle
    )

    PlotlyJS.plot(
        [
            bars[1][1], bars[1][2], bars[1][3],
            bars[2][1], bars[2][2], bars[2][3],
            bars[3][1], bars[3][2], bars[3][3],
            bars[4][1], bars[4][2], bars[4][3]
        ],
        layout,
    )
end


p = barPlot(allEss,"ess Average scores for different models (with min and max error bars)")
PlotlyJS.savefig(p,"figs/modelComparison/ess.png",
        width=1400, height=800)
p = barPlot(allRhat,"rhat Average scores for different models (with min and max error bars)")
PlotlyJS.savefig(p,"figs/modelComparison/rhat.png",
        width=1400, height=800)