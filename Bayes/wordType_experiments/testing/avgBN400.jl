include("../setup.jl")
include("../typeStructures.jl")
include("../model_master.jl")
include("../plottingFuncs.jl")
# %%
od =  "models/testingDifferentPCS/output_FullADP_23_1931_NOPCA"
chndfs = []
ssdfs  = []
for i in range(1,6)
    push!(chndfs,CSV.read(od*"/chndf_"*string(i),DataFrame))
    push!(ssdfs,CSV.read(od*"/ssdf_"*string(i),DataFrame))
end
# %%
using Counters
dfTags   = CSV.read("../input/full_tags.csv", DataFrame)
wordEncodings = Dict(   0=>"Adjective",2=>"Adverb",
                        3=>"Conjunction",4=>"Determiner",5=>"Noun",6=>"Numeral",
                        7=>"Pronoun",8=>"Particle",9=>"Verb",11=>"Adposition (lex)",12=>"Adposition (sub)",13=>"Adposition (syn)")
newTags = dfTags[dfTags.Participant.==1,:].newTags
k = [0,2,3,4,5,6,7,8,9,11,12,13]
x = [wordEncodings[i] for i in k]
y = [counter(newTags)[i] for i in k]
props = y/sum(y)

# %%
xs = 1:6

function getAvgB(val)
    pEffects = [StatsBase.mean(chndfs[val].σ_bp)* StatsBase.mean(chndfs[val][!,"b_ps["*string(i)*"]"]) for i in range(1,23)]
    cEffects = [StatsBase.mean(chndfs[val].σ_bw)* StatsBase.mean(chndfs[val][!,"b_ws["*string(i)*"]"]) for i in range(1,12)]
    baseEffect = StatsBase.mean(chndfs[val].b_e)
    sum = baseEffect + StatsBase.mean(pEffects*1/23) + StatsBase.mean(cEffects.*props)
    return sum
end
Plots.bar(xs,getAvgB.(xs),ylim=(-0.1,0.2),label="avgB")
yticks!([-0.1:0.05:0.2;])
xticks!([1:1:6;], ["ELAN","LAN","N400","EPNP","P600","PNP"])
Plots.savefig("avgB.png")
