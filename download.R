library(rjson)
configJson <- rjson::fromJSON(file = "http://roo.golitsyn.com/api/?method=config")
configLang <- unlist(lapply(configJson$translations, function(x){x$lang}))
configData <- unlist(lapply(configJson$translations, function(x){sub('?5f9d6704','',x$data, fixed = TRUE)}))

dataPath <- configData[configLang=='English']
dataJson <- rjson::fromJSON(file=dataPath)
dataString <- RJSONIO::toJSON(dataJson, collapse = "")
dataString_new <- sub('\": \"', '',dataString)
write(dataString, "ModifiedEN_generatedbyR")

