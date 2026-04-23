
function createVariables()
    args = map(x->string(x), ARGS)
    pc   = parse(Int,args[1])
    NUM_PARTICIPANTS = parse(Int,args[2])
    NUM_WORDS = parse(Int,args[3])
    TYPE_STRUCTURE = args[4]
    dfTags   = CSV.read("../../../input/full_tags.csv", DataFrame).tags
    df       = CSV.read("../../../input/dfPCANorm_corrected.csv", DataFrame)
    df[!,"fullTag"] = dfTags
    df_modified = subset(df, :Participant => ByRow(<(NUM_PARTICIPANTS)))
    df_modified = subset(df_modified, :Word => ByRow(<(NUM_WORDS)))
    NUM_TYPES,df_modified,wordTypes,cols = processTypeStructure(df_modified,TYPE_STRUCTURE)
    dfPCA = df_modified[:, [:PC_1, :PC_2, :PC_3, :PC_4]]
    return df_modified, dfPCA, pc, NUM_PARTICIPANTS,  NUM_WORDS, TYPE_STRUCTURE, NUM_TYPES,wordTypes,cols
end