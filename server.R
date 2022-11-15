#server - the workhorse

library(shiny)
library(dplyr)
library(boot)
library(ggplot2)

boot.mean<-function(x,i) mean(x[i])



server<-function(input,output){
#   df<-reactive({
#     read.table(text='5
# 5
# 5
# 7
# 5
# 10
# 5
# 4
# 8.04
# 5
# 5
# 14
# 5',col.names = c('values')) %>%
#       mutate(values=as.numeric(values))
#   })
  df<-eventReactive(input$runIt,{
  #  df<-as.data.frame(paste(input$pasted1, collapse = "\n"))
    if(input$pasted1!=''){
    read.table(text=input$pasted1,col.names = c('values')) %>%
        mutate(values=as.numeric(values))
    }
})


  bootOut<-reactive({
    if(nrow(df())>1){
     df() %>%
        rsample::bootstraps(times=5000) %>%
        pull(splits) %>%
        purrr::map_dbl(.,function(x){ dat <-rsample::analysis(x)
        mean(dat$values)
        }) %>%
        quantile(.95)
    }
  })
  
  output$plotOut<-renderPlot({
    if(nrow(df())>1){
    ggplot()+
      geom_jitter(aes(x='',y=df()$values),height=0)+
      geom_hline(yintercept=bootOut(),col='black',lwd=2)+
     # geom_hline(yintercept=input$threshold,col='red',lwd=2)+
      theme_bw()+
      ylab('Values')+
      xlab('')
    } else ggplot()
})
  output$textOut<-renderText({
    paste(input$ci,'% UCL:',bootOut())
    })
}
