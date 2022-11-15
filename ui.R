#User Interface

library(shiny)

fluidPage(
  sidebarLayout(
  sidebarPanel(
  textAreaInput("pasted1", "paste text here",height='200px'), 
  radioButtons('ci','Select Confidence Interval',c('95%'=.95)),
  numericInput('reps','Replications',5000),
  actionButton('runIt','Calculate')),
  mainPanel(
  textOutput("textOut"),
  plotOutput('plotOut')
)))
