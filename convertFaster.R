if(Sys.info()[['user']]=='arwin'){
  source('C:/Users/arwin/Desktop/RO/ROOriginEnglishToChineseUI/changeLibPath.R', echo=FALSE)
}

library(data.table)
library(googlesheets4)
library(stringi)
library(progress)
library(git2r)
repo <- git2r::init()
git2r::pull()

startTime <- Sys.time()
load(file='rawString.rdata')

endString <- ",\"696473873\":\" \"}"
rawString <- `stri_sub<-`(rawString,nchar(rawString), nchar(rawString), value = endString)
json <- jsonlite::fromJSON(rawString)
KoId <- names(json)
json <- unlist(json)
DT <- data.table(KoId=as.numeric(KoId), json)
rm(json)

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
rm(ChTable,MapTable)

DT <- merge(DT,NewTable, by.x = 'KoId', by.y = 'id',all.x = TRUE, sort = TRUE)
DT[!is.na(utf16string), json:=utf16string]
DT[,utf16string:=NULL]
DT[KoId=='2802078031', json:="Rescue Debirucci with Guild One! \\\ \\u0669( \\u141B )\\u0648 \\/ Please check the adventurer's mail!"]
DT <- DT[KoId!='0']
namedList <- as.list(DT$json)
names(namedList) <- DT$KoId

json <- jsonlite::toJSON(namedList,auto_unbox = TRUE)
json <- gsub("<U\\+(....)>", "\\\\u\\1", json)
json <- stri_replace_all_fixed(json, '\n','\\n')
json <- stri_replace_all_fixed(json, '\\\\u','\\u')
json <- stri_replace_all_fixed(json, "\\\\/","\\/")

Encoding(json) <- "bytes"
writeLines(json, "ModifiedEN")

rawString <- stri_replace_all_fixed(rawString, '\",\"', '\",\n\"')
write(rawString, "ModifiedEN.txt")

git2r::commit(message='0', all = TRUE)
# git2r::config(repo, user.name = "Alice", user.email = "Alice@example.com")
# git2r::push()
endTime <- Sys.time()
print(endTime-startTime)