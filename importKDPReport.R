importKDPReport <- function(filename,finalCurrency = 'USD'){
  
  library('plyr')
  library('quantmod')
  # read relevant KDP columns, add country of sale as a column, and combine data
  # filename = 'kdp-report-1-2016.csv'
  # finalCurrency = 'USD'
  contents = read.csv(filename);
  contents$Period = "";
  contents$Country = "";
  contents$OrigCurrency = "";
  contents$Royalty.inFinalCurrency = rep(0,nrow(contents))
  contents$FinalCurrency = finalCurrency;
  
  periodFormatStr = "%B - %Y"
  periodstr = "Sales report for the period ";
  storestartstr = "Amazon Kindle "
  countrystartidx = nchar(storestartstr)+1;
  countrystopidxbase = nchar(" Store");
  
  
  
  
  periodidx = substring(contents$Title,1,nchar(periodstr)) == periodstr;
  
  storeStartRows = which(periodidx) - 1
  
  for(i in 1:length(storeStartRows)){
    
    storeStartIdx = storeStartRows[[i]]
    
    if (i < length(storeStartRows)){
      storeStopIdx = storeStartRows[[i+1]] - 1
    }else{
      storeStopIdx = nrow(contents)
    }
    
    period = substring(contents[storeStartIdx+1,]$Title,nchar(periodstr)+1)
    
    if(substring(period,13,14)=="to"){
      d = as.Date(substring(period,1,11),format="%d-%b-%Y")
      period = format(d,format=periodFormatStr)
    }
    
    OrigCurrency = sub("\\)","",
                       sub("\\(","",
                           sub(" ","",contents$Royalty[[storeStartIdx]])))
    
    countryTempstr = as.character(contents$Title[[storeStartIdx+2]])
    countrystopidx = nchar(countryTempstr) - countrystopidxbase
    country = substring(countryTempstr,countrystartidx, countrystopidx)
    
    contents[storeStartIdx:storeStopIdx,]$Period = period
    contents[storeStartIdx:storeStopIdx,]$OrigCurrency = OrigCurrency
    contents[storeStartIdx:storeStopIdx,]$Country = country
  }
  
  
  deleteidx = (contents$Title == "Title" | contents$Author == "")
  
  contents = contents[!deleteidx,];
  
  contents = rename(contents,c(
    "Royalty.Type.2." = "RoyaltyType",
    "Transaction.Type..3." = "TransactionType",
    "Units.Sold" = "UnitsSold",
    "Units.Refunded" = "UnitsRefunded",
    "Avg..List.Price.without.tax" = "ListPrice",
    "Avg..Offer.Price.without.tax" = "OfferPrice",
    "Royalty"="Royalty.inOrigCurrency"
    ))
  
  contents = droplevels(contents)
  
  levels(contents$RoyaltyType) = sub("%","",levels(contents$RoyaltyType));
  
  numericColumns = c("UnitsSold","UnitsRefunded","Net.Units.Sold.or.KENP.Read...1.",
                     "RoyaltyType","ListPrice","OfferPrice","Royalty.inOrigCurrency")
  for (col in numericColumns){
    contents[,col] = as.numeric(levels(contents[,col]))[contents[,col]]
  }
  contents$RoyaltyType = contents$RoyaltyType/100;
  
  contents$NetUnitsSold = contents$Net.Units.Sold.or.KENP.Read...1.
  contents[is.na(contents$UnitsSold),]$NetUnitsSold = NA
  contents$KENPRead = contents$Net.Units.Sold.or.KENP.Read...1.
  contents[!is.na(contents$UnitsSold),]$KENPRead = NA
  
  dates = as.character(as.Date(with(contents,paste0("15 ",Period)),
                               format=paste("%d ", periodFormatStr)))
  uniquedates = unique(dates)
  
  exchangeString = with(contents,paste0(OrigCurrency,"/",FinalCurrency))
  exchanges = unique(exchangeString)
  
  conversion = c();
  date = c();
  rate = c();
  
  for(ex in exchanges){
    for(d in uniquedates){
      conversion = c(conversion,ex)
      date = c(date,d)
      rate = c(rate,getFX(ex,from=d,to=d,auto.assign = FALSE)[[1]])
    }
  }
  exchangeTable = data.frame(conversion,date,rate)
  for(i in 1:nrow(exchangeTable)){
    matchidx = (dates==exchangeTable$date[[i]] 
                & exchangeString==exchangeTable$conversion[[i]])
    contents[matchidx,]$Royalty.inFinalCurrency = 
      exchangeTable$rate[[i]] * contents[matchidx,]$Royalty.inOrigCurrency
  }
  
  factorColumns = c("Period","Country","OrigCurrency","FinalCurrency");
  for (col in factorColumns){
    contents[,col] = as.factor(contents[,col])
  }
  
  drops = c("Average.Delivery.Cost","Average.File.Size",
            "ASIN","Net.Units.Sold.or.KENP.Read...1.");
  contents = contents[,!(names(contents) %in% drops)]
  
  colorder = c("Title",
               "Author",
               "Period",
               "Country",
               "Royalty.inOrigCurrency",
               "OrigCurrency",
               "Royalty.inFinalCurrency",
               "FinalCurrency",
               "RoyaltyType",
               "TransactionType",
               "ListPrice",
               "OfferPrice",
               "UnitsSold",
               "UnitsRefunded",
               "NetUnitsSold",
               "KENPRead")
  contents = contents[,colorder]
  return(contents)
}