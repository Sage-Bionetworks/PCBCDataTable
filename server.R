library(shiny)
library(DT)

shinyServer(function(input, output) {
  
  output$mrna <- DT::renderDataTable({
    DT::datatable(mrna, 
                  extensions = c('ColVis'),
                  options = list(pageLength = 15),
                  escape=1)
    })

  output$mirna <- DT::renderDataTable({
    DT::datatable(mirna, 
                  extensions = c('ColVis'),
                  options = list(pageLength = 15),
                  escape=1)
  })
  
  output$methylation <- DT::renderDataTable({
    DT::datatable(methylation, 
                  extensions = c('ColVis'),
                  options = list(pageLength = 15),
                  escape=1)
  })
  
  output$all <- DT::renderDataTable({
    DT::datatable(allData, 
                  extensions = c('ColVis'),
                  options = list(pageLength = 15),
                  escape=1)
  })

})
