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

function HDI(data)
    p1 = percentile(data,1.5)
    p2 = percentile(data,98.5)
    m = mean(data)
    return m,p1,p2
end

# df = CSV.read("savedData/df_2.csv", DataFrame)
chn = deserialize("savedData/m_df_n400.jls")
chn_ss = DataFrame(summarystats(chn))
chn_df = DataFrame(chn)
density(chn_df[!,"a_w"],label = "Content",xaxis="Posterior Effect")
density!(chn_df[!,"b_w"],label = "Function")
CSV.write("savedData/n400_ss.csv", chn_ss)

#density(chn_df[!,"b_w[2]"]-chn_df[!,"b_w[1]"],label = "Difference",xaxis="Posterior Effect")
#density(chn_df[!,"b_e"],label="n400",xaxis="Posterior Effect")

# PNP  = HDI(chn_df[!,"a_e[1]"])
# P600 = HDI(chn_df[!,"a_e[2]"])
# EPNP = HDI(chn_df[!,"a_e[3]"])
# N400 = HDI(chn_df[!,"a_e[4]"])
# LAN  = HDI(chn_df[!,"a_e[5]"])
# ELAN = HDI(chn_df[!,"a_e[6]"])
# y = [chn_df[!,"b"]]
# violin(["N400"], y, legend=false,xaxis="Posterior Effect")
# ess_rhat_df = DataFrame(ess_rhat(chn))
# xs = ess_rhat_df[!,"rhat"]
# ys = ess_rhat_df[!,"ess"]
# scatter(xs, ys, xlabel = "rhat", ylabel = "ess", legend=false)

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
