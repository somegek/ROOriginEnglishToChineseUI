library(rjson)
library(data.table)

fileName <- 'ModifiedEN'
EN <- readChar(fileName, file.info(fileName)$size)
EN <- rjson::fromJSON(json_str = EN)

csvFiles <- list.files(pattern = '*.csv')
for(file in csvFiles){
  DT <- fread(file)
  browser()
}
