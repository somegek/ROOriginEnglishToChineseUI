library(data.table)
library(openxlsx)

load(file='dataJson.rdata')

MapTable <- as.data.table(read.xlsx('ID2ChineseMappingTable.xlsx',sheet = 1))
MapTable[, id := as.character(id)]

# set reference column for faster indexing
setkey(MapTable, id)
setkey(DT, id)

# left join base on id
DT <- merge(DT, MapTable, all.x = TRUE, all.y = FALSE, by = 'id')
# if new text exist, replace old text
DT[!is.na(newText), text := newText]
# clean up columns
DT[, c('origText', 'newText'):=NULL]

DT <- DT[names(dataJson)]
outputList <- as.list(DT$text)
names(outputList) <- names(dataJson)

dataString <- RJSONIO::toJSON(outputList, collapse = "")
write(dataString, "ModifiedEN")
