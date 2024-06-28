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
using Serialization
using ParetoSmooth

NUM_SENTENCES = 205
NUM_PARTICIPANTS = 24
NUM_WORDS = 1931
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
dfTags   = CSV.read("../../input/full_tags.csv", DataFrame).tags
df       = CSV.read("../../input/dfPCANorm.csv", DataFrame)
df[!,"fullTag"] = dfTags
df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
# df_modified   = subset(df_modified, :fullTag => ByRow((>=(7))))
# df_modified   = subset(df_modified, :fullTag => ByRow((<=(9))))
# df_modified   = subset(df_modified, :fullTag => ByRow((!=(8))))
# df_modified.fullTag = df_modified.fullTag.-7
# df_modified.fullTag = df_modified.fullTag./2
# df_modified.fullTag = Int64.(df_modified.fullTag.+1)
dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4, :PC_5, :PC_6]]
a = subset(df_modified, :fullTag => ByRow((==(0))))
b = subset(df_modified, :fullTag => ByRow((==(5))))
b.fullTag .= 1
c = subset(df_modified, :fullTag => ByRow((==(9))))
c.fullTag .= 2
df_modified = vcat(a,b,c)
# 0 Adj
# 1 Adp
# 2 Adv
# 3 Conj
# 4 Det
# 5 Noun
# 6 Num
# 7 Pron
# 8 Prt
# 9 Verb
# 10 X