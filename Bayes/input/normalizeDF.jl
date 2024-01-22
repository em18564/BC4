using DataFrames,CSV,StatsBase
df = CSV.read("df_gpt2.csv", DataFrame)
dhier = CSV.read("dfHierarchicalNorm.csv", DataFrame)

dfEL = subset(df, :component => ByRow(==(0)))
dfLA = subset(df, :component => ByRow(==(1)))
dfN4 = subset(df, :component => ByRow(==(2)))
dfEP = subset(df, :component => ByRow(==(3)))
dfP6 = subset(df, :component => ByRow(==(4)))
dfPN = subset(df, :component => ByRow(==(5)))
rename!(dfEL,:ERP => :ELAN)
dfEL[!,"LAN"] =  dfLA[:,:ERP]
dfEL[!,"N400"] = dfN4[:,:ERP]
dfEL[!,"EPNP"] = dfEP[:,:ERP]
dfEL[!,"P600"] = dfP6[:,:ERP]
dfEL[!,"PNP"] =  dfPN[:,:ERP]
df = dfEL
df = select!(df, Not([:component]))

df[:,:ELAN]  = (df[:,:ELAN] .- mean(df[:,:ELAN]))./std(df[:,:ELAN])
df[:,:LAN]   = (df[:,:LAN]  .- mean(df[:,:LAN]) )./std(df[:,:LAN])
df[:,:N400]  = (df[:,:N400] .- mean(df[:,:N400]))./std(df[:,:N400])
df[:,:EPNP]  = (df[:,:EPNP] .- mean(df[:,:EPNP]))./std(df[:,:EPNP])
df[:,:P600]  = (df[:,:P600] .- mean(df[:,:P600]))./std(df[:,:P600])
df[:,:PNP]   = (df[:,:PNP]  .- mean(df[:,:PNP]) )./std(df[:,:ELAN])
CSV.write("dfGptHier.csv",df)