using MAT
using CSV
using DataFrames
df_old = CSV.read("dfPCA.csv", DataFrame)


dicts = Vector{Dict{String, Any}}()
stim  = read(matopen("data/stimuli_erp.mat"),"sentences")

for i in 1:9
    file = matopen("data/EEG0"*string(i)*".mat")
    dict = read(file,"EEG")
    if i == 6
        global dictPart2 = read(file,"EEG_part2")
    end
     push!(dicts,dict)


    
end
for i in 10:24
    file = matopen("data/EEG"*string(i)*".mat")
    dict = read(file,"EEG")
    push!(dicts,dict)
end

df = DataFrame( Participant = Integer[], Tag = Integer[], Word = Integer[],
                EEG1=Float64[], EEG2=Float64[], EEG3=Float64[], EEG4=Float64[], EEG5=Float64[], EEG6=Float64[], EEG7=Float64[], EEG8=Float64[], EEG9=Float64[], EEG10=Float64[],
                EEG11=Float64[],EEG12=Float64[],EEG13=Float64[],EEG14=Float64[],EEG15=Float64[],EEG16=Float64[],EEG17=Float64[],EEG18=Float64[],EEG19=Float64[],EEG20=Float64[], 
                EEG21=Float64[],EEG22=Float64[],EEG23=Float64[],EEG24=Float64[],EEG25=Float64[],EEG26=Float64[],EEG27=Float64[],EEG28=Float64[],EEG29=Float64[],EEG30=Float64[], 
                EEG31=Float64[],EEG32=Float64[],EEG33=Float64[],EEG34=Float64[])

for (i,d) in pairs(dicts)
    events = d["event"]["latency"][:]
    types  = d["event"]["type"][:]
    data   = d["data"]
    tags   = (subset(df_old, :Participant => ByRow(==(i-1))))[!,:Tags]
    words  = (subset(df_old, :Participant => ByRow(==(i-1))))[!,:Word]
    for (j,w) in pairs(words)
        if i == 9
            global limit = 1917
        elseif i == 13
            global limit = 1918
        elseif i == 14
            global limit = 1902
        elseif i == 20
            global limit = 1881
        else
            global limit = 1932
        end

        if i == 6
            if w < 1420
                lat  = Integer(events[Integer(w)])
                EEGs = data[:,lat:lat+174]




                for k in 1:(length(EEGs[1,:]))
                    push!(df, vcat(i,tags[j],Integer(w),EEGs[:,k]))
                end
            elseif w<1833
                lat  = Integer(dictPart2["event"]["latency"][Integer(w)-1419])
                data = dictPart2["data"]
                EEGs = data[:,lat:lat+174]
                for k in 1:(length(EEGs[1,:]))
                    push!(df, vcat(i,tags[j],Integer(w),EEGs[:,k]))
                end            
            end
        else
            if w < limit
                lat  = Integer(events[Integer(w)])
                EEGs = data[:,lat:lat+174]
                for k in 1:(length(EEGs[1,:]))
                    push!(df, vcat(i,tags[j],Integer(w),EEGs[:,k]))
                end
                
            end




        end
    end    
end
CSV.write("dfEEG.csv", df)

# d["data"][:,d["event"]["latency"][1]]