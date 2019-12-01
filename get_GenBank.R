## Code for downloading batches of DNA sequences from GenBank for multiple
## genes at a time.
## 
## Written by Vikram B. Baliga
## Last updated: 2019-12-01


############################### package loading ################################
packages <- c("tidyverse", "ape")
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)


################################# data import ##################################
## The imported csv file should have: 
## column 1 = species names; example file uses "binomial" as this column name
## each successive column represents one gene
## each row is one species
accessions_batch <- read_csv("./multigene_accessions_test.csv")

## Now exclude the column with species names and make a list of each gene set
accessions_list <- 
    accessions_batch %>% 
  ## exclude species names
    dplyr::select(-binomial) %>% 
  ## coerce to list
    as.list() %>% 
  ## remove NAs
    lapply(function(x) x[!is.na(x)])

## Perform a check - does the number of genes match expectations?
## First state how many genes you expect
number_of_genes <- 20
## Now test
ifelse(length(accessions_list) == number_of_genes, 
       yes = "Number of genes matches expectations", 
       no = stop("\nNumber of genes does not match your expectations. 
                 \nPlease check how data are being imported."))

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
sleep_timer <- 5

## The for() loop
## First make a blank list
sequences_set <- list()
for (i in 1:length(accessions_list)){
  ## Now use read.GenBank to get the seqs
  sequences_set[[i]] <- read.GenBank(accessions_list[[i]], 
                                      species.names = TRUE)
  ## Take a momentary pause to not overload the API
  Sys.sleep(sleep_timer)
  ## Print the iteration # to track progress
  print(i)
}

## Now rename according to species
for (i in 1:length(sequences_set)){
  names(sequences_set[[i]]) <- attr(sequences_set[[i]], "species")
}


################################ writing to files ##############################
## First make list of gene names to prep for file export
gene_names <- 
  colnames(accessions_batch)[-1] %>%
  paste0("_seqs.fasta")

## Use a for() loop to iteratively write each set of sequences to FASTA files
for (i in 1:length(sequences_set)){
  write.dna(sequences_set[[i]], gene_names[[i]], format = "fasta")
}


