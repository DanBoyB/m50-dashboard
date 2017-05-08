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