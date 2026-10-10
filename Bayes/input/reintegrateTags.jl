# %%
using DataFrames,CSV,StatsBase

df_Old       = CSV.read("full_tags.csv",DataFrame)
df_newTags   = CSV.read("wordTags.csv",DataFrame)
fixedNouns   = CSV.read("fixedNouns.csv",DataFrame)
df_newTags.nounTags = fixedNouns.nounTags
# %%
detTags = Int.(zeros(size(df_newTags)[1]))
for rowId in range(1,size(df_newTags)[1]-1)
    if (df_newTags[rowId,1]== 4)
        found = false
        curRowId = rowId
        while (!found)
            curRowId = curRowId + 1
            if (df_Old.word[curRowId] - df_Old.word[curRowId-1]) > 1
                detTags[rowId] = 6
                found = true
            else
                if (df_newTags[curRowId,1]== 5) 
                    detTags[rowId] = df_newTags[curRowId,2]
                    found = true
                end
            end
        end
        
        
    end
end
# %%
dict = Dict(subset(df_Old, :Participant => ByRow((==(1)))).word .=> range(1,length(detTags)))

indexes = [dict[word] for word in df_Old.word]
df_Old[!,"newBaseTags"] = df_newTags.baseTags[indexes]
df_Old[!,"nounTags"]    = df_newTags.nounTags[indexes]
df_Old[!,"adpTags"]     = df_newTags.adpTags[indexes]
df_Old[!,"detTags"]     = detTags[indexes]
# %%

CSV.write("dfWithTagsReintigrated.csv",df_Old)