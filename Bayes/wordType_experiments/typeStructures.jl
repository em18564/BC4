
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


function processTypeStructure(df_modified,TYPE_STRUCTURE)
    if(TYPE_STRUCTURE == "FullCF")
        NUM_TYPES = 5
        adj = subset(df_modified, :fullTag => ByRow((==(0))))
        adj.fullTag .= 0
        noun = subset(df_modified, :fullTag => ByRow((==(5))))
        noun.fullTag .= 1
        verb = subset(df_modified, :fullTag => ByRow((==(9))))
        verb.fullTag .= 2
        adv = subset(df_modified, :fullTag => ByRow((==(2))))
        adv.fullTag .= 3
        f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(1)))),
                subset(df_modified, :fullTag => ByRow((==(8)))),
                subset(df_modified, :fullTag => ByRow((==(3)))))
        f.fullTag .= 4
        df_modified = vcat(adj,noun,verb,adv,f)
        wordTypes = ["Adjective","Noun","Verb","Adverb","Function"]
        cols = [palette(:tab10)[i] for i in range(1,10)]
    elseif(TYPE_STRUCTURE == "CF")
        c = vcat( subset(df_modified, :fullTag => ByRow((==(0)))),
          subset(df_modified, :fullTag => ByRow((==(5)))),
          subset(df_modified, :fullTag => ByRow((==(9)))),
          subset(df_modified, :fullTag => ByRow((==(2)))))
        f = vcat( subset(df_modified, :fullTag => ByRow((==(6)))),
                subset(df_modified, :fullTag => ByRow((==(4)))),
                subset(df_modified, :fullTag => ByRow((==(7)))),
                subset(df_modified, :fullTag => ByRow((==(1)))),
                subset(df_modified, :fullTag => ByRow((==(8)))),
                subset(df_modified, :fullTag => ByRow((==(3)))))
        c.fullTag .= 0
        f.fullTag .= 1
        df_modified = vcat(c,f)
        NUM_TYPES = 2
        wordTypes = ["Content","Function"]
        cols = ["#3D9970", "#7D0DC3"]

    elseif(TYPE_STRUCTURE == "Full")
        NUM_TYPES = 10
        wordTypes = ["Adjective","Adposition","Adverb",
                        "Conjunction","Determiner","Noun","Numeral",
                        "Pronoun","Particle","Verb"]
        cols = [palette(:tab10)[i] for i in range(1,10)]

    else()
        throw("Illegal type structure")
    end


    return NUM_TYPES,df_modified,wordTypes,cols
end



