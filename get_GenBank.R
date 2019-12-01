## Code for downloading batches of DNA sequences from GenBank for multiple
## genes at a time.
## Written by Vikram B. Baliga
## Last updated: 2019-11-30


###### now try multigenes ######
library(tidyverse)

## the imported csv file should have: 
## column 1 = species names; example file uses "binomial" as column name
## each successive column represents one gene
## each row is one species
accessions_batch <- read_csv("./multigene_accessions_test.csv")

accessions_list <- 
  accessions_batch %>% 
  ## exclude species names
  dplyr::select(-binomial) %>% 
  ## coerce to list
  as.list() %>% 
  ## remove NAs
  lapply(function(x) x[!is.na(x)])

test <- lapply(accessions_list, ape::read.GenBank, species.names = TRUE)
