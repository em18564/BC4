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

df = DataFrame(data         = vcat(difb1,difb2,difd1,difd2,difd3,difd4)
              ,group        = vcat(fill("Δa_w ",length(difb1)),fill("Δb_w ",length(difb2)),fill("EPNP Δa_w ",length(difd1)),fill("EPNP Δb_w ",length(difd2)),fill("PNP Δa_w ",length(difd3)),fill("PNP Δb_w ",length(difd4)))
              ,model   = vcat(fill("EPNP With Covariance",length(difb1)+length(difb2)),fill("EPNP+PNP With Covariance",length(difd1)+length(difd2)+length(difd3)+length(difd4))))
vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=14pt,key_label_font_size=12pt,minor_label_font_size=12pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference of content and function words across different Bayesian models"),Guide.xlabel("Posterior"),
                    layer(df, x=:group,y=:data,color=:model,Geom.violin),
                    layer(df, x=:group,y=:data,Geom.boxplot(suppress_outliers=true,method=[0.015,0.015,0.50,0.985,0.985])));

                    
# df = DataFrame(data         = vcat(difd1,difd2,difd3,difd4)
#               ,group        = vcat(fill("Δa_w",length(difd1)),fill("Δb_w",length(difd2)),fill("Δa_w ",length(difd3)),fill("Δb_w ",length(difd4)))
#               ,ERP   = vcat(fill("EPNP",length(difd1)+length(difd2)),fill("PNP",length(difd3)+length(difd4)),))
# vio = Gadfly.plot(  Theme(major_label_font_size=17pt,key_title_font_size=16pt,key_label_font_size=14pt,minor_label_font_size=14pt,background_color = "ghostwhite",default_color="grey",boxplot_spacing=70px),Guide.ylabel("Posterior Difference (with 97% HCI)"),Guide.title("Posterior Difference of content and function words"),Guide.xlabel("Posterior"),
#                     layer(df, x=:group,y=:data,color=:ERP,Geom.violin),
#                     layer(df, x=:group,y=:data,Geom.boxplot(suppress_outliers=true,method=[0.015,0.015,0.50,0.985,0.985])));

draw(PNG("violin.png", 16inch, 8inch, dpi=300), vio)
