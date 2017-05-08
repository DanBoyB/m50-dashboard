sidebar <- dashboardSidebar(
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
)