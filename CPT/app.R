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

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("timePlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  demo1 <- reactiveFileReader(5000, NULL, "../demofile1.csv", 
                              read.table, quote="\"", comment.char="")
  output$timePlot <- renderPlot({ 
    demo = demo1()
    maxT = max(demo[,2:9])+1
    minT = min(demo[,2:9])-1
    colorMap = viridis(8)
    plot(demo$V1,demo$V2, type="b", col=colorMap[1], lwd=2, 
         xlab="Time (s)", ylab="Temp (F)", ylim=c(minT, maxT), pch=1)
    lines(demo$V1, demo$V3, type="b", lwd=2, col=colorMap[2], pch=2)
    lines(demo$V1, demo$V4, type="b", lwd=2, col=colorMap[3], pch=3) 
    lines(demo$V1, demo$V5, type="b", lwd=2, col=colorMap[4], pch=4) 
    lines(demo$V1, demo$V6, type="b", lwd=2, col=colorMap[5], pch=6) 
    lines(demo$V1, demo$V7, type="b", lwd=2, col=colorMap[6], pch=6) 
    lines(demo$V1, demo$V8, type="b", lwd=2, col=colorMap[7], pch=7) 
    lines(demo$V1, demo$V9, type="b", lwd=2, col=colorMap[8], pch=8) 
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
