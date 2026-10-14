# %%
using DataFrames,CSV,StatsBase

df_Old       = CSV.read("full_tags.csv",DataFrame)
df_newTags   = CSV.read("wordTags.csv",DataFrame)
fixedNouns   = CSV.read("fixedDF3.csv",DataFrame)
df_newTags.nounTags = fixedNouns.nounTags
# %%

sent                = CSV.File("sentences.csv", header=false) |> Tables.matrix


df_with_words       = CSV.read("df_WithWords.csv",DataFrame)
words               = df_with_words[df_with_words.Participant.==0,"realWord"]
wordIds             = df_with_words[df_with_words.Participant.==0,"word"]
wordTags            = fixedNouns.baseTags


restructureArray(wordArray) = [filter((i) -> i != "",[replace(innerword,"." => ""," "=>"") for innerword in split(innersent,",")[2:end]])
                                for innersent in wordArray]

r_sent              = restructureArray(sent)

engSent = [replace(replace(s,",,"=>"@"),","=>" ","@"=>",") for s in sent]

detSentenceIds = []
detSentences   = Dict()
detWords       = Dict()
detWordIds     = Dict()
function checkWords()
    i       = 1
    curRow  = 1
    curWord = 1
    for wordId in eachindex(wordIds[1:end])
    
        try
            @assert(r_sent[curRow][curWord]  ==replace(words[i],"," => ""," "=>""))
        catch e
            println()
            println(string(curRow),"-",string(curWord),",",string(i),":")
            println(r_sent[curRow][curWord],"-",words[i])
            println()
            throw(e)
        end
        
        if(wordTags[i]==4)
            if(!(curRow in detSentenceIds))
                push!(detSentenceIds,curRow)
                detSentences[curRow] = engSent[curRow]
                detWords[curRow] = []
                detWordIds[curRow] = []
            end
            push!(detWords[curRow],  r_sent[curRow][curWord])
            push!(detWordIds[curRow],i)
            
        end
        


        i+=1
        curWord+=1

        if wordId != length(wordIds)
            if wordIds[wordId+1] - wordIds[wordId] != 1
                curRow+=1
                curWord=1
            end
        end
    end
    
end

checkWords()
# %%
newWordTags = wordTags
donedetSentences = []
detTags = Int.(zeros(size(df_newTags)[1]))

# %%

for id in detSentenceIds
    if !(id in donedetSentences)
        for i in eachindex(detWords[id])
            complete = false
            while !complete
                complete = true
                if (wordIds[detWordIds[id][i]+1] - wordIds[detWordIds[id][i]] == 1) && (wordTags[detWordIds[id][i]+1] == 5)
                    detTags[detWordIds[id][i]] = fixedNouns.nounTags[detWordIds[id][i]+1] 
                elseif (wordIds[detWordIds[id][i]+2] - wordIds[detWordIds[id][i]] == 2) && (wordTags[detWordIds[id][i]+1] == 0) && (wordTags[detWordIds[id][i]+2] == 5)
                        detTags[detWordIds[id][i]] = fixedNouns.nounTags[detWordIds[id][i]+2] 
                else
                    println("(A) Subject, (S) Direct-Object, (D) Indirect-Object, (F) Prepositional Object or (G) Adverbial Modifier")
                    println()
                    println(detSentences[id])
                    println(words[detWordIds[id][i]-1]," (",detWords[id][i],") ",words[detWordIds[id][i]+1])
                    println()

                    input = readline()
                    if input == "A"
                        detTags[detWordIds[id][i]] = 1
                    elseif input == "S"
                        detTags[detWordIds[id][i]] = 2
                    elseif input == "D"
                        detTags[detWordIds[id][i]] = 3
                    elseif input == "F"
                        detTags[detWordIds[id][i]] = 4
                    elseif input == "G"
                        detTags[detWordIds[id][i]] = 5

                    else
                        println("try again:")
                        complete = false
                    end
                end
                
                
            end
            

        end
        push!(donedetSentences,id)
    end 
end

# %%
dict = Dict(subset(df_Old, :Participant => ByRow((==(1)))).word .=> range(1,length(detTags)))

indexes = [dict[word] for word in df_Old.word]
df_Old[!,"newBaseTags"] = fixedNouns.baseTags[indexes]
df_Old[!,"nounTags"]    = fixedNouns.nounTags[indexes]
df_Old[!,"adpTags"]     = fixedNouns.adpTags[indexes]
df_Old[!,"detTags"]     = detTags[indexes]
# %%

CSV.write("dfWithTagsReintigratedNew.csv",df_Old)