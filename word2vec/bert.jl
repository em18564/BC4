using Flux,Transformers
using Transformers.TextEncoders
using Transformers.HuggingFace
textencoder, bert_model = hgf"bert-base-uncased"
