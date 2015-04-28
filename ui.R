
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(
  fluidPage(
    title = 'PCBC Data',
    
    mainPanel(
      tabsetPanel(
        tabPanel("All", 
                 DT::dataTableOutput('all')),
        tabPanel("mRNA",
                 DT::dataTableOutput('mrna')),
        tabPanel("miRNA",
                 DT::dataTableOutput('mirna'))
      )
    )
  )
)





