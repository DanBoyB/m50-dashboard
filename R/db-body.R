body <- dashboardBody(
    # tags$head(tags$style(HTML('
    #                           .skin-blue .main-header .logo {
    #                           background-color: #0000b8;
    #                           }
    #                           .skin-blue .main-header .logo:hover {
    #                           background-color: #0000b8;
    #                           }
    #                           /* navbar (rest of the header) */
    #                           .skin-blue .main-header .navbar {
    #                           background-color: #0000b8;
    #                           }
    #                           '))),
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