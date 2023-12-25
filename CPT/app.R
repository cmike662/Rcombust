#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(viridisLite)
library(lubridate)
# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = shinytheme("slate"),
  #shinythemes::themeSelector(),
  #Application title
  titlePanel("Shiny CPT app"),
  
  # Show a plot of the generated distribution
  mainPanel(
    column(3, "Current cook time (m)",textOutput("cookTime")),
    column(3, "Start cook time", textOutput("startTime")),
    column(6, "Current temperatures (F)", tableOutput("T1")),
    tabsetPanel(type = "tabs",
                tabPanel("Temperature", plotOutput("timePlot", 
                                                   click = "timePlot_click",
                                                   dblclick = "timePlot_dblclick",
                                                   brush = brushOpts(
                                                     id = "timePlot_brush",
                                                     resetOnNew = TRUE
                                                   ) ),
                         verbatimTextOutput("info")),
                tabPanel("Heat Units", plotOutput("heatPlot",
                                                  click="heatPlot_click"),
                        verbatimTextOutput("infoHeat")),
                tabPanel("Heat Gradient", plotOutput("fluxPlot"))
    )
  )
)

# Define server logic required to draw a heat accumulation
server <- function(input, output) {
  sumHeatUnits <- c(0,0,0,0,0,0,0,0,0)
  demo <- data.frame()
  accumulatedUnits <- data.frame()
  baseTemp = 130
  defaultInterval = 10
  cookStart = 0
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  #Initial check on CPT data
  if(file.exists("../CombustCommCont.csv")){
    demo = read.table("../CombustCommCont.csv")
    cookStart = demo[1,1]
    demo[1,1] = 0
    accumulatedUnits = data.frame(t(sumHeatUnits))
    if(nrow(demo) > 1) {
    for (j in 2:nrow(demo)){
      demo[j,1] = demo[j,1]-cookStart
      sumHeatUnits[1] = demo[j,1]
      deltaT = demo[j,1] - demo[j-1,1]
      #if(deltaT > 0){
        for (j1 in 2:9){
          sumHeatUnits[j1] <- max(0, ((demo[j,j1]+demo[j-1,j1])/2-baseTemp)*deltaT/60) + sumHeatUnits[j1]
        }
      #}
      accumulatedUnits = rbind(accumulatedUnits, sumHeatUnits)
    }
    }
  }
  while (!file.exists("../CombustComm.csv")){
    Sys.sleep(1)
  }
  demo1 <- reactiveFileReader(7000, NULL, "../CombustComm.csv", 
                              read.table, quote="\"", comment.char="")
  #tryCatch(read.table(x, header = TRUE, sep = '|'), error=function(e) NULL)
  
  observeEvent(demo1(), {
    if (nrow(demo) == 0){
      tmp = demo1()
      tmp[1,1]=0
      demo <<- tmp
      cookStart <<- demo1()[1,1]
    }else {
      tmp = demo1()
      tmp[1,1] = demo1()[1,1] - cookStart 
      demo <<- rbind(demo, tmp)
    }
    HeatUnits <- sumHeatUnits
    nr <- nrow(demo)
    if (nr > 1){
      HeatUnits[1] = demo[nr,1]
      deltaT = demo[nr,1] - demo[nr-1,1]
    } else {
      deltaT = demo[1,1]
    }
    if(deltaT > 0){
      for (j in 2:9){
        HeatUnits[j] <- max(0, ((demo1()[,j] + demo[nr-1,j])/2-baseTemp)*deltaT/60) + HeatUnits[j]
      }
    }
      sumHeatUnits <<- HeatUnits
      if(nrow(accumulatedUnits) == 0){
        accumulatedUnits <<- as.data.frame(t(sumHeatUnits))
      } else {
        accumulatedUnits <<- rbind(accumulatedUnits, sumHeatUnits)
      }
  })
  
  output$heatPlot <- renderPlot({
    t = demo1()
    colorMap = viridis(8)
    maxA <- max(accumulatedUnits[,6:9])
    minA <- min(accumulatedUnits[,6:9])
    if(maxA == minA) {maxA = maxA+1}
    maxTime = max(demo$V1/60, 10)
    plot(accumulatedUnits[,1]/60, accumulatedUnits[,6], type="l", lwd=3, col=colorMap[1], 
         pch=1, ylim = c(minA, maxA), xlim=c(0,maxTime), 
         xlab="Time (m)", ylab="Accumulated Heat Units")
    for (j in 7:9){
      lines(accumulatedUnits[,1]/60, accumulatedUnits[,j], type="l", lwd=3, col=colorMap[j-1], pch=j-1) 
    }
  })
  
  #Respond to click on accumulated plot
  output$infoHeat <- renderText({
    paste0("Time: ", input$heatPlot_click$x, "\nAccumulated units: ", input$heatPlot_click$y)
  })
  
  
  #Plot the temperature v time plot  
  output$timePlot <- renderPlot({ 
    tmp = demo1()
    if (!is.null(ranges$x)) {
      rangeX = ranges$x
      rangeY = ranges$y
    } else {
      rangeX = c(0, max(demo[,1]/60, 10))
      rangeY = c(min(demo[,2:9])-1, max(demo[,2:9])+1)
    }
    colorMap = viridis(8)
    plot(demo$V1/60,demo$V2, type="l", col=colorMap[1], lwd=2, 
         xlab="Time (m)", ylab="Temp (F)", ylim=rangeY, xlim=rangeX, pch=1)
    lines(demo$V1/60, demo$V3, type="l", lwd=2, col=colorMap[2], pch=2)
    lines(demo$V1/60, demo$V4, type="l", lwd=2, col=colorMap[3], pch=3) 
    lines(demo$V1/60, demo$V5, type="l", lwd=2, col=colorMap[4], pch=4) 
    lines(demo$V1/60, demo$V6, type="l", lwd=2, col=colorMap[5], pch=6) 
    lines(demo$V1/60, demo$V7, type="l", lwd=2, col=colorMap[6], pch=6) 
    lines(demo$V1/60, demo$V8, type="l", lwd=2, col=colorMap[7], pch=7) 
    lines(demo$V1/60, demo$V9, type="l", lwd=2, col=colorMap[8], pch=8) 
    
  })
  
  # When a double-click happens, check if there's a brush on the plot.
  # If so, zoom to the brush bounds; if not, reset the zoom.
  observeEvent(input$timePlot_dblclick, {
    brush <- input$timePlot_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })  

  #Response to click on temperature graph  
  output$info <- renderText({
    paste0("Time: ", input$timePlot_click$x, "\nTemperature: ", input$timePlot_click$y)
  })
  
  #Render the flux chart
  output$fluxPlot <- renderPlot({
    vcat <- vector()
    vflux <- vector()
    for(j in 7:1){
      vcat[j] = 8-j
      vflux[j] = (demo1()[,j+1] - demo1()[,j+2])
    }
    plot(vcat, vflux, type="b", xlab="Sensor", ylab="Delta T", xlim=rev(range(vcat)))
  }) 
  
  output$T1 = renderTable({
    #digits=1
    d <-setNames(demo1()[,-1], c("t8", "t7","t6", "t5", "t4", "t3", "t2", "t1"))
  }, digits=1) 
  
  output$cookTime = renderText({ round((demo1()[,1]-cookStart)/60, digits=2)})
  
  output$startTime = renderText({
    #The with_tz() should convert it to the local timezone
    tst = with_tz(as_datetime(cookStart))
    tmp = paste0(month(tst),"-", day(tst),"-", year(tst),"\n",
          hour(tst),":", minute(tst),":", round(second(tst))) 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
