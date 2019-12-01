###### for downloading protein sequences ######
library(rentrez)

## import sequence list from a CSV
IDs <- read.table("./protein_accessions.csv",
                  quote="\"", stringsAsFactors=FALSE)

## convert to character lists
as.list(IDs)$V1 -> prot_list

## use entrez_fetch() to get the protein FASTAs
prot_gen<-entrez_fetch(id=prot_list,
                       db="protein",rettype = "fasta")

## write to file
write(prot_gen, file="my_proteins.fasta")



###### for downloading DNA sequences ######
library(ape)

## import each sequence list from its CSV file
## NO "strings as factor"
coi <- read.table("./COI_BaligaLaw2016.csv",
                  quote="\"", stringsAsFactors=FALSE)

## convert to character lists
as.list(coi)$V1 -> coi_list

## use read.GenBank to acquire the sequences
coi_gen <- read.GenBank(coi_list, species.names = T)

## use species names
names_coi<-data.frame(species=attr(coi_gen,"species"),accs=names(coi_gen))
names(coi_gen)<-attr(coi_gen,"species")

## set WD!!

## export each
write.dna(coi_gen,"renamed_COI.fasta", format="fasta")


###### now try multigenes ######
library(tidyverse)

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
