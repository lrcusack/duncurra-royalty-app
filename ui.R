library('shiny')

navbarPage("Duncurra Royalty App",
           tabPanel("File Selection",
                    sidebarLayout(
                      sidebarPanel(
                        fileInput("file", "Choose KDP file saved as .csv",accept=".csv"),
                        checkboxInput('sumperiods', 'Sum over all periods in reports?', TRUE)
                      ),
                      mainPanel(
                        dataTableOutput('contents')
                      )
                    )
           ),
           tabPanel("Author Summary",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput('authorsummaryselect', 
                                    label = "Choose Author(s)", 
                                    choices = NULL,
                                    multiple = TRUE)
                      ),
                      mainPanel(
                        dataTableOutput('summary')
                      )
                    )
           ),
           tabPanel("Title Summary",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput('authorselect', 
                                    label = "Choose Author(s)", 
                                    choices = NULL,
                                    multiple = TRUE),
                        selectInput('titleselect', 
                                    label = "Choose Title(s)", 
                                    choices = NULL,
                                    multiple = TRUE)
                      ),
                      mainPanel(
                        dataTableOutput('titlesummary')
                      )
                    )
           )
)