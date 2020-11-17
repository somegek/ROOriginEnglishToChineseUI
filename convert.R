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

endString <- ",\"696473873\":\" \"}"
rawString <- `stri_sub<-`(rawString,nchar(rawString), nchar(rawString), value = endString)

KoId <- names(jsonlite::fromJSON(rawString))

ChTable <- as.data.table(read_sheet("1zbRXgH4_XHXNLBqMakUkJ1gq6mAnSMiMunfgiWY-MIw"))
ChTable[, id := as.numeric(id)]
ChTable <- ChTable[id %in% KoId,.(id,utf16string)]

MapTable <- as.data.table(read_sheet("1IFXu-ybDMz5asDhDRFljB6ziE6WtPRzw9W9hodvnqLE"))
MapTable[, id := as.numeric(id)]
MapTable <- MapTable[!is.na(id) & !is.na(utf16string), .(id, utf16string)]

NewTable <- merge(ChTable, MapTable, by = "id", all.x = TRUE)
NewTable[!is.na(utf16string.y), utf16string.x :=utf16string.y]
NewTable[, utf16string.y:=NULL]
setnames(NewTable, "utf16string.x","utf16string")
setorder(NewTable, id)
nTotal <- nrow(NewTable)
pos <- 0
for(curId in NewTable$id){
  pos <- pos+1
  print(round(pos/nTotal,2))
  # curId <- '4265649338' # example
  location <- stri_locate_all_fixed(pattern=paste0('\"',curId,'\":\"'), rawString)[[1]]
  startPos <- unname(location[1,2]+1)
  endLocations <- stri_locate_all_fixed(pattern='\",\"', rawString)[[1]][,1]
  endPos <- unlist(endLocations[which(endLocations>startPos)[1]]-1)
  # print(substr(rawString, startPos, endPos))
  rawString <- `stri_sub<-`(rawString, startPos, endPos, value=unlist(NewTable[id==curId,utf16string]))
}

write(rawString, "ModifiedEN")

rawString <- stri_replace_all_fixed(rawString, '\",\"', '\",\n\"')
write(rawString, "ModifiedEN.txt")

git2r::commit(message='0', all = TRUE)
# git2r::config(repo, user.name = "Alice", user.email = "Alice@example.com")
# git2r::push()
endTime <- Sys.time()
print(endTime-startTime)