library(rjson)
library(data.table)
library(readr)
configJson <- rjson::fromJSON(file = "http://roo.golitsyn.com/api/?method=config")
configLang <- unlist(lapply(configJson$translations, function(x){x$lang}))
configData <- unlist(lapply(configJson$translations, function(x){sub('\\?.*$','',x$data)}))

dataPath <- configData[configLang=='English']
# dataPath <- 'http://roo.golitsyn.com/translations/json/EN'
# dataPath <- 'https://raw.githubusercontent.com/somegek/ROOriginEnglishToChineseUI/master/OriginalEN'

rawString <- readr::read_file(dataPath)

save(rawString, file='rawString.rdata')
write(rawString, "rawEN")
