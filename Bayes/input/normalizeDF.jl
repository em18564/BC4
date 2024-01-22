using DataFrames,CSV,StatsBase
df = CSV.read("dfHierarchical.csv", DataFrame)
df[:,:ELAN]  = (df[:,:ELAN] .- mean(df[:,:ELAN]))./std(df[:,:ELAN])
df[:,:LAN]   = (df[:,:LAN]  .- mean(df[:,:LAN]) )./std(df[:,:LAN])
df[:,:N400]  = (df[:,:N400] .- mean(df[:,:N400]))./std(df[:,:N400])
df[:,:EPNP]  = (df[:,:EPNP] .- mean(df[:,:EPNP]))./std(df[:,:EPNP])
df[:,:P600]  = (df[:,:P600] .- mean(df[:,:P600]))./std(df[:,:P600])
df[:,:PNP]   = (df[:,:PNP]  .- mean(df[:,:PNP]) )./std(df[:,:ELAN])
CSV.write("dfHierarchicalNorm.csv",df)