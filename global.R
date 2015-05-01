library(dplyr)
library(tidyr)
library(stringr)

library(synapseClient)

synapseLogin()

colsToUse <- c('id', 'dataType', 'fileType', 'fileSubType', 'UID', 'biologicalSampleName', 
               'C4_Cell_Line_ID', 'Originating_Lab_ID', 'Originating_Lab', 'Cell_Line_Type',
               'Cell_Type_of_Origin', 'Tissue_of_Origin', 'Reprogramming_Vector_Type',
               'Reprogramming_Gene_Combination', 'pass_qc', 'exclude')

colsToUseStr <- paste(colsToUse, collapse=",")
rnaData <- synQuery(sprintf("select %s from file where benefactorId=='syn1773109' and dataType=='%s'", colsToUseStr, 'mRNA'), blockSize=400)$collectAll()
mirnaData <- synQuery(sprintf("select %s from file where benefactorId=='syn1773109' and dataType=='%s'", colsToUseStr, 'miRNA'), blockSize=400)$collectAll()
methylationData <- synQuery(sprintf("select %s from file where benefactorId=='syn1773109' and dataType=='%s'", colsToUseStr, 'methylation'), blockSize=400)$collectAll()

allData <- rbind(rnaData, mirnaData, methylationData)
colnames(allData) <- gsub(".*\\.", "", colnames(allData))
allData <- allData[, colsToUse]
allData$id <- paste('<a href="https://www.synapse.org/#!Synapse:', allData$id, '" target="_blank">', allData$id, '</a>', sep="")

mrna <- allData %>% 
  filter(dataType=='mRNA') %>%
  filter(!is.na(UID),
         !is.na(biologicalSampleName),
         !(fileType %in% c('matrix', 'genomicMatrix'))) %>% 
  unite(file, fileType, fileSubType, sep="_") %>% 
  mutate(file=str_replace(file, "_NA", "")) %>% 
  select(UID, biologicalSampleName, pass_qc, exclude, file, id) %>%
  spread(file, id)

mrna2 <- mrna %>%
  gather(file, id, 5:ncol(mrna)) %>%
  group_by(UID, biologicalSampleName, pass_qc, exclude) %>%
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
  select(UID, biologicalSampleName, pass_qc, exclude, file, id) %>%
  spread(file, id)

mirna2 <- mirna %>%
  gather(file, id, 5:7) %>%
  group_by(UID, biologicalSampleName, pass_qc, exclude) %>%
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
  select(UID, biologicalSampleName, BeadChip, pass_qc, exclude, file, id) %>%
  spread(file, id)
