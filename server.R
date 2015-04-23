library(shiny)
library(DT)

shinyServer(function(input, output) {
  
  output$tbl = DT::renderDataTable({
    DT::datatable(allData, 
                  options = list(lengthChange = FALSE, 
                                 pageLength = 15),
                  escape = 1)
    })
})
