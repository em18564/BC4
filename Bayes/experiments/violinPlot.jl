# using Random
using StatsBase
using Distributions
#using StatsPlots
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
# using PlotlyJS
# using Plots
using Gadfly
import Cairo, Fontconfig
function HDI(data)
    l = percentile(data,1.5)
    u = percentile(data,98.5)
    m = mean(data)
    return m,l,u
end

#df = CSV.read("savedData/df_2.csv", DataFrame)
chna = deserialize("ePNP_noCov/output/out.jls")
chn_dfa = DataFrame(chna)
difa1 = chn_dfa[!,"a_w_s[2]"]-chn_dfa[!,"a_w_s[1]"]
difa2 = chn_dfa[!,"b_w_s[2]"]-chn_dfa[!,"b_w_s[1]"]

chnb = deserialize("ePNP_cov/output/out.jls")
chn_dfb = DataFrame(chnb)
difb1 = chn_dfb[!,"ab_w[1,2]"]-chn_dfb[!,"ab_w[1,1]"]
difb2 = chn_dfb[!,"ab_w[2,2]"]-chn_dfb[!,"ab_w[2,1]"]

chnc = deserialize("ePNPPNP_noCov/output/out.jls")
chn_dfc = DataFrame(chnc)
difc1 = chn_dfc[!,"a_w_s1[2]"]-chn_dfc[!,"a_w_s1[1]"]
difc2 = chn_dfc[!,"b_w_s1[2]"]-chn_dfc[!,"b_w_s1[1]"]
difc3 = chn_dfc[!,"a_w_s2[2]"]-chn_dfc[!,"a_w_s2[1]"]
difc4 = chn_dfc[!,"b_w_s2[2]"]-chn_dfc[!,"b_w_s2[1]"]

chnd = deserialize("ePNPPNP_Cov/output/out.jls")
chn_dfd = DataFrame(chnd)
difd1 = chn_dfd[!,"ab_w_e[1,2]"]-chn_dfd[!,"ab_w_e[1,1]"]
difd2 = chn_dfd[!,"ab_w_e[2,2]"]-chn_dfd[!,"ab_w_e[2,1]"]
difd3 = chn_dfd[!,"ab_w_p[1,2]"]-chn_dfd[!,"ab_w_p[1,1]"]
difd4 = chn_dfd[!,"ab_w_p[2,2]"]-chn_dfd[!,"ab_w_p[2,1]"]

df = DataFrame(data         = vcat(difa1,difa2,difb1,difb2,difc1,difc2,difc3,difc4,difd1,difd2,difd3,difd4)
              ,group        = vcat(fill("Just EPNP Δa_w",length(difa1)),fill("Just EPNP Δb_w",length(difa2)),fill("Just EPNP Δa_w Cov",length(difb1)),fill("Just EPNP Δb_w Cov",length(difb2)),fill("EPNP Δa_w",length(difc1)),fill("EPNP Δb_w",length(difc2)),fill("PNP Δa_w",length(difc3)),fill("PNP Δb_w",length(difc4)),fill("EPNP Δa_w w/ Cov",length(difd1)),fill("EPNP Δb_w w/ Cov",length(difd2)),fill("PNP Δa_w w/ Cov",length(difd3)),fill("PNP Δb_w w/ Cov",length(difd4)))
              ,experiment   = vcat(fill("EPNP No Covariance",length(difa1)+length(difa2)),fill("EPNP W/ Covariance",length(difb1)+length(difb2)),fill("EPNP+PNP No Covariance",length(difc1)+length(difc2)+length(difc3)+length(difc4)),fill("EPNP+PNP W/ Covariance",length(difd1)+length(difd2)+length(difd3)+length(difd4))))
vio = Gadfly.plot(  Theme(background_color = "ghostwhite",default_color="grey"),
                    layer(df, x=:group,y=:data,color=:experiment,Geom.violin),
                    layer(df, x=:group,y=:data,Geom.boxplot(suppress_outliers=true,method=[0.015,0.015,0.50,0.985,0.985])));


draw(PNG("violin.png", 8inch, 8inch), vio)
