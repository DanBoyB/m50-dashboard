statTable <- reactive({
    comb_stats %>% 
        filter(month == input$month,
               direction == input$direction, 
               period == input$period) %>%
        group_by(Sec, month, period, direction) %>% 
        summarise(stableHours = sum(stableHours),
                  monthlyHours = sum(monthlyHours),
                  buffTimeIndex = round(weighted.mean(buffTimeIndex, vkm), 2),
                  miseryIndex = round(weighted.mean(miseryIndex, vkm), 2),
                  vkm = round(sum(vkm), 2),
                  mvkm = round(sum(mvkm), 2)) %>% 
        mutate(percStable = stableHours / monthlyHours) %>% 
        ungroup() %>% 
        select(Sec, mvkm, percStable, buffTimeIndex, miseryIndex) %>% 
        mutate(Sec = factor(Sec, levels = lev),
               percStable = round(percStable * 100, 2)) %>% 
        arrange(Sec) %>% 
        rename(Section = Sec,
               `Million Vehicle Km` = mvkm,
               `% Stable Flow` = percStable,
               `Buffer Time Index` = buffTimeIndex,
               `Misery Index` = miseryIndex)
})

output$table <- DT::renderDataTable(statTable(), 
                                    options = list(dom = 't')) 

