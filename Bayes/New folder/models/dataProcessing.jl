using MAT
using DataFrames, Turing,Plots, StatsPlots,Distributions,Measures, StatsBase,CSV

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_ERP = 6

df = CSV.read("savedData/df.csv", DataFrame)

# vars = matread(pwd() * "/data/stimuli_erp.mat")
# print(vars["tags"])
# numberOfSubjects = 24
# function genDataFrame()
#     sentences = vars["sentences"]
#     words = [w for sent in sentences for w in sent]
#     surps_full = vars["surp_ngram"]
#     logwordfreq_full = vars["logwordfreq"]
#     wordlen_full = vars["wordlength"]
    
#     surps = zeros(0)
#     logwordfreq = zeros(0)
#     wordlen = zeros(0)

#     for i in eachindex(surps_full)
#         append!(surps,surps_full[i][:,3])
#         println((surps_full[i][:,3]))
#     end 

    
#     for i in eachindex(logwordfreq_full)
#         append!(logwordfreq,logwordfreq_full[i])
#     end
#     for i in eachindex(wordlen_full)
#         append!(wordlen,wordlen_full[i])
#     end

#     ordr = vars["sentence_position"] .- 1
#     erps = vars["ERP"]
#     erp_base = vars["ERPbase"]
#     erps_comp = zeros(0)
#     erps_base_comp = zeros(0)
#     for i in eachindex(erps)
#         append!(erps_comp,(erps[i][:,:,3]))
#         append!(erps_base_comp,(erp_base[i][:,:,3]))
#     end
#     column = zeros(0)
#     surps_spread = zeros(0)
#     logwordfreq_spread = zeros(0)
#     wordlen_spread = zeros(0)
#     for i in (range(1,NUM_PARTICIPANTS))
#         append!(column,ones(NUM_WORDS).*i)
#         append!(surps_spread,surps)
#         append!(logwordfreq_spread,logwordfreq)
#         append!(wordlen_spread,wordlen)
#     end
#     repeats = floor(Int8,length(column)/NUM_WORDS)
#     words = repeat(range(1,NUM_WORDS),repeats)
    

#     df = DataFrame(Participant=column,ERP=erps_comp,ERPBase=erps_base_comp,word=words,surprisal=surps_spread,logwordfreq=logwordfreq_spread,wordlen=wordlen_spread)
#     df = filter(:ERP => E -> !(ismissing(E) || isnothing(E) || isnan(E)), df)

#     df[!,"wordlen"] = (df[!,"wordlen"].-mean(df[!,"wordlen"]))./std(df[!,"wordlen"])
#     df[!,"surprisal"] = (df[!,"surprisal"].-mean(df[!,"surprisal"]))./std(df[!,"surprisal"])
#     df[!,"logwordfreq"] = (df[!,"logwordfreq"].-mean(df[!,"logwordfreq"]))./std(df[!,"logwordfreq"])
    
#     return df
#     #println(df_test)
# end

# df = genDataFrame()
# p25 = percentile(df[!,"surprisal"],25)
# p75 = percentile(df[!,"surprisal"],75)
# df25 = subset(df, :surprisal => ByRow(<(p25)))
# df75 = subset(df, :surprisal => ByRow(>(p75)))
# CSV.write("savedData/df.csv", df)
# plot(histogram([df25[!,"ERP"],df75[!,"ERP"]],label = ["25 Percentile" "75 Percentile"]))
# savefig("savedData/hist")
# println(mean(df25[!,"ERP"]))
# println(mean(df75[!,"ERP"]))
#build DataFrame
#make sure nothing is missed
#do sanity check! Take most/least surp 25% and the look at prob dist of the ERP