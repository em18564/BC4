# %%
# using Random
using StatsBase
using Distributions
#using StatsPlots
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
# using Plots
# using Gadfly
# import Cairo, Fontconfig
# %%
noChains = 1000
wordTypes = ["Content","Function"]
cols = ["#3D9970", "#FF4136"]
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end

#df = CSV.read("savedData/df_2.csv", DataFrame)
chn1 = deserialize("output_withoutWT/out1.jls")
chn2 = deserialize("output_withoutWT/out2.jls")
chn3 = deserialize("output_withoutWT/out3.jls")
chn_df1 = DataFrames.DataFrame(chn1)
chn_df2 = DataFrames.DataFrame(chn2)
chn_df3 = DataFrames.DataFrame(chn3)


chn1_2 = deserialize("output_withWT/out1.jls")
chn2_2 = deserialize("output_withWT/out2.jls")
chn3_2 = deserialize("output_withWT/out3.jls")
chn_df1_2 = DataFrames.DataFrame(chn1_2)
chn_df2_2 = DataFrames.DataFrame(chn2_2)
chn_df3_2 = DataFrames.DataFrame(chn3_2)
# %%
dfs = [chn_df1,chn_df2,chn_df3]
dfs_2 = [chn_df1_2,chn_df2_2,chn_df3_2]

function getBox(i)
    return PlotlyJS.violin(y=dfs[i][:,"a"],marker=attr(symbol="line-ew", meanline_visible=true)),PlotlyJS.violin(y=dfs[i][:,"b"],marker=attr(symbol="line-ew", meanline_visible=true))
end



data = [getBox(1)[1],getBox(2)[1],getBox(3)[1]]
layout = Layout(
        violinmode="group",
        yaxis=attr(title="Posterior")
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withoutWT/a.png",width=1000,height=600)

data = [getBox(1)[2],getBox(2)[2],getBox(3)[2]]
layout = Layout(
        violinmode="group"
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withoutWT/b.png",width=1000,height=600)

# traces = [getBox(1)[1],getBox(2)[1]]
# layout = Layout(yaxis=attr(title="97% HDI Difference",range=[-0.3,0.3]),
#                         boxmode="group")
# PlotlyJS.plot(traces,layout)




# %%

dfs_2 = [chn_df1_2,chn_df2_2,chn_df3_2]

function getBox(i)
    return  PlotlyJS.violin(y=dfs_2[i][:,"ab_w[1, 1]"],marker=attr(symbol="line-ew", meanline_visible=true)),
            PlotlyJS.violin(y=dfs_2[i][:,"ab_w[1, 2]"],marker=attr(symbol="line-ew", meanline_visible=true)),
            PlotlyJS.violin(y=dfs_2[i][:,"ab_w[2, 1]"],marker=attr(symbol="line-ew", meanline_visible=true)),
            PlotlyJS.violin(y=dfs_2[i][:,"ab_w[2, 2]"],marker=attr(symbol="line-ew", meanline_visible=true))
end



data = [getBox(1)[1],getBox(1)[2],getBox(2)[1],getBox(2)[2],getBox(3)[1],getBox(3)[2]]
layout = Layout(
        violinmode="group",
        yaxis=attr(title="Posterior")
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withWT/a.png",width=1000,height=600)

data = [getBox(1)[3],getBox(1)[4],getBox(2)[3],getBox(2)[4],getBox(3)[3],getBox(3)[4]]
layout = Layout(
        violinmode="group",
        yaxis=attr(title="Posterior")
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withWT/b.png",width=1000,height=600)


function getBoxDif(i)
    return  PlotlyJS.violin(y=dfs_2[i][:,"ab_w[1, 1]"]-dfs_2[i][:,"ab_w[1, 2]"],marker=attr(symbol="line-ew", meanline_visible=true)),
            PlotlyJS.violin(y=dfs_2[i][:,"ab_w[2, 1]"]-dfs_2[i][:,"ab_w[2, 2]"],marker=attr(symbol="line-ew", meanline_visible=true))
end

data = [getBoxDif(1)[1],getBoxDif(2)[1],getBoxDif(3)[1]]
layout = Layout(
        violinmode="group",
        yaxis=attr(title="Posterior difference")
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withWT/adifs.png",width=1000,height=600)

data = [getBoxDif(1)[2],getBoxDif(2)[2],getBoxDif(3)[2]]
layout = Layout(
        violinmode="group",
        yaxis=attr(title="Posterior difference")
    )
plt = PlotlyJS.plot(data, layout)
PlotlyJS.savefig(plt,"output_withWT/bdifs.png",width=1000,height=600)






# %%
gr(size=(1100,450), dpi=600)
chns = [chn1,chn2,chn3]
plts = []
for i in range(1,3)
    push!(plts,Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"],xlabel = "R-hat",ylabel = "ess",title="PC " * string(i)))
end

essRhat = Plots.plot(plts[1],plts[2],plts[3],layout=@layout grid(1,3))
Plots.savefig(essRhat,"output_withoutWT/essRhat.png")


gr(size=(1100,450), dpi=600)
chns = [chn1_2,chn2_2,chn3_2]
plts = []
for i in range(1,3)
    push!(plts,Plots.scatter(DataFrames.DataFrame(summarystats(chns[i]; append_chains=true))[:,"rhat"],DataFrames.DataFrame(summarystats(chns[1]; append_chains=true))[:,"ess_bulk"],xlabel = "R-hat",ylabel = "ess",title="PC " * string(i)))
end

essRhat = Plots.plot(plts[1],plts[2],plts[3],layout=@layout grid(1,3))
Plots.savefig(essRhat,"output_withWT/essRhat.png")

