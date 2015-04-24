library(shiny)
library(DT)

shinyServer(function(input, output) {
  
  output$tbl = DT::renderDataTable({
    DT::datatable(allData, 
                  extensions = c('ColVis'),
                  options = list(pageLength = 15),
                  escape=1)
    })
})
