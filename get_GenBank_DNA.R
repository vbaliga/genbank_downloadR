## Code for downloading batches of DNA sequences from GenBank for multiple
## genes at a time.
## 
## Written by Vikram B. Baliga
## Last updated: 2019-12-05


############################### package loading ################################
## Specify the packages you'll use in the script
packages <- c("tidyverse", "ape")
## Now for each package you listed, first check to see if the package is already
## installed. If it is installed, it's simply loaded. If not, it's downloaded 
## from CRAN and then installed and loaded.
package.check <- lapply(packages,
                        FUN = function(x) {
                          if (!require(x, character.only = TRUE)) {
                            install.packages(x, dependencies = TRUE)
                            library(x, character.only = TRUE)
                            }
                          }
                        )


################################# data import ##################################
## The imported csv file should have: 
##  - column 1 = species names; example file uses "binomial" as this column name
##  - each successive column represents one gene
##  - each row is one species
accessions_batch <- read_csv("./Baliga_et_al_2019_SciAdv_all_genes.csv")

## Now exclude the column with species names and make a list of each gene set
accessions_list <- 
    accessions_batch %>% 
  ## exclude species names
    dplyr::select(-binomial) %>% 
  ## coerce to list
    as.list() %>% 
  ## remove NAs
    lapply(function(x) x[!is.na(x)])

## OPTIONAL:
## Perform a check - does the number of genes match expectations?
## Next block of code is commented out so it doesn't run; un-comment if you want
## to use it.
### First state how many genes you expect
#number_of_genes <- 12
### Now test
#ifelse(length(accessions_list) == number_of_genes, 
#       yes = "Number of genes matches expectations", 
#       no = stop("\nNumber of genes does not match your expectations. 
#                 \nPlease check how data are being imported."))


################################ batch downloading #############################
## It is possible to use lapply() on accessions_list to apply read.GenBank()
## to each gene within the list. BUT, you'll run into a `429 Too Many Requests` 
## after the first few hundred. It's an API issue. The code below gives an 
## example of this, which won't work. Maybe someday this will be permissible...

#test <- lapply(accessions_list, ape::read.GenBank, species.names = TRUE)

## Instead, we'll use purrr::slowly() along with map().
## Use rate_delay() to make R momentarily pause before running the next line.
## This prevents overloading the API.

## I've found a 2-sec pause seems to work; YMMV.
sleep_timer <- rate_delay(2)

## Now use slowly() to take ape::read.GenBank() and wait 5 secs
slow_pulls <- slowly(~ read.GenBank(.x, species.names = TRUE), 
                     rate = sleep_timer,
                     quiet = FALSE)

## Now map this function, using accessions_list
sequences_set <- 
    map(accessions_list, slow_pulls) %>%
  ## And rename according to species instead of accession IDs
    lapply(function(x) {
      attr(x, "species") -> attr(x, "names")
      return(x)
    })


################################ writing to files ##############################
## First make list of gene names to prep for file export
gene_names <- 
  colnames(accessions_batch)[-1] %>%
  paste0("_seqs.fasta")

## Write each set of sequences to FASTA files
invisible(lapply(1:length(sequences_set),
                 function(x) {
                   write.dna(sequences_set[[x]],
                             gene_names[[x]],
                             format = "fasta")
                 }))

