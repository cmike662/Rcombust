#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(viridisLite)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  #Application title
  titlePanel("Shiny CPT app"),
  
  # Show a plot of the generated distribution
  mainPanel(
    "Current cook time (m)",
    textOutput("cookTime"),
    "Current temperatures (F)",
    tableOutput("T1"),
    tabsetPanel(type = "tabs",
                tabPanel("Temperature", plotOutput("timePlot")),
                tabPanel("Heat Units", plotOutput("heatPlot")),
                tabPanel("Heat flux", plotOutput("fluxPlot"))
    )
  )
)

# Define server logic required to draw a heat accumulation
server <- function(input, output) {
  sumHeatUnits <- c(0,0,0,0,0,0,0,0,0)
  demo <- data.frame()
  accumulatedUnits <- data.frame()
  baseTemp = 60 #130
  defaultInterval = 10
  cookStart = 0
  
  #Initial check on CPT data
  if(file.exists("../CombustCommCont.csv")){
    demo = read.table("../CombustCommCont.csv")
    cookStart = demo[1,1]
    demo[1,1] = 0
    accumulatedUnits = data.frame(t(sumHeatUnits))
    for (j in 2:nrow(demo)){
      demo[j,1] = demo[j,1]-cookStart
      sumHeatUnits[1] = demo[j,1]
      deltaT = demo[j,1] - demo[j-1,1]
      if(deltaT > 0){
        for (j1 in 2:9){
          sumHeatUnits[j1] <- max(0, (demo[j,j1]-baseTemp)/deltaT/60) + sumHeatUnits[j1]
        }
      }
      accumulatedUnits = rbind(accumulatedUnits, sumHeatUnits)
    }
  }
  while (!file.exists("../CombustComm.csv")){
    Sys.sleep(1)
  }
  demo1 <- reactiveFileReader(10000, NULL, "../CombustComm.csv", 
                              read.table, quote="\"", comment.char="")

  
  observeEvent(demo1(), {
    if (nrow(demo) == 0){
      tmp = demo1()
      tmp[1,1]=0
      demo <<- tmp
      cookStart <<- demo1()[1,1]
    }else {
      #curTime = demo1()[1,1] - cookStart
      tmp = demo1()
      tmp[1,1] = demo1()[1,1] - cookStart 
      demo <<- rbind(demo, tmp)
      #demo[nrow(demo),1] = curTime
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
        HeatUnits[j] <- max(0, (demo1()[,j]-baseTemp)/deltaT/60) + HeatUnits[j]
      }
    }
      sumHeatUnits <<- HeatUnits
      if(nrow(accumulatedUnits) == 0){
        accumulatedUnits <<- as.data.frame(t(sumHeatUnits))
      } else {
        accumulatedUnits <<- rbind(accumulatedUnits, sumHeatUnits)
      }

    #print(accumulatedUnits)
  })
  
  output$heatPlot <- renderPlot({
    t = demo1()
    colorMap = viridis(8)
    maxA <- max(accumulatedUnits[,2:9])
    minA <- min(accumulatedUnits[,2:9])
    if(maxA == minA) {maxA = maxA+1}
    maxTime = max(demo$V1/60, 10)
    plot(accumulatedUnits[,1]/60, accumulatedUnits[,2], type="b", lwd=2, col=colorMap[1], 
         pch=1, ylim = c(minA, maxA), xlim=c(0,maxTime), 
         xlab="Time (m)", ylab="Accumulated Heat Units")
    for (j in 3:9){
      lines(accumulatedUnits[,1]/60, accumulatedUnits[,j], type="b", lwd=2, col=colorMap[j-1], pch=j-1) 
    }
  })

  #Plot the temperature v time plot  
  output$timePlot <- renderPlot({ 
    tmp = demo1()
    maxT = max(demo[,2:9])+1
    minT = min(demo[,2:9])-1
    maxTime = max(demo$V1/60, 10)
    colorMap = viridis(8)
    plot(demo$V1/60,demo$V2, type="b", col=colorMap[1], lwd=2, 
         xlab="Time (m)", ylab="Temp (F)", ylim=c(minT, maxT), xlim=c(0,maxTime), pch=1)
    lines(demo$V1/60, demo$V3, type="b", lwd=2, col=colorMap[2], pch=2)
    lines(demo$V1/60, demo$V4, type="b", lwd=2, col=colorMap[3], pch=3) 
    lines(demo$V1/60, demo$V5, type="b", lwd=2, col=colorMap[4], pch=4) 
    lines(demo$V1/60, demo$V6, type="b", lwd=2, col=colorMap[5], pch=6) 
    lines(demo$V1/60, demo$V7, type="b", lwd=2, col=colorMap[6], pch=6) 
    lines(demo$V1/60, demo$V8, type="b", lwd=2, col=colorMap[7], pch=7) 
    lines(demo$V1/60, demo$V9, type="b", lwd=2, col=colorMap[8], pch=8) 
    
  })
  
  #Render the flux chart
  output$fluxPlot <- renderPlot({
    vcat <- vector()
    vflux <- vector()
    for(j in 7:1){
      vcat[j] = 8-j
      vflux[j] = (demo1()[,j+1] - demo1()[,j+2])
    }
    plot(vcat, vflux, type="b", xlab="probe", ylab="Delta T", xlim=rev(range(vcat)))
  }) 
  
  output$T1 = renderTable({
    #digits=1
    d <-setNames(demo1()[,-1], c("t8", "t7","t6", "t5", "t4", "t3", "t2", "t1"))
  }, digits=1) 
  
  output$cookTime = renderText({ round((demo1()[,1]-cookStart)/60, digits=2)})
}

# Run the application 
shinyApp(ui = ui, server = server)
