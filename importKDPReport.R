library('readxl')
library('stringr')
library('lubridate')
library('plyr')
library('tidyr')
library('dplyr')
library('stringr')

importKDPReport <- function(filename, finalCurrency = 'USD') {
  period = str_match(
    read_excel(
      filename, 
      sheet='eBook Royalty Report'
    )$Title[2], 
    "Sales report for the period (\\w*) - (\\d*)"
  )
  report_date = make_date(
    as.integer(period[,3]), 
    match(substr(period[,2],0,3), month.abb)
  ) %m+% months(1) - days(1)
  getConverstionRate <- function(originalCurrency) {
    conversion_date = min(
      max(
        report_date, Sys.Date() - days(180)
      ), Sys.Date()-1
    )
    getFX(
      Currencies = paste0(originalCurrency,"/",finalCurrency), 
      from=as.character(conversion_date), 
      to=as.character(conversion_date), 
      auto.assign = FALSE
    )
  }
  
  numericColumns = c("Units Sold","Units Refunded","Net Units Sold or KENP Read",
                     "Royalty Type","List Price","Offer Price",
                     "Royalty in Original Currency")
  factorColumns = c('Author', 'Marketplace', 'Original Currency', 'Transaction Type')
  netColumns = c('Standard', 'Standard - Paperback')
  
  
  result <- read_excel(filename, sheet = 'Combined Royalty Report') %>%
    mutate(`Royalty Type` = str_replace(`Royalty Type`, "%", "")) %>%
    mutate(`Period End Date` = report_date) %>%
    rename(
      `List Price` = `Avg. List Price without tax`,
      `Offer Price` = `Avg. Offer Price without tax`,
      `Royalty in Original Currency` = `Royalty`,
      `Net Units Sold or KENP Read` = `Net Units Sold or KENP Read**`,
      `Transaction Type` = `Transaction Type*`,
      `Original Currency` = `Currency`
    ) %>%
    mutate(across(all_of(numericColumns), as.numeric)) %>%
    mutate(across(all_of(factorColumns), as.factor)) %>%
    mutate(`Royalty Type` = `Royalty Type`/100) %>%
    pivot_wider(names_from = `Transaction Type`, values_from = `Net Units Sold or KENP Read`) %>%
    rename(
      `eBook Net Units Sold` = `Standard`,
      `Paperback Net Units Sold` = `Standard - Paperback`,
    )
  
  currencies = levels(result$`Original Currency`)
  
  conversions <- tibble(
    `Original Currency` = currencies,
    `Exchange Rate` = sapply(currencies, getConverstionRate)
  )
  left_join(result, conversions, by = "Original Currency") %>%
    mutate(`Royalty in Final Currency` = `Royalty in Original Currency` * `Exchange Rate`)
}