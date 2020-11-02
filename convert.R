library(data.table)
library(googlesheets4)
library(stringi)

load(file='rawString.rdata')

MapTable <- as.data.table(read_sheet("1IFXu-ybDMz5asDhDRFljB6ziE6WtPRzw9W9hodvnqLE"))
MapTable[, id := as.character(id)]
MapTable <- MapTable[!is.na(id), .(id, utf16string)]

for(curId in MapTable$id){
  if(id=='31298961')browser()
  # curId <- '28976' # example
  location <- stri_locate_all(pattern=paste0('\"',curId,'\":\"'), rawString, fixed = TRUE)[[1]]
  startPos <- unname(location[1,2]+1)
  endLocations <- stri_locate_all(pattern=paste0('\",\"'), rawString, fixed = TRUE)[[1]][,1]
  endPos <- unlist(endLocations[which(endLocations>startPos)[1]]-1)
  print(substr(rawString, startPos, endPos))
  rawString <- `stri_sub<-`(rawString, startPos, endPos, value=unlist(MapTable[id==curId,utf16string]))
}

endString <- ",\"696473873\":\" \"}"
rawString <- `stri_sub<-`(rawString,nchar(rawString), nchar(rawString), value = endString)

write(rawString, "ModifiedEN")
