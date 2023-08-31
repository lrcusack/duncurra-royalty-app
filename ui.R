library('shiny')
library('quantmod')


navbarPage("Duncurra Royalty App",
           tabPanel("Home/Instructions",
                    titlePanel('Welcome to Duncurra Royalty App'),
                    p('This is a web based app that authors who publish through KDP can use to view sales and income.'),
                    p('The app reads XLSX (Microsoft Excel) files as downloaded from KDP'),
                    
                    h1('How to use:'),
                      h2('File Selection'),
                        p('Click the File Selection tab and select the XLSX file to upload. You can select single or multiple file(s) at a time. There is an option to \"sum over all periods in reports\". If you upload multiple files, and you want them all summed in the summary view, leave this box checked. You may uncheck it at any time to see summaries broken down by period (month).'),
                      h2('Currency conversion'),
                        p('There is also a "desired currency" option on the file selection tab. The default is USD, but if Amazon pays you in another currency, you can select that here. After you select a file, the first thing you will see is the currency exchange rates. If you select reports from multiple months, you will see exchange rates for them all.'),
                        p('To do currency conversions, the app will pull the currency conversion rate, from the last day of the month of when the royalties are paid, unless that date is in the future, in which case it will pull the conversion rate for yesterday. Sales periods more than 180 days in the past will use the conversion rate from 180 days ago.'),
                        p('For example: Royalties from August sales are paid in October. When you use the app to look at the royalty report on September 23, it will calculate the currency conversion based on September 22 values. Every date on or after November 1, it will be reported on October 31 exchange rates'),
                        p('Please note that this may not be the precise exchange rate used by the various Amazon outlets, but (aside from any extreme fluctuations) it should be close.'),
                    
                    
                      h2('Summaries'),
                        h3('Summary by Author'),
                          p('If you select the tab \"Author Summary\" you can look at a high level summary for each author in your KDP report'),
                          p('Using the input box on the left side of the window, you can select specific authors to show only their summaries. Authors can be removed from this selection list using backspace'),
                          p('The bottom row of this window always shows the totals (sums) of whatever data you have visible'),
                        h3("Summary by Title"),
                          p('If you select \"Title summary\" you can look at summary data for each title in your KDP report.'),
                          p('Using the input boxes on the left side of the window, you can select specific authors to show only their titles. Additionally, specific titles can be selected to be viewed. Only titles written by authors in the author selection box will appear in the title selection box. Authors/titles can be removed from this selection list using backspace'),
                          p('The bottom row of this window always shows the totals (sums) of whatever data you have visible'),
                    
                      h2('Raw Data'),
                        p('So the summaries don\'t cut it for you. You want to get your hands dirty with your data and see how the sausage is made. The \"Raw Data\" tab will show you the exact data pulled from the report(s) plus the specific exchange rates used-- Title, Author, Period, Country, Royalty in original currency (amount), original currency (type, e.g. GBP), exchange(e.g. GBP/USD), exchange rate, exchange date, and royalty in final currency (amount), final currency (type), royalty type, payout plan, list price, offer price, units sold, units refunded, net units sold, and KENEP (Kindle Unlimited Pages Read) read.'),
                        p('NOTE: On the raw data tab, you will see titles listed more than once, because that is the way Amazon reports them. For example - Charles Dickens might see Oliver Twist three times, once at 35%, once at 70% and once KU funds. But when you look at the title summary you will see the total for that title regardless of the type of royalty.'),
                        
                      h2("Finally..."),
                        p('Once you have a display of data you want to save, print it to PDF and save it, copy and paste the table into Word or Excel, or just bask in the glow of this awesome app'),
                    
                    h1('Privacy'),
                      p('For your privacy, your data does not stay in the app. So once you see what you want, you need to save it. Otherwise, to get the same data again, you will have to upload the reports again.'),
                    
                    h3('Feel free to share this with other authors who may wish to use it.')
           ),
           tabPanel("File Selection",
                    sidebarLayout(
                      sidebarPanel(
                        fileInput("file", 
                                  "Choose KDP file saved as .xlsx",
                                  accept=".xlsx",
                                  multiple = TRUE),
                        checkboxInput('sumperiods', 'Sum over all periods in reports?', TRUE),
                        selectInput('finalcurrency','Select Desired Currency',getCurrencies()$names)
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
           ),
           tabPanel("Raw Data",
                    dataTableOutput('rawdata')),
           tabPanel('Software License',
                    h1('R'),
                    p('This software was created using the open source software \"R\", along with
                      several R packages including quantmod, plyr, and shiny'),
                    h1('Duncurra Royalty App'),
                    p('MIT License'),
                    p('Copyright (c) 2016 Liam Cusack'),
                    p('Permission is hereby granted, free of charge, to any person obtaining a copy
                      of this software and associated documentation files (the "Software"), to deal
                      in the Software without restriction, including without limitation the rights
                      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                      copies of the Software, and to permit persons to whom the Software is
                      furnished to do so, subject to the following conditions:'),
                    p('The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.'),
                    p('THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.'),
                    h1('Source Code'),
                    p('Source code is available at ', a('https://github.com/lrcusack/duncurra-royalty-app'))
           )
)