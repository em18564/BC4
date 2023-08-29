using Random
using StatsBase
using Distributions
using StatsPlots
using StatsFuns
using Logging

using Turing
using CSV
using DataFrames
using Optim
using StatisticalRethinking

using MCMCDiagnosticTools
using MCMCChains
using Serialization
using Plots

function plotFuncN400(data,folder)
    l = @layout [a ; b]
    chn = deserialize(data)
    chn_ss = DataFrame(summarystats(chn))
    chn_df = DataFrame(chn)
    p1 = density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
    density!(chn_df[!,"ab_w[2,2]"],label = "Function")
    p2 = density(chn_df[!,"ab_w[2,2]"]-chn_df[!,"ab_w[2,1]"],label = "Difference",xaxis="Posterior Effect")
    plot(p1,p2,layout=l,dpi=300)
    savefig(folder*"/wordType.png")
    p = density(chn_df[!,"ab_e[2,1]"],label="n400",xaxis="Posterior Effect")
    plot(p,dpi=300)
    savefig(folder*"/n400.png")
    ess_rhat_df = DataFrame(ess_rhat(chn))
    xs = ess_rhat_df[!,"rhat"]
    ys = ess_rhat_df[!,"ess"]
    p = scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
    plot(p,dpi=300)
    savefig(folder*"/essRhat.png")
end

function plotFuncFull(data,folder)
    l = @layout [a ; b]
    chn = deserialize(data)
    chn_ss = DataFrame(summarystats(chn))
    chn_df = DataFrame(chn)
    p1 = density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
    density!(chn_df[!,"ab_w[2,2]"],label = "Function")
    p2 = density(chn_df[!,"ab_w[2,2]"]-chn_df[!,"ab_w[2,1]"],label = "Difference",xaxis="Posterior Effect")
    plot(p1,p2,layout=l,dpi=300)
    savefig(folder*"/wordType.png")
    y = [chn_df[!,"ab_e[2,1]"],chn_df[!,"ab_e[2,2]"],chn_df[!,"ab_e[2,3]"],chn_df[!,"ab_e[2,4]"],chn_df[!,"ab_e[2,5]"],chn_df[!,"ab_e[2,6]"]]
    names =["PNP" "P600" "EPNP" "N400" "LAN" "ELAN"]
    print(y[1])
    p = violin(names, y, legend=false,xaxis="Posterior Effect")
    plot(p,dpi=300)
    savefig(folder*"/erp.png")
    ess_rhat_df = DataFrame(ess_rhat(chn))
    xs = ess_rhat_df[!,"rhat"]
    ys = ess_rhat_df[!,"ess"]
    p = scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
    plot(p,dpi=300)
    savefig(folder*"/essRhat.png")
end

plotFuncN400("savedData/m_df_n400.jls","graphs/n400")
plotFuncN400("savedData/m_df_n400_full.jls","graphs/n400_full")
plotFuncFull("savedData/m_df_full_full.jls","graphs/full_full")
plotFuncFull("savedData/m_df_full.jls","graphs/full")
# df = CSV.read("savedData/df_2.csv", DataFrame)



l = @layout [a ; b]
data = "savedData/m_df_ltd_word.jls"
folder = "graphs/ltd_word"
chn = deserialize(data)
chn_ss = DataFrame(summarystats(chn))
chn_df = DataFrame(chn)
p1 = density(chn_df[!,"ab_w[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w[2,2]"],label = "Function")
p2 = density(chn_df[!,"ab_w[2,2]"]-chn_df[!,"ab_w[2,1]"],label = "Difference",xaxis="Posterior Effect")
plot(p1,p2,layout=l,dpi=300)
savefig(folder*"/wordType.png")
p = density(chn_df[!,"a_e"],label="n400",xaxis="Posterior Effect")
plot(p,dpi=300)
savefig(folder*"/n400.png")
ess_rhat_df = DataFrame(ess_rhat(chn))
xs = ess_rhat_df[!,"rhat"]
ys = ess_rhat_df[!,"ess"]
p = scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
plot(p,dpi=300)
savefig(folder*"/essRhat.png")




# PNP  = HDI(chn_df[!,"a_e[1]"])
# P600 = HDI(chn_df[!,"a_e[2]"])
# EPNP = HDI(chn_df[!,"a_e[3]"])
# N400 = HDI(chn_df[!,"a_e[4]"])
# LAN  = HDI(chn_df[!,"a_e[5]"])
# ELAN = HDI(chn_df[!,"a_e[6]"])
# y = [chn_df[!,"b"]]
# violin(["N400"], y, legend=false,xaxis="Posterior Effect")

#plot(truncated(Cauchy(20),0,1000),lw=3,xlims=(-1, 100),legend=false,title="Half-Cauchy")

# density(chn_df[!,"σ"],label="n400")
#savefig("graphs/n400.png")
# histogram(ess_rhat_df[!,"rhat"],label="rhat")
# savefig("graphs/rhat.png")

# histogram(ess_rhat_df[!,"ess"],label="ess")
# savefig("graphs/ess.png")


# plot(chn, colordim = :parameter; size=(1680, 800))
# savefig("graphs/trace.png")

# autocorplot(chn,size=(1680,800))
# savefig("graphs/autocor.png")
