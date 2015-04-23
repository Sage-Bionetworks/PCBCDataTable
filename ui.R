
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

fluidPage(
  title = 'DataTables Information',
  fluidRow(
    column(6, DT::dataTableOutput('tbl'), height=500)
  )
)

