## Code for downloading batches of DNA sequences from GenBank for multiple
## genes at a time.
## 
## Written by Vikram B. Baliga
## Last updated: 2019-11-30


############################### package loading ################################
## For data wrangling
library(tidyverse)
## For reading from GenBank
library(ape)


################################# data import ##################################
## The imported csv file should have: 
## column 1 = species names; example file uses "binomial" as this column name
## each successive column represents one gene
## each row is one species
accessions_batch <- read_csv("./multigene_accessions_test.csv")

## now exclude the column with species names and make a list of each gene set
accessions_list <- 
    accessions_batch %>% 
  ## exclude species names
    dplyr::select(-binomial) %>% 
  ## coerce to list
    as.list() %>% 
  ## remove NAs
    lapply(function(x) x[!is.na(x)])


################################ batch downloading #############################
## It is possible to use lapply() on accessions_list to apply read.GenBank()
## to each gene within the list. BUT, you'll run into a `429 Too Many Requests` 
## after the first few hundred. It's an API issue. The code below gives an 
## example of this, which won't work. Maybe someday this will be permissible...

#test <- lapply(accessions_list, ape::read.GenBank, species.names = TRUE)

## Instead, a for() loop seems to be the way to go
## Use Sys.sleep() to make R momentarily pause before running the next line.
## This prevents overloading the API.
## I've found a 5-sec pause seems to work; YMMV.
sleep_factor <- 5

## The for() loop
## First make a blank list
sequences_set <- list()
for (i in 1:length(accessions_list)){
  ## Now use read.GenBank to get the seqs
  sequences_set[[i]] <- read.GenBank(accessions_list[[i]], 
                                      species.names = TRUE)
  ## Take a momentary pause to not overload the API
  Sys.sleep(sleep_factor)
  ## Print the iteration # to track progress
  print(i)
}

## Now make list of gene names
gene_names <- 
  colnames(accessions_batch)[-1] %>%
  paste0("_seqs")
