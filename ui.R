#User Interface

library(shiny)
library(rhandsontable)


###requests - make it less crunchy/squishy (roll over on tables)
##adjust y axis title based on which analysis

ui<-fluidPage(fluidRow(column(8,titlePanel('Bootstrap Calculator')),
              column(4,img(src='logo_horizontal.jpg',align='right',width='100%'))),
  sidebarLayout(
  sidebarPanel(radioButtons('anal','Select Analysis',c('Upper 95% Confidence Limit for Effluent Concentrations'='conc',
                                        'Lower 95% Confidence Limit for Removal Efficiency'='removal')),
  numericInput('reps','Replications',5000),
  actionButton('runIt','Calculate'),
  width=3),
  mainPanel(
    HTML(paste0('This app can calculate either the one-tailed upper 95% confidence interval around the',
          ' mean effluent concentration, or the one-tailed lower 95% confidence interval around the',
          ' mean pollutant removal efficiency.  To perform these calcualtions, the app randomly ',
          'resamples the original data to create 5000 datasets with the same number of values as the original data.',
          'The mean of each resampled dataset is then calculated.',  
          'The 5000 means are then sorted in ascending order.',
          'The one-tailed upper 95% confidence interval around the mean effluent concentration is the',
          ' mean with the rank of 4750 out of 5000.  The one-tailed lower 95% confidence interval around the ',
          'mean pollutant removal efficiency is the mean with the rank of 250 out of 5000.  ',
          '<br>',
          'THIS APP SHOULD ONLY BE USED WHEN THERE ARE 10 OR MORE DATA POINTS FOR EFFLUENT CONCENTRATION OR ',
          'POLLUTANT REMOVAL EFFICIENCY.')),
    HTML('<br>'),
    strong('Input Data'),
    fluidRow(column(8,rHandsontableOutput('hot')),
             column(4,plotOutput('plotOut'))
             ),
    htmlOutput("textOut"),
    width=9)
  )
  )
