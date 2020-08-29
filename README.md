---
output: github_document
---



# rstanbtm

The goal of rstanbtm is to provide functions to fit a 
[Biterm Topic Model](https://www.researchgate.net/publication/262244963_A_biterm_topic_model_for_short_texts)
with R and Stan.

## Installation

You can install rstanbtm with:


```r
remotes::install_github('https://github.com/assuncaolfi/rstanbtm')
#> Skipping install of 'rstanbtm' from a github remote, the SHA1 (822b0249) has not changed since last install.
#>   Use `force = TRUE` to force installation
```

## Example

This example fits the same data of the example from the 
excellent [BTM](https://github.com/bnosac/BTM) package, 
using rstanbtm functions for biterm construction and 
model fitting instead.


```r
library(rstanbtm)
library(data.table)
library(parallel)
library(udpipe)

## Annotate text with parts of speech tags
data("brussels_reviews", package = "udpipe")
anno <- subset(brussels_reviews, language %in% "nl")
anno <- data.frame(
    doc_id = anno$id,
    text = anno$feedback,
    stringsAsFactors = FALSE
)
anno <- udpipe(anno, "dutch", trace = 10)

## Get cooccurrences of nouns / adjectives and proper nouns
biterms <- as.data.table(anno)
biterms <- biterms[
    TRUE,
    cooccurrence(
        x = lemma, 
        relevant = upos %in% c("NOUN", "PROPN", "ADJ"),
        skipgram = 2
    ), 
    by = list(doc_id)
]


## Get number of cores
cores <- detectCores()
                   
## Build the model
set.seed(123456)
biterms <- id_terms(biterms)
model <- btm(
    biterms, 
    k = 5,
    alpha = 50 / 5,
    beta = 0.01,
    chains = 4,
    cores = cores
)
```



