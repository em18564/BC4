using StatsPlots,Measures

ctg = repeat(["ELAN", "LAN", "N400", "EPNP", "P600", "PNP"], inner = 6)
name = repeat("PC" .* string.(1:6), outer = 6)
name2 = "PC" .* string.(1:6)

theme(:ggplot2)
default(
    titlefont = 24,
    guidefont = 24,     # x and y axis labels (xlabel/ylabel)
    tickfont = 16,      # axis tick numbers
    legendfont = 16
)
marker_colors=repeat(["#C5C5C5","#767676","#636363","#3B3B3B","#141414","#000000"],inner=6)
p1 = groupedbar(name, transpose(l), group = ctg, 
           ylabel = "Principal Component Loadings",
           bar_width = 0.67,
           ylim = (-5,5),
           yticks = range(-5,5,11),
           xticks =(range(0.5,5.5,6),repeat("",6)),
           color = marker_colors,
           bg_inside   = "#E5ECF6",
           background_color_legend = "#F4F7FB",
           xminorticks = 0,
           yminorticks = 5,
           lw=0,
           title="(a)",
           widen=false)
#savefig("PCALoadings.png")
varExp = (principalvars(M)./var(M))
cumVar = [sum(varExp[1:i]) for i in 1:length(varExp)]
p2     = bar(name2,varExp,xlabel = "Principal Component", ylabel = "Explainded Variance",
            bar_width = 0.67,
           lw=0,
           ylim=(0,1.06),labels="Individual Explained Variance",
           yticks = range(0,1,11),
           bg_inside   = "#E5ECF6",
           background_color_legend = "#F4F7FB",
           xminorticks = 0,
           yminorticks = 0,
           colour=:darkblue,
           title="(b)",
           widen=false)
for i in eachindex(varExp)
    p2     = annotate!(i-0.5, varExp[i] +0.025, text(string(round(varExp[i]*100,digits=1))*"%", :center, 16))
end
for i in eachindex(cumVar)[2:6]
    p2     = annotate!(i-0.5, cumVar[i] +0.03, text(string(round(cumVar[i]*100,digits=1))*"%", :center, 16))
end
p2      = plot!(name2,cumVar,marker=:circle,labels="Cumulative Explained Variance",
                    colour=:red,markersize=7)


plot(p1, p2, layout = (2, 1),size=(1800,2200), left_margin = 15mm,right_margin=10mm)
savefig("PCALoadings.png")
# %%