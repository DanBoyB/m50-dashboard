library(shinydashboard)
library(shinythemes)
library(leaflet)
library(tidyverse)
library(lubridate)
library(sf)

# Load in link data, shapefile and M50 stats
source("R/load-data.R", local = TRUE)

################################################################################################
# Shiny UI

ui <- dashboardPage(
  dashboardHeader(title = "M50 Test dashboard"),
  dashboardSidebar(
    selectInput("year", label = "Select Year:",
                choices = years),
    selectInput("month", label = "Select Month:",
                choices = months),
    radioButtons("period", label = "Analysis Period",
                 choices = list("Off Peak",
                                "AM Peak Shoulders",
                                "AM Peak Hour",
                                "Inter Peak",
                                "PM Peak Shoulders",
                                "PM Peak Hour"
                                ), 
                 selected = "AM Peak Hour"),
    radioButtons("direction", label = "Traffic Direction",
                 choices = list("Northbound",
                                "Southbound"
                                ), 
                 selected = "Northbound")
  ),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box(title = "Monthly Summary Indicators", width = 12,
        valueBoxOutput("totalVkm", width = 3),
        valueBoxOutput("totalStableFlow", width = 3),
        valueBoxOutput("totalBuffer", width = 3),
        valueBoxOutput("totalMisery", width = 3)
      ),
      box(width = 6, 
        leafletOutput("map")
      ),
      box(width = 6, title = "Indicators by Section",
          DT::dataTableOutput("table")
      ),
      tabBox(width = 12, title = "Indicators Explained",
             tabPanel("Vehicle Km", htmlOutput("text1")),
             tabPanel("Stable Flow", htmlOutput("text2")),
             tabPanel("Buffer Time Index", htmlOutput("text3")),
             tabPanel("Misery Index", htmlOutput("text4"))
      )
      
    )
  )
)

server <- function(input, output) {
    
    source("R/stat-table.R", local = TRUE)
    source("R/m50-map.R", local = TRUE)
    source("R/value-boxes.R", local = TRUE)
    source("R/ind-expl-text.R", local = TRUE)
    
    }

shinyApp(ui, server)    