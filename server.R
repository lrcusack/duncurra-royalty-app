source('importKDPReport.R')
source('generateSummary.R')

library('shiny')

shinyServer(function(input, output, session) {
  
  updatetitlelist = reactive({
    titles = unique(kdp()[is.element(kdp()$Author,input$authorselect),'Title'])
    updateSelectInput(session,'titleselect',
                      choices=setdiff(titles,'Total'),
                      selected = input$titleselect)
  })
  
  titleSummaryTable = reactive({
    if (is.null((input$file)))
      return(NULL)
    titlesummary = generateSummary(kdp(),
                                        input$authorselect,
                                        input$titleselect,
                                        sumperiods = input$sumperiods)
    updatetitlelist()
    return(titlesummary)
    
  })
  
  authorSummaryTable = reactive({
    if (is.null((input$file)))
      return(NULL)
    authorsummary = generateSummary(kdp(),
                                          input$authorsummaryselect,
                                          sumperiods = input$sumperiods,
                                          sumtitles = TRUE)
    return(authorsummary)
  })
  
  kdp = reactive({
    inFile <- input$file
    
    if (is.null(inFile))
      return(NULL)
    
    val <<- importKDPReport(inFile$datapath)
    
    updateSelectInput(session,'authorsummaryselect',
                      choices=unique(val$Author))
    updateSelectInput(session,'authorselect', 
                      choices=unique(val$Author))
    updateSelectInput(session,'titleselect', 
                      choices=unique(val$Title))
    
    return(val)
  })
  

  
  output$contents <- renderDataTable({
    data = kdp()
  })
  
  output$summary <-  renderDataTable({
    data = authorSummaryTable()
  })
  
  output$titlesummary <- renderDataTable({
    data = titleSummaryTable()
  })
  
  output$table <- renderPrint({
    summary(cars)
  })
})