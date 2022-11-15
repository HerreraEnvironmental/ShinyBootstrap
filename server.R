#server - the workhorse

library(shiny)
library(dplyr)
library(boot)
library(ggplot2)
library(rhandsontable)

sigfigs <- function(x){
  orig_scipen <- getOption("scipen")
  options(scipen = 999)
  on.exit(options(scipen = orig_scipen))
  
  x <- as.character(x)
  x <- sub("\\.", "", x)
  x <- gsub("(^0+|0+$)", "", x)
  nchar(x)
}

initial_table<-read.table(
text='"Effluent Concentration"	"Removal Efficiency (%)"
5	72%
5	83%
5	92%
7	76%
5	63%
10	71%
5	51%
4	58%
8.04	64%
5	76%
5	76%
14	60%
5	73%
NA	42%',header=T) %>%
  rename(`Effluent Concentration`=1,`Removal Efficiency (%)`=2)

server<-function(input,output){

df <- reactive({
      hot <- input$hot
      if (!is.null(hot)) hot_to_r(hot)
    })

output$hot <- renderRHandsontable({
  rhandsontable(initial_table)
})

sigfig_num<-reactive({
  ifelse(input$anal=='conc',
         max(sigfigs(df()[!is.na(df()[,1]),1]),na.rm=T),
         max(sigfigs(df()[!is.na(df()[,2]),2]),na.rm=T))
})

  bootOut<-eventReactive(input$runIt,{
    if(nrow(df())>1){
     df()  %>%
        select(ifelse(input$anal=='conc',1,2)) %>%
        rename(obs=1) %>%
        filter(!is.na(obs)) %>%
        mutate(obs=as.numeric(gsub('%','',obs))) %>%
        rsample::bootstraps(times=5000) %>%
        pull(splits) %>%
        purrr::map_dbl(.,function(x){ dat <-rsample::analysis(x)
        mean(dat$obs,na.rm=T)
        }) %>%
        quantile(ifelse(input$anal=='conc',.95,0.05)) %>%
        signif(.,sigfig_num())
    }
  })
  

  p<-eventReactive(input$runIt,{
    if(nrow(df())>1){
      df()%>%
        rename(values=1,pctreduction=2) %>%
        rowwise() %>%
        mutate(pctreduction=as.numeric(gsub('%','',pctreduction)),
               plotValue=ifelse(input$anal=='conc',values,pctreduction)) %>%
        ggplot()+
        geom_jitter(aes(x='',y=plotValue),height=0)+
        geom_hline(yintercept=bootOut(),col='black',lwd=2)+
        # geom_hline(yintercept=input$threshold,col='red',lwd=2)+
        theme_bw()+
        ylab(ifelse(input$anal=='conc','Effluent Concentrations','Removal Efficiency (%)'))+
        xlab('')
    } else ggplot()
  }
  )

    output$plotOut<-renderPlot({p()})%>%
      bindEvent(input$runIt)

  output$textOut<-renderText({
    paste('<center><p style="font-size:30px"><b>',
          ifelse(input$anal=='conc','Upper 95% Confidence Limit for Effluent Concentrations:',
                        'Lower 95% Confidence Limit for Removal Efficiency:'),
          '<br>',
          formatC(bootOut(),sigfig_num(),format='fg',flag='#'),
          ifelse(input$anal=='conc','','%'),
          '</b></p></center>') 
    })%>%
    bindEvent(input$runIt) 
}
