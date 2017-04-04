library(shinydashboard)
library(shinythemes)
library(leaflet)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

links <- read_csv("data/links.csv") %>% 
    slice(2:11) %>% 
    select(siteID, Sec) %>% 
    mutate(siteID = as.factor(siteID))

combStats <- readRDS("data/combStats.rds") %>% 
    ungroup() %>% 
    mutate(month = month(month, label = TRUE, abbr = FALSE)) %>% 
    left_join(links, by = "siteID") 

lev <- c("N11 - CHE", "CHE - CAR", "CAR - BAL", "BAL - FIR", "FIR - N81", "N81 - N7", "N7 - N4",
         "N4 - N3", "N3 - N2")

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
    
    
    statTable <- reactive({
        combStats %>% 
            filter(month == input$month,
                   direction == input$direction, 
                   period == input$period) %>%
            group_by(Sec, month, period, direction) %>% 
            summarise(stableHours = sum(stableHours),
                      monthlyHours = sum(monthlyHours),
                      buffTimeIndex = weighted.mean(buffTimeIndex, vkm),
                      miseryIndex = weighted.mean(miseryIndex, vkm),
                      vkm = sum(vkm),
                      mvkm = sum(mvkm)) %>% 
            mutate(percStable = stableHours / monthlyHours) %>% 
            ungroup() %>% 
            select(Sec, mvkm, percStable, buffTimeIndex, miseryIndex) %>% 
            mutate(Sec = factor(Sec, levels = lev)) %>% 
            arrange(Sec)
    })
    
    globalStats <- reactive({
        combStats %>% 
            filter(month == input$month) %>% 
            summarise(stableHours = sum(stableHours),
                      monthlyHours = sum(monthlyHours),
                      buffTimeIndex = weighted.mean(buffTimeIndex, vkm),
                      miseryIndex = weighted.mean(miseryIndex, vkm),
                      vkm = sum(vkm),
                      mvkm = sum(mvkm)) %>% 
            mutate(percStable = stableHours / monthlyHours) %>% 
            ungroup() %>% 
            select(mvkm, percStable, buffTimeIndex, miseryIndex)
    })
        
    
    output$totalVkm <- renderValueBox({
        valueBox(
            formatC(unlist(globalStats()$mvkm),
                    format = "d", big.mark = ','),
            "Million Vehicle Km on M50",
            icon = icon("car"),
            color = "blue")
        })
  
    output$totalStableFlow <- renderValueBox({
        valueBox(
            formatC(unlist(globalStats()$percStable) * 100,
                    format = "d", big.mark = ','),
            "% Stable Flow on M50",
            icon = icon("thumbs-up"),
            color = "green")
        })
  
      output$totalBuffer <- renderValueBox({
          valueBox(
              formatC(unlist(globalStats()$buffTimeIndex),
                      format = "d", big.mark = ','),
              "M50 Buffer Time Index",
              icon = icon("clock-o"),
              color = "orange")
          })
  
        output$totalMisery <- renderValueBox({
            valueBox(
                formatC(unlist(globalStats()$miseryIndex),
                        format = "d", big.mark = ','),
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
          
            output$table <- renderTable(statTable())
            
        }

shinyApp(ui, server)