using MAT
using CSV
using DataFrames
df_old = CSV.read("df_gpt2.csv", DataFrame)


dicts = Vector{Dict{String, Any}}()
stim  = read(matopen("data/stimuli_erp.mat"),"sentences")

for i in 1:9
    file = matopen("data/EEG0"*string(i)*".mat")
    dict = read(file,"EEG")
    push!(dicts,dict)
end
for i in 10:24
    file = matopen("data/EEG"*string(i)*".mat")
    dict = read(file,"EEG")
    push!(dicts,dict)
end


for (i,d) in pairs(dicts)
    events = d["event"]["latency"][:]
    types  = d["event"]["type"][:]
    tags   = subset(subset(df_old, :component => ByRow(==(0)), :Participant => ByRow(==(i-1))))[!,:tags]

    
end

# d["data"][:,d["event"]["latency"][1]]