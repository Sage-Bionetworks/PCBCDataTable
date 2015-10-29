library(shiny)
library(DT)

shinyServer(function(input, output) {
  
  output$mrna <- DT::renderDataTable({
    DT::datatable(mrna2,
                  filter = list(position = 'top', clear = FALSE),
                  options = list(pageLength = 15,
                                 dom='frtip',
                                 search = list(regex = TRUE)),
                  escape=1)
    })

  output$mirna <- DT::renderDataTable({
    DT::datatable(mirna2, 
                  filter = list(position = 'top', clear = FALSE),
                  options = list(pageLength = 15,
                                 dom='frtip',
                                 search = list(regex = TRUE)),
                  escape=1)
  })
  
  output$methylation <- DT::renderDataTable({
    DT::datatable(methylation,
                  filter = list(position = 'top', clear = FALSE),
                  options = list(pageLength = 15,
                                 dom='frtip',
                                 search = list(regex = TRUE)),
                  escape=1)
  })
  
  output$all <- DT::renderDataTable({
    DT::datatable(allData, 
                  extensions = c('ColReorder', 'ColVis'),
                  filter = list(position = 'top', clear = FALSE),
                  options = list(pageLength = 15,
                                 dom='C<"clear">Rfrtip',
                                 search = list(regex = TRUE)),
                  escape=1)
  })

})
