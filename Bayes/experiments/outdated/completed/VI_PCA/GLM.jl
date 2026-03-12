using GLM, LinearRegression,Plots, TypedTables, CSV, DataFrames, DecisionTree
df_full = CSV.read("../../input/dfHierarchicalNorm.csv", DataFrame)
df = df_full[:, [:ELAN, :LAN, :N400, :EPNP, :P600, :PNP]]
df_Y = Vector(df_full[:, :Tags])
df_X = Matrix(df)

t = Table(ELAN = df_X[:,1],LAN  = df_X[:,2],N400 = df_X[:,3],
          EPNP = df_X[:,4],P600 = df_X[:,5],PNP  = df_X[:,6], Y = df_Y)

lr = linregress(df_X,df_Y)
ols = lm(@formula(Y ~ ELAN+LAN+N400+EPNP+P600+PNP), t)
model = build_tree(df_Y, df_X)
model = prune_tree(model, 0.9)
preds = apply_tree(model, df_X)
DecisionTree.confusion_matrix(df_Y, preds)
