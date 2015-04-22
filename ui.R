
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput('tbl')
    ),
  
  server = function(input, output) {
    output$tbl = DT::renderDataTable({
      DT::datatable(allData, 
                    options = list(lengthChange = FALSE, pageLength = 10),
                    escape = 1
                    )
    })
  },
  
  
)
