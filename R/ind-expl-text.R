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