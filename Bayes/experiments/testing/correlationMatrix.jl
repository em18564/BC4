
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
NUM_SENTENCES = 205
NUM_PARTICIPANTS = 6
NUM_WORDS = 800
NUM_TYPES = 2
NUM_ERP = 6 # ELAN, LAN, N400, EPNP, P600, PNP
dfo = CSV.read("../../input/dfHierarchical.csv", DataFrame)
df_modified_1 = subset(dfo, :Participant => ByRow(<(NUM_PARTICIPANTS)))
df_modified = subset(df_modified_1, :Word => ByRow(<(NUM_WORDS)))
df = df_modified[:,[:"ELAN",:"LAN",:"N400",:"EPNP",:"P600",:"PNP"]]
correlation = cor(Matrix(df))
covariance  = cov(Matrix(df))

a = [1.0        0.181342   0.0810761  0.0116194  -0.0903498  -0.10144
0.181342   1.0        0.566544   0.339601    0.0354594   0.0669557
0.0810761  0.566544   1.0        0.310265    0.246098    0.150833
0.0116194  0.339601   0.310265   1.0         0.331713    0.675938
-0.0903498  0.0354594  0.246098   0.331713    1.0         0.679675
-0.10144    0.0669557  0.150833   0.675938    0.679675    1.0]