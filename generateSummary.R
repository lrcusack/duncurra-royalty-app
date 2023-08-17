generateSummary <- function(kdp,Authors = NULL,Titles = NULL,Periods = NULL,
                            sumperiods = FALSE,
                            sumtitles = FALSE,
                            sumauthors = FALSE,
                            currency = 'USD'){
  if (is.null(Authors)){
    Authors = unique(kdp$Author)
  }
  if (is.null(Titles)){
    Titles = unique(kdp$Title)
    print('Titles')
    print(Titles)
  }
  if(is.null(Periods)){
    Periods = unique(kdp$`Period End Date`)
  }
  ntitles = length(Titles)
  nauthors = length(Authors)
  nperiods = length(Periods)
  Royalty = c()
  eBookRoyalty = c()
  eBooksSold = c()
  PaperbackRoyalty = c()
  PaperbacksSold = c()
  KENPRoyalty = c()
  PagesRead = c()
  Title = c()
  Author = c()
  Period = c()
  
  
  for (i in 1:ntitles){
    titleidx = kdp$Title==Titles[[i]]
    for(j in 1:nauthors){
      authoridx = kdp$Author==Authors[[j]]
      
      for (k in 1:nperiods){
        periodidx = kdp$`Period End Date` == Periods[[k]]
        idx = rep(TRUE,nrow(kdp))
        if (!sumauthors){
          idx = idx & authoridx
        }
        if (!sumtitles){
          idx = idx & titleidx
        }
        if (!sumperiods){
          idx = idx & periodidx
        }
        if (any(idx)){
          Royalty = c(Royalty,sum(kdp[idx,]$`Royalty in Final Currency`))
          eBooksSold = c(eBooksSold,sum(kdp[idx,]$`eBook Net Units Sold`,na.rm = TRUE))
          PaperbacksSold = c(PaperbacksSold,sum(kdp[idx,]$`Paperback Net Units Sold`,na.rm = TRUE))
          PagesRead = c(PagesRead,sum(kdp[idx,]$`Kindle Edition Normalized Page (KENP) Read`,na.rm = TRUE))
          KENPRoyalty = c(KENPRoyalty,sum(kdp[(idx & !is.na(kdp$`Kindle Edition Normalized Page (KENP) Read`)),]$`Royalty in Final Currency`))
          eBookRoyalty = c(eBookRoyalty,sum(kdp[(idx & !is.na(kdp$`eBook Net Units Sold`)),]$`Royalty in Final Currency`))
          PaperbackRoyalty = c(PaperbackRoyalty,sum(kdp[(idx & !is.na(kdp$`Paperback Net Units Sold`)),]$`Royalty in Final Currency`))
          Title = c(Title,as.character(Titles[[i]]));
          Author = c(Author,as.character(Authors[[j]]))
          Period = c(Period,as.character(Periods[[k]]))
        }
        
      }
    }
  }
  as = data.frame(Royalty,eBookRoyalty,eBooksSold,PaperbackRoyalty,PaperbacksSold,KENPRoyalty,PagesRead)
  
  if(!sumperiods){
    as$Period = Period
  }
  if(!sumtitles){
    as$Title = Title
  }
  if (!sumauthors){
    as$Author = Author
  }
  
  as = unique(as)
  
  
  totalrow = as[1,]
  
  for (col in names(as)){
    if(is.numeric(as[,col])){
      totalrow[1,col] = sum(as[,col])
    } else {
      totalrow[1,col] = 'Total'
    }
  }
  as[nrow(as)+1,] = totalrow[1,]
  
  
  colorder = intersect(c('Title','Author','Royalty',
                         'eBookRoyalty', 'eBooksSold',
                         'PaperbackRoyalty', 'PaperbacksSold',
                         'KENPRoyalty','PagesRead',
                         'Period'),
                       names(as))
  as = as[,colorder]
  
  
  financeCols = c('Royalty','eBookRoyalty', 'PaperbackRoyalty', 'KENPRoyalty')
  
  currSymbol = switch (currency,
    'USD' = '$',
    'NZD' = '$',
    'AUD' = '$',
    'CAD' = '$',
    'AUD' = '$',
    'GBP' = '\u00A3',
    'EUR' = '\u20AC',
    currency
  )
  for (col in financeCols){
    as[,col] = paste(currSymbol,format(round(as[,col],digits=2),nsmall=2),sep="")
  }
  
  
  return(as)
}