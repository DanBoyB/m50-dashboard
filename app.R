library(shinydashboard)
library(shinythemes)
library(leaflet)
library(tidyverse)
library(lubridate)
library(sf)

# Load in link data, shapefile and M50 stats
links <- read_csv("data/links.csv") %>% 
    slice(2:11) %>% 
    select(siteID, Sec) %>% 
    mutate(siteID = as.factor(siteID))

comb_stats <- readRDS("data/combStats.rds") %>% 
    ungroup() %>% 
    mutate(month = month(month, label = TRUE, abbr = FALSE)) %>% 
    left_join(links, by = "siteID") 

m50_secs <- st_read("data/m50-secs-wgs.shp") %>% 
    left_join(comb_stats, by = c("sec" = "Sec")) %>% 
    filter(sec != "BMN - M1")

# Create colour palette for leaflet map
pal <- colorFactor(
    palette = "Paired",
    domain = m50_secs$sec,
    ordered = FALSE)

# Create factor levels to order M50 sections
lev <- c("N11 - CHE", "CHE - CAR", "CAR - BAL", "BAL - FIR", "FIR - N81", "N81 - N7", "N7 - N4",
         "N4 - N3", "N3 - N2")

# Dates for dashboard sidebar dropdowns
years <- c(2015)
months <- month(seq.Date(as.Date("2015-01-01"), 
                         as.Date("2015-12-31"), 
                         by = "month"),
         label = TRUE, 
         abbr = FALSE)

# Text output explaining indicators

ind_expl <- paste("Vehicle Km", "Explanation of vkm", sep = "\n")

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
        leafletOutput("mymap")
      ),
      box(width = 6, title = "Indicators by Section",
          tableOutput("table")
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
    
    
    statTable <- reactive({
        comb_stats %>% 
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
            mutate(Sec = factor(Sec, levels = lev),
                   percStable = percStable * 100) %>% 
            arrange(Sec) %>% 
            rename(Section = Sec,
                   `Million Vehicle Km` = mvkm,
                   `% Stable Flow` = percStable,
                   `Buffer Time Index` = buffTimeIndex,
                   `Misery Index` = miseryIndex)
    })
    
    globalStats <- reactive({
        comb_stats %>% 
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
              leaflet(m50_secs, width = 5, height = 10) %>%
                  addTiles() %>%
                  setView(-6.2883, 53.33, zoom = 11) %>% 
                  addPolylines(color = ~pal(sec),
                               highlightOptions = highlightOptions(color = "white", weight = 2,
                                                                   bringToFront = TRUE))
                })
          
          observeEvent(input$map_click, {
              ## Get the click info like had been doing
              click <- input$map_click
              clat <- click$lat
              clng <- click$lng
              address <- revgeocode(c(clng,clat))
              
              leafletProxy('map', data = filteredData()) %>%
                  addPopups(popup = tagList(tags$h4(statTable()$Sec)))
          })
          
          output$table <- renderTable(statTable())
          
          output$text1 <- renderUI({
              HTML(paste("Vehicle kilometre as a measure of traffic flow, determined by 
                         multiplying the number of vehicles on a given section of the M50 by the 
                         length of that M50 section measured in kilometres.", "</b>"))
          })
          
          output$text2 <- renderUI({
              HTML(paste("Stable flow on the M50 is defined as the percentage of time that traffic speeds are in 
                         excess of 60 kph and the traffic stream is operating at a level of service (LOS)
                         of A, B or C.", "</b>"))
          })
          
          output$text3 <- renderUI({
              HTML(paste("The buffer time index is a measure of typical journey time reliability. It represents 
                         the percentage extra time that travelers on the M50 need to add to their average travel 
                         time when planning trips to ensure on-time arrival", "</b>", "e.g, a buffer time index of 20 means 
                         that, for a 15 min average travel time on the M50, a traveler should allow for an 
                         additional 3 minutes to ensure on-time arrival most of the time. A higher buffer time index
                         implies less reliable travel times on the M50.", "</b>"))
          })
          
          output$text4 <- renderUI({
              HTML(paste("The misery index is a measure of the amount of delay of the worst trips on the M50. This is
                         similar to the buffer time index but includes for the impact of the highest travel times, 
                         generally due to major incidents or severe congestion caused by other irregular factors. A
                         higher misery index implies that more incidents or severe congestion occured on the M50.", "</b>"))
          })
                         
                         
                         
                         
            
        }

shinyApp(ui, server)    