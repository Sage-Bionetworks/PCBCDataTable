library(dplyr)
library(tidyr)
library(stringr)

library(synapseClient)

synapseLogin()

# Which columns to consider
colsToUse <- c('id', 'dataType', 'fileType', 'fileSubType', 'UID', 'biologicalSampleName', 
               'C4_Cell_Line_ID', 'Originating_Lab_ID', 'Originating_Lab', 'Cell_Line_Type',
               'Cell_Type_of_Origin', 'Tissue_of_Origin', 'Reprogramming_Vector_Type',
               'Reprogramming_Gene_Combination', 'pass_qc', 'exclude')

# query the table with specific columns
colsToUseStr <- paste(colsToUse, collapse=",")
queryTemplate <- "select %s from file where benefactorId=='syn1773109' and dataType=='%s'"

cache <- NA
# cache <- "syn"

if (!is.na(cache)) {
  obj <- synGet(cache)
  load(getFileLocation(obj))
} else {
  rnaData <- synQuery(sprintf(queryTemplate, colsToUseStr, 'mRNA'), 
                      blockSize=300)$collectAll()
  
  mirnaData <- synQuery(sprintf(queryTemplate, colsToUseStr, 'miRNA'), 
                        blockSize=400)$collectAll()
  
  methylationData <- synQuery(sprintf(queryTemplate, colsToUseStr, 'methylation'), 
                              blockSize=400)$collectAll()
  
  # Combine the data together
  allData <- rbind(rnaData, mirnaData, methylationData)
  colnames(allData) <- gsub(".*\\.", "", colnames(allData))
  allData <- allData[, colsToUse]
  
  # Turn IDs into urls that open in new tab/window
  allData$id <- paste('<a href="https://www.synapse.org/#!Synapse:', allData$id, '" target="_blank">', allData$id, '</a>', sep="")
  
  # Filtering for specific data types and making the data for specific tabs
  mrna <- allData %>% 
    filter(dataType=='mRNA') %>%
    filter(!is.na(UID),
           !is.na(biologicalSampleName),
           !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
    unite(file, fileType, fileSubType, sep="_") %>% 
    mutate(file=str_replace(file, "_NA", "")) %>% 
    select(UID, biologicalSampleName, Originating_Lab_ID, Originating_Lab, pass_qc, exclude, file, id) %>%
    spread(file, id)
  
  mrna2 <- mrna %>%
    gather(file, id, 7:ncol(mrna)) %>%
    group_by(UID, biologicalSampleName, Originating_Lab_ID, Originating_Lab, pass_qc, exclude) %>%
    summarize(incomplete=any(is.na(id))) %>%
    ungroup() %>%
    left_join(mrna)
  
  mirna <- allData %>% 
    filter(dataType=='miRNA') %>%
    filter(!is.na(UID), 
           !is.na(biologicalSampleName),
           !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
    unite(file, fileType, fileSubType, sep="_") %>% 
    mutate(file=str_replace(file, "_NA", "")) %>% 
    select(UID, biologicalSampleName, Originating_Lab_ID, Originating_Lab, pass_qc, exclude, file, id) %>%
    spread(file, id)
  
  mirna2 <- mirna %>%
    gather(file, id, 7:ncol(mirna)) %>%
    group_by(UID, biologicalSampleName, Originating_Lab_ID, Originating_Lab, pass_qc, exclude) %>%
    summarize(incomplete=any(is.na(id))) %>%
    ungroup() %>%
    left_join(mirna)
  
  methylColsToUse <- c(colsToUse, "Channel", "BeadChip")
  methylColsToUseStr <- paste(methylColsToUse, collapse=",")
  
  methylationData <- synQuery(sprintf("select %s from file where benefactorId=='syn1773109' and dataType=='%s'", 
                                      methylColsToUseStr, 'methylation'), blockSize=400)$collectAll()
  colnames(methylationData) <- gsub(".*\\.", "", colnames(methylationData))
  methylationData$id <- paste('<a href="https://www.synapse.org/#!Synapse:', 
                              methylationData$id, '" target="_blank">', methylationData$id, '</a>', sep="")
  
  methylation <- methylationData %>% 
    filter(dataType=='methylation') %>%
    filter(!is.na(UID), 
           !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
    unite(file, fileType, Channel, sep="_") %>% 
    mutate(file=str_replace(file, "_NA", "")) %>% 
    select(UID, biologicalSampleName, Originating_Lab_ID, Originating_Lab, BeadChip, pass_qc, exclude, file, id) %>%
    spread(file, id)
}