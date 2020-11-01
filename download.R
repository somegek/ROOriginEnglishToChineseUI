library(rjson)
library(data.table)
configJson <- rjson::fromJSON(file = "http://roo.golitsyn.com/api/?method=config")
configLang <- unlist(lapply(configJson$translations, function(x){x$lang}))
configData <- unlist(lapply(configJson$translations, function(x){sub('\\?.*$','',x$data)}))

dataPath <- configData[configLang=='English']
dataPath <- 'http://roo.golitsyn.com/translations/json/ZH'
dataJson <- rjson::fromJSON(file=dataPath)
dataId <- names(dataJson)
dataValue <- unlist(dataJson)
DT <- data.table(id=dataId, text=dataValue)
save(dataJson, DT, file='dataJson.rdata')
