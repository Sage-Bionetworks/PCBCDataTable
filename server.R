library(shiny)
library(DT)

shinyServer(function(input, output) {
  
  output$mrna <- DT::renderDataTable({
    DT::datatable(mrna, 
                  options = list(pageLength = 15,
                                 dom='frtip'),
                  escape=1)
    })

  output$mirna <- DT::renderDataTable({
    DT::datatable(mirna, 
                  options = list(pageLength = 15,
                                 dom='frtip'),
                  escape=1)
  })
  
  output$methylation <- DT::renderDataTable({
    DT::datatable(methylation,
                  options = list(pageLength = 15,
                                 dom='frtip'),
                  escape=1)
  })
  
  output$all <- DT::renderDataTable({
    DT::datatable(allData, 
                  extensions = c('ColReorder', 'ColVis'),
                  options = list(pageLength = 15,
                                 dom='C<"clear">Rfrtip'),
                  escape=1)
  })

})
