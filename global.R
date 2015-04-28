library(dplyr)
library(tidyr)

library(synapseClient)

synapseLogin()

colsToUse <- c('id', 'dataType', 'fileType', 'fileSubType', 'UID', 'biologicalSampleName', 
               'C4_Cell_Line_ID', 'Originating_Lab_ID', 'Originating_Lab', 'Cell_Line_Type',
               'Cell_Type_of_Origin', 'Tissue_of_Origin', 'Reprogramming_Vector_Type',
               'Reprogramming_Gene_Combination')

colsToUseStr <- paste(colsToUse, collapse=",")
rnaData <- synQuery(sprintf("select %s from file where projectId=='syn1773109' and dataType=='%s'", colsToUseStr, 'mRNA'), blockSize=400)$collectAll()
mirnaData <- synQuery(sprintf("select %s from file where projectId=='syn1773109' and dataType=='%s'", colsToUseStr, 'miRNA'), blockSize=400)$collectAll()
methylationData <- synQuery(sprintf("select %s from file where projectId=='syn1773109' and dataType=='%s'", colsToUseStr, 'methylation'), blockSize=400)$collectAll()

allData <- rbind(rnaData, mirnaData, methylationData)
colnames(allData) <- gsub(".*\\.", "", colnames(allData))
allData <- allData[, colsToUse]
allData$id <- paste('<a href="https://www.synapse.org/#!Synapse:', allData$id, '">', allData$id, '</a>', sep="")

mrna <- allData %>% 
  filter(dataType=='mRNA') %>%
  filter(!is.na(UID), 
         !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
  unite(file, fileType, fileSubType, sep="_") %>% 
  mutate(file=str_replace(file, "_NA", "")) %>% 
  select(UID, biologicalSampleName, file, id) %>%
  spread(file, id)

mirna <- allData %>% 
  filter(dataType=='miRNA') %>%
  filter(!is.na(UID), 
         !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
  unite(file, fileType, fileSubType, sep="_") %>% 
  mutate(file=str_replace(file, "_NA", "")) %>% 
  select(UID, biologicalSampleName, file, id) %>%
  spread(file, id)

biosample <- allData %>%
  filter(fileType %in% c("fastq", "idat")) %>% 
  count(biologicalSampleName, dataType) %>%
  select(biologicalSampleName, dataType, n) %>%
  spread(dataType, n)

cellline <- allData %>%
  filter(fileType %in% c("fastq", "idat"), !is.na(C4_Cell_Line_ID)) %>% 
  count(C4_Cell_Line_ID, dataType) %>%
  select(C4_Cell_Line_ID, dataType, n) %>%
  spread(dataType, n)

# methylation <- allData %>% 
#   filter(dataType=='methylation') %>%
#   filter(!is.na(UID), 
#          !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
#   unite(file, fileType, fileSubType, sep="_") %>% 
#   mutate(file=str_replace(file, "_NA", "")) %>% 
#   select(UID, biologicalSampleName, file, id) %>%
#   spread(file, id)
