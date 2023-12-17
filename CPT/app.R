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
    # mainPanel(
    #   tableOutput("T1")
    # ),
    #Application title
    titlePanel("Shiny CPT app"),
    # fluidRow(
    #   column(1,textOutput("T1") )
    # )

        # Show a plot of the generated distribution
       mainPanel(
         "Current cook time (m)",
         textOutput("cookTime"),
         "Current temperatures (F)",
         tableOutput("T1"),
         plotOutput("timePlot")
       )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  demo1 <- reactiveFileReader(5000, NULL, "../demofile1.csv", 
                              read.table, quote="\"", comment.char="")
  #demo = demo1()
  output$timePlot <- renderPlot({ 
    demo = demo1()
    maxT = max(demo[,2:9])+1
    minT = min(demo[,2:9])-1
    maxTime = max(demo$V1, 100)
    colorMap = viridis(8)
    plot(demo$V1,demo$V2, type="b", col=colorMap[1], lwd=2, 
         xlab="Time (s)", ylab="Temp (F)", ylim=c(minT, maxT), xlim=c(0,maxTime), pch=1)
    lines(demo$V1, demo$V3, type="b", lwd=2, col=colorMap[2], pch=2)
    lines(demo$V1, demo$V4, type="b", lwd=2, col=colorMap[3], pch=3) 
    lines(demo$V1, demo$V5, type="b", lwd=2, col=colorMap[4], pch=4) 
    lines(demo$V1, demo$V6, type="b", lwd=2, col=colorMap[5], pch=6) 
    lines(demo$V1, demo$V7, type="b", lwd=2, col=colorMap[6], pch=6) 
    lines(demo$V1, demo$V8, type="b", lwd=2, col=colorMap[7], pch=7) 
    lines(demo$V1, demo$V9, type="b", lwd=2, col=colorMap[8], pch=8) 
    
  })
  
  output$T1 = renderTable({
    #digits=1
    d <-setNames(demo1()[,-1], c("t1", "t2","t3", "t4", "t5", "t6", "t7", "t8"))
  }, digits=1) 
  
  output$cookTime = renderText({ round(demo1()[,1]/60, digits=2)})
}

# Run the application 
shinyApp(ui = ui, server = server)
