source('importKDPReport.R')
source('generateSummary.R')

require('curl')
library('shiny')


shinyServer(function(input, output, session) {
  
  finalcurrency = reactive({
    fcname = input$finalcurrency
    currencies = getCurrencies()
    return(as.character(currencies[fcname==currencies$names,'symbols']))
  })
  
  updatetitlelist = reactive({
    if (is.null(input$authorselect))
      titles = unique(kdp()[,'Title'])
    else
      titles = unique(kdp()[is.element(kdp()$Author,input$authorselect),'Title'])
    updateSelectInput(session,'titleselect',
                      choices=setdiff(array(titles),'Total'),
                      selected = input$titleselect)
  })
  
  titleSummaryTable = reactive({
    if (is.null((input$file)))
      return(NULL)
    titlesummary = generateSummary(kdp(),
                                   input$authorselect,
                                   input$titleselect,
                                   sumperiods = input$sumperiods,
                                   currency = finalcurrency())
    updatetitlelist()
    return(titlesummary)
    
  })
  
  authorSummaryTable = reactive({
    if (is.null((input$file)))
      return(NULL)
    authorsummary = generateSummary(kdp(),
                                    input$authorsummaryselect,
                                    sumperiods = input$sumperiods,
                                    sumtitles = TRUE,
                                    currency = finalcurrency())
    return(authorsummary)
  })
  
  kdp = reactive({
    inFile <- input$file
    
    if (is.null(inFile))
      return(NULL)
    
    val = data.frame()
    ex = data.frame()
    for (path in inFile$datapath){
      val = rbind.fill(val,importKDPReport(path,finalCurrency = finalcurrency()))
    }
    
    updateSelectInput(session,'authorsummaryselect',
                      choices=unique(val$Author))
    updateSelectInput(session,'authorselect', 
                      choices=unique(val$Author))
    updateSelectInput(session,'titleselect', 
                      choices=unique(val$Title))
    
    return(val)
  })
  
  
  
  output$contents <- renderDataTable({
    data = getExchangeTable(kdp())
  })
  
  output$summary <-  renderDataTable({
    data = authorSummaryTable()
  })
  
  output$titlesummary <- renderDataTable({
    data = titleSummaryTable()
  })
  
  output$rawdata <- renderDataTable({
    data = kdp()
  })
})