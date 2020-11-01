library(rjson)
library(data.table)
configJson <- rjson::fromJSON(file = "http://roo.golitsyn.com/api/?method=config")
configLang <- unlist(lapply(configJson$translations, function(x){x$lang}))
configData <- unlist(lapply(configJson$translations, function(x){sub('\\?.*$','',x$data)}))

dataPath <- configData[configLang=='English']
dataPath <- 'http://roo.golitsyn.com/translations/json/EN'
dataPath <- 'https://raw.githubusercontent.com/somegek/ROOriginEnglishToChineseUI/master/OriginalEN'
dataJson <- rjson::fromJSON(file=dataPath)
dataId <- names(dataJson)

# dataJson <- gsub('/','\\/',dataJson, fixed = TRUE)
names(dataJson) <- dataId
dataValue <- unlist(dataJson)
DT <- data.table(id=dataId, text=dataValue)
save(dataJson, DT, file='dataJson.rdata')
