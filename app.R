library(shinydashboard)
library(leaflet)
library(tidyverse)
library(lubridate)
library(sf)

# Load in link data, shapefile and M50 stats
source("R/load-data.R", local = TRUE)

# Load in dashboard UI elements
source("R/db-header.R", local = TRUE)
source("R/db-sidebar.R", local = TRUE)
source("R/db-body.R", local = TRUE)

ui <- dashboardPage(
    dbHeader,
    sidebar,
    body
)

server <- function(input, output) {
    
    # Load in reactive elements
    source("R/stat-table.R", local = TRUE)
    source("R/m50-map.R", local = TRUE)
    source("R/value-boxes.R", local = TRUE)
    source("R/ind-expl-text.R", local = TRUE)
    
    }

# Create App
shinyApp(ui, server)    