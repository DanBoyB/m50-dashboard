library(shinydashboard)
library(shinythemes)
library(leaflet)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

combStats <- readRDS("data/combStats.rds") %>% 
    ungroup() %>% 
    mutate(month = month(month, label = TRUE, abbr = FALSE))

lev <- readRDS("data/nblevels.rds") %>% 
    append(readRDS("data/sblevels.rds"))

lev[-c(10:11)]

sections <- data_frame(sectionName = unique(combStats$sectionName)) %>% 
    mutate(sectionName = factor(sectionName, levels = lev[-c(10:11)]))


years <- c(2015)
months <- month(seq.Date(as.Date("2015-01-01"), 
                         as.Date("2015-12-31"), 
                         by = "month"),
         label = TRUE, 
         abbr = FALSE)

ui <- dashboardPage(
  dashboardHeader(title = "M50 Test dashboard"),
  dashboardSidebar(
    selectInput("year", label = "Select Year:",
                choices = years),
    selectInput("month", label = "Select Month:",
                choices = months),
    radioButtons("period", label = "Analysis Period",
                 choices = list("All" = 1, 
                                "Off Peak / Holiday Periods" = 2,
                                "AM Peak Shoulders" = 3,
                                "AM Peak Hour" = 4,
                                "Inter Peak" = 5,
                                "PM Peak Shoulders" = 6,
                                "PM Peak Hour" = 7
                                ), 
                 selected = 1),
    checkboxGroupInput("direction", label = "Traffic Direction",
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
        leafletOutput("mymap")
      ),
      box(width = 6, title = "Indicators by Section",
          tableOutput("table")
      ),
      box(width = 12, title = "Indicators Explained"
      )
      
    )
  )
)

server <- function(input, output) {
    
    
    table <- reactive({
        combStats %>% 
            filter(month == input$month,
                   direction == input$direction) %>% 
            select(-month, -direction)
    })
        
    
    output$totalVkm <- renderValueBox({
        valueBox(
            formatC(100, format = "d", big.mark = ','),
            "Million Vehicle Km on M50",
            icon = icon("car"),
            color = "blue")
        })
  
    output$totalStableFlow <- renderValueBox({
        valueBox(
            formatC(100, format = "d", big.mark = ','),
            "% Stable Flow on M50",
            icon = icon("thumbs-up"),
            color = "green")
        })
  
      output$totalBuffer <- renderValueBox({
          valueBox(
              formatC(100, format = "d", big.mark = ','),
              "M50 Buffer Time Index",
              icon = icon("clock-o"),
              color = "orange")
          })
  
        output$totalMisery <- renderValueBox({
            valueBox(
                formatC(100, format = "d", big.mark = ','),
                "M50 Misery Index",
                icon = icon("frown-o"),
                color = "red")
            })
  
          output$mymap <- renderLeaflet({
              leaflet(width = 5, height = 10) %>%
                  addTiles() %>%
                  fitBounds(lat1 = 53.437327, lng1 = -6.186063, lat2 = 53.218444, lng2 = -6.414639) 
              # %>% 
              #   # Add default OpenStreetMap map tiles
              #   addMarkers(, popup="M50") 
              
                })
          
            output$table <- renderTable(table())
            
        }

shinyApp(ui, server)