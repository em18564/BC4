# %%
using DataFrames,CSV,StatsBase


sent                = CSV.File("sentences.csv", header=false) |> Tables.matrix


df_with_words       = CSV.read("df_WithWords.csv",DataFrame)
words               = df_with_words[df_with_words.Participant.==0,"realWord"]
wordIds             = df_with_words[df_with_words.Participant.==0,"word"]
wordTags            = df_with_words[df_with_words.Participant.==0,"tags"]


# %%
restructureArray(wordArray) = [filter((i) -> i != "",[replace(innerword,"." => ""," "=>"") for innerword in split(innersent,",")[2:end]])
                                for innersent in wordArray]

r_sent              = restructureArray(sent)

engSent = [replace(replace(s,",,"=>"@"),","=>" ","@"=>",") for s in sent]

# %%
adpSentenceIds = []
adpSentences   = Dict()
adpWords       = Dict()
adpWordIds     = Dict()
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
        
        if(wordTags[i]=="ADP")
            if(!(curRow in adpSentenceIds))
                push!(adpSentenceIds,curRow)
                adpSentences[curRow] = engSent[curRow]
                adpWords[curRow] = []
                adpWordIds[curRow] = []
            end
            push!(adpWords[curRow],  r_sent[curRow][curWord])
            push!(adpWordIds[curRow],i)
            
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
doneAdpSentences = []

# %%
for id in adpSentenceIds
    if !(id in doneAdpSentences)
        for i in eachindex(adpWords[id])
            complete = false
            while !complete
                complete = true
                print("\033c")
                println("(A) Lexical: prepositions used for location and time in English")
                println("  e.g: Nina put the book *on/under/at/next* to DP the table.")
                println()
                println("(S) Subcategorised: grammaticized, collocative, non-lexical or dependent")
                println("  e.g: Everyone picked *on* the new student.")
                println()
                println("(D) Syntactic:  possessive *of*, passive *by*")
                println("  e.g: The younger children are assisted *by* their teachers.")
                println()
                println("(A) Lexical, (S) Subcategorised, (D) Syntactic or (F) Unsure")
                println()
                println(adpSentences[id])
                println(adpWords[id][i])
                println()

                input = readline()
                if input == "A"
                    newWordTags[adpWordIds[id][i]] = "ADP_LEX"
                elseif input == "S"
                    newWordTags[adpWordIds[id][i]] = "ADP_SUB"
                elseif input == "D"
                    newWordTags[adpWordIds[id][i]] = "ADP_SYN"
                elseif input == "F"
                    newWordTags[adpWordIds[id][i]] = "ADP_UNS"

                else
                    println("try again:")
                    complete = false
                end
            end
            

            newWordTags[adpWordIds[id][i]]
        end
        push!(doneAdpSentences,id)
    end 
end

# %%
using Tables

CSV.write("saved.csv",Tables.table(newWordTags), header=false)

# %%
wordToTag = Dict()
for i in eachindex(wordIds)
    wordToTag[wordIds[i]] = newWordTags[i]
end
# %%
newTags    = [wordToTag[word] for word in df_with_words.word]

tagToTagId = Dict(  "ADJ"       => 0,
                    "ADV"       => 2,
                    "CONJ"      => 3,
                    "DET"       => 4,
                    "NOUN"      => 5,
                    "NUM"       => 6,
                    "PRON"      => 7,
                    "PRT"       => 8,
                    "VERB"      => 9,
                    "X"         => 10,      
                    "ADP_LEX"   => 11,
                    "ADP_SUB"   => 12,
                    "ADP_SYN"   => 13)

newTagsIds = [tagToTagId[tag] for tag in newTags]

# %%
df_with_words.tags_sepAdp    = newTags
df_with_words.tagsIds_sepAdp = newTagsIds

CSV.write("df_with_words_2.csv",df_with_words)

dfFullTags = CSV.read("full_tags.csv",DataFrame)
dfFullTags.newTags = newTagsIds

CSV.write("full_tags.csv",dfFullTags)