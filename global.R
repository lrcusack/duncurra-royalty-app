library('quantmod')

getCurrencies = function (){
  temp = oanda.currencies;
  topcurr = c('USD','GBP','CAD','EUR','NZD','AUD','BZD')
  symbols = rownames(temp)
  idx = is.element(symbols,topcurr)
  names = temp[,1]
  currencies = data.frame(symbols,names)
  currencies = rbind(currencies[idx,],currencies[!idx,])
  return(currencies)
}

getExchangeTable = function(kdp) {
  exchangeTable = unique(kdp[,c('Original Currency','Period End Date','Exchange Rate')])
}