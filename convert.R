if(Sys.info()[['user']]=='arwin'){
  source('C:/Users/arwin/Desktop/RO/ROOriginEnglishToChineseUI/changeLibPath.R', echo=FALSE)
}

library(data.table)
library(googlesheets4)
library(stringi)

library(git2r)
repo <- git2r::init()
git2r::pull()

startTime <- Sys.time()
load(file='rawString.rdata')

KoId <- names(jsonlite::fromJSON(rawString))

ChTable <- as.data.table(read_sheet("1zbRXgH4_XHXNLBqMakUkJ1gq6mAnSMiMunfgiWY-MIw"))
ChTable[, id := as.character(id)]
ChTable <- ChTable[id %in% KoId,.(id,utf16string)]

MapTable <- as.data.table(read_sheet("1IFXu-ybDMz5asDhDRFljB6ziE6WtPRzw9W9hodvnqLE"))
MapTable[, id := as.character(id)]
MapTable <- MapTable[!is.na(id) & !is.na(utf16string), .(id, utf16string)]

MapTable <- merge(ChTable, MapTable, by = "id", all.x = TRUE)
MapTable[!is.na(utf16string.y), utf16string.x :=utf16string.y]
MapTable[, utf16string.y:=NULL]
setnames(MapTable, "utf16string.x","utf16string")

for(curId in MapTable$id){
  # curId <- '28976' # example
  location <- stri_locate_all_fixed(pattern=paste0('\"',curId,'\":\"'), rawString)[[1]]
  startPos <- unname(location[1,2]+1)
  endLocations <- stri_locate_all_fixed(pattern='\",\"', rawString)[[1]][,1]
  endPos <- unlist(endLocations[which(endLocations>startPos)[1]]-1)
  print(substr(rawString, startPos, endPos))
  rawString <- `stri_sub<-`(rawString, startPos, endPos, value=unlist(MapTable[id==curId,utf16string]))
}

endString <- ",\"696473873\":\" \"}"
rawString <- `stri_sub<-`(rawString,nchar(rawString), nchar(rawString), value = endString)

write(rawString, "ModifiedEN")

rawString <- stri_replace_all_fixed(rawString, '\",\"', '\",\n\"')
write(rawString, "ModifiedEN.txt")

git2r::commit(message='0', all = TRUE)
# git2r::config(repo, user.name = "Alice", user.email = "Alice@example.com")
# git2r::push()
endTime <- Sys.time()
print(startTime-endTime)