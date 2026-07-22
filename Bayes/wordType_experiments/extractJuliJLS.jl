# %%

include("setup.jl")
include("typeStructures.jl")
include("model_master.jl")
include("plottingFuncs.jl")
#using SkipNan
#using ExactOptimalTransport,OptimalTransport
#using KernelDensity

#using SlicedWasserstein
#using PhyloTrees
#using Phylo
# 1 Adj
# 2 Adp
# 3 Adv
# 4 Conj
# 5 Det
# 6 Noun
# 7 Num
# 8 Pron
# 9 Prt
# 10 Verb
outputDirs =[   "models/testingDifferentPCS/output_FullADP_23_1931_6PCA_250",
                "models/testingDifferentPCS/output_FullADP_23_1931_6PCA_1000",
                "models/testingDifferentPCS/output_NoNum_23_1931_6PCA_250",
                "models/testingDifferentPCS/output_NoNum_23_1931_6PCA_1000"]          

function extractFiles(outputDir)
    chn1 = deserialize(outputDir*"/out1.jls")
    chn2 = deserialize(outputDir*"/out2.jls")
    chn3 = deserialize(outputDir*"/out3.jls")
    chn4 = deserialize(outputDir*"/out4.jls")
    chn5 = deserialize(outputDir*"/out5.jls")
    chn6 = deserialize(outputDir*"/out6.jls")
    chn_df1 = DataFrames.DataFrame(chn1)
    chn_df2 = DataFrames.DataFrame(chn2)
    chn_df3 = DataFrames.DataFrame(chn3)
    chn_df4 = DataFrames.DataFrame(chn4)
    chn_df5 = DataFrames.DataFrame(chn5)
    chn_df6 = DataFrames.DataFrame(chn6)
    ss_df1  = DataFrames.DataFrame(summarystats(chn1))
    ss_df2  = DataFrames.DataFrame(summarystats(chn2))
    ss_df3  = DataFrames.DataFrame(summarystats(chn3))
    ss_df4  = DataFrames.DataFrame(summarystats(chn4))
    ss_df5  = DataFrames.DataFrame(summarystats(chn5))
    ss_df6  = DataFrames.DataFrame(summarystats(chn6))
    chndfs  = [chn_df1, chn_df2, chn_df3, chn_df4, chn_df5, chn_df6]
    ssdfs   = [ss_df1,  ss_df2,  ss_df3,  ss_df4,  ss_df5,  ss_df6 ]
    for i in eachindex(chndfs)
        CSV.write(outputDir*"/chndf_"*string(i),chndfs[i])
        CSV.write(outputDir*"/ssdf_"*string(i),chndfs[i])
    end
end

for od in outputDirs
    extractFiles(od)
end
