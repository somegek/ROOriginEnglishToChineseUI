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

rawString <- substr(rawString, 2, nchar(rawString)-1)

stringVec <- strsplit(rawString,'\",\"',fixed = TRUE)[[1]]
stringList <- lapply(stringVec, function(x){
  x <- strsplit(x, '\":\"', fixed = TRUE)[[1]]
  return(x)
})
stringList[[6]] <- c('12289', ',')
stringList[[7]] <- c('19968', 'Monday')
'4279364896'
browser()
stringId <- unlist(lapply(stringList, function(x){
  return(x[[1]])
}))
options(gargle_oauth_email = TRUE)
ChTable <- as.data.table(read_sheet("1zbRXgH4_XHXNLBqMakUkJ1gq6mAnSMiMunfgiWY-MIw"))
ChTable[, id := as.numeric(id)]
ChTable <- ChTable[id %in% stringId,.(id,utf16string)]

MapTable <- as.data.table(read_sheet("1IFXu-ybDMz5asDhDRFljB6ziE6WtPRzw9W9hodvnqLE"))
MapTable[, id := as.numeric(id)]
MapTable <- MapTable[!is.na(id) & !is.na(utf16string), .(id, utf16string)]

NewTable <- merge(ChTable, MapTable, by = "id", all.x = TRUE)
NewTable[!is.na(utf16string.y), utf16string.x :=utf16string.y]
NewTable[, utf16string.y:=NULL]
setnames(NewTable, "utf16string.x","utf16string")
setorder(NewTable, id)
NewList <- as.list(transpose(NewTable))

stringList <- stringList[which(!stringId %in% NewTable$id)]




stringList <- c(stringList,NewList)

stringVec <- lapply(stringList, function(x){
  return(paste0(x[1], '\":\"', x[2]))
})

rawFinal <- paste0(stringVec, collapse = '\",\"')
rawFinal <- paste0("{", rawFinal, "\"}")

rawFinal <- stri_replace_all_fixed(rawFinal, '\n','\\n')

write(rawFinal, "ModifiedEN")

rawString <- stri_replace_all_fixed(rawString, '\",\"', '\",\n\"')
write(rawString, "ModifiedEN.txt")

git2r::commit(message='0', all = TRUE)
# git2r::config(repo, user.name = "Alice", user.email = "Alice@example.com")
# git2r::push()
endTime <- Sys.time()
print(endTime-startTime)