using Distributions
using StatsPlots
using StatsBase
using LaTeXStrings
using CSV
using DataFrames
using StatisticalRethinking
using StatisticalRethinking: link
using LinearAlgebra
using Logging
using Random
using Turing
m_df = CSV.read("savedData/m_df.csv", DataFrame)
df = CSV.read("savedData/df.csv", DataFrame)
#precis(df)
#precis(m_df)
#print(df[1,"ERP"])
sum=0
for i in 1:length(df[!,"ERP"])
    a1 = (m_df[1,"a1"])
    a2 = (m_df[1,string("a2[",string(Int(df[i,"Participant"])),"]")])
    a3 = (m_df[1,string("a3[",string(Int(df[i,"word"])),"]")])
    b1 = (m_df[1,"b1"])
    b2 = (m_df[1,string("b2[",string(Int(df[i,"Participant"])),"]")])
    b3 = (m_df[1,string("b3[",string(Int(df[i,"word"])),"]")])
    PredERP = (a1 + a2 + a3) + (b1 + b2 + b3) * df[i,"surprisal"]
    global sum +=  ((df[i,"ERP"]-PredERP)/df[i,"ERP"])
end
print(sum/length(df[!,"ERP"]))
