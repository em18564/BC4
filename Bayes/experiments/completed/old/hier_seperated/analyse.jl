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

# function HDI(data)
#     p1 = percentile(data,1.5)
#     p2 = percentile(data,98.5)
#     m = mean(data)
#     return m,p1,p2
# end

chn = deserialize("output/out.jls")
chn_ss = DataFrame(summarystats(chn))
chn_df = DataFrame(chn)
density(chn_df[!,"ab_w_1[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_1[2,2]"],label = "Function")
savefig("output/dens1.png")
density(chn_df[!,"ab_w_2[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_2[2,2]"],label = "Function")
savefig("output/dens2.png")
density(chn_df[!,"ab_w_3[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_3[2,2]"],label = "Function")
savefig("output/dens3.png")
density(chn_df[!,"ab_w_4[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_4[2,2]"],label = "Function")
savefig("output/dens4.png")
density(chn_df[!,"ab_w_5[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_5[2,2]"],label = "Function")
savefig("output/dens5.png")
density(chn_df[!,"ab_w_6[2,1]"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"ab_w_6[2,2]"],label = "Function")
savefig("output/dens6.png")
CSV.write("output/ss.csv", chn_ss)

density(chn_df[!,"ab_w_1[2,2]"]+chn_df[!,"ab_w_2[2,2]"]+chn_df[!,"ab_w_3[2,2]"]+chn_df[!,"ab_w_4[2,2]"]+chn_df[!,"ab_w_5[2,2]"]+chn_df[!,"ab_w_6[2,2]"]-chn_df[!,"ab_w_1[2,1]"]-chn_df[!,"ab_w_2[2,1]"]-chn_df[!,"ab_w_3[2,1]"]-chn_df[!,"ab_w_4[2,1]"]-chn_df[!,"ab_w_5[2,1]"]-chn_df[!,"ab_w_6[2,1]"],label = "Difference",xaxis="Posterior Effect")
density(chn_df[!,"ab_w_3[2,2]"]-chn_df[!,"ab_w_3[2,1]"])
savefig("output/dif2.png")


ELAN  = (chn_df[!,"ab_e[2,1]"])
LAN = (chn_df[!,"ab_e[2,2]"])
N400 = (chn_df[!,"ab_e[2,3]"])
EPNP = (chn_df[!,"ab_e[2,4]"])
P600  = (chn_df[!,"ab_e[2,5]"])
PNP = (chn_df[!,"ab_e[2,6]"])
y = [ELAN,LAN,N400,EPNP,P600,PNP]
violin(["ELAN" "LAN" "N400" "EPNP" "P600" "PNP" ], y, legend=false,xaxis="Posterior Effect")
savefig("output/violin.png")

ess_rhat_df = DataFrame(ess_rhat(chn))
xs = ess_rhat_df[!,"rhat"]
ys = ess_rhat_df[!,"ess"]
scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)
savefig("output/essRhat.png")

#plot(truncated(Cauchy(-20),0,1000),lw=3,xlims=(-1, 100),legend=false,title="Half-Cauchy")

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
