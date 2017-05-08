
output$map <- renderLeaflet({
    leaflet(m50_secs, width = 5, height = 10) %>%
        addProviderTiles(providers$CartoDB.Positron) %>% 
        setView(-6.2883, 53.33, zoom = 11) %>% 
        addPolylines(color = ~pal(sec),
                     highlightOptions = highlightOptions(color = "white", weight = 2,
                                                         bringToFront = TRUE),
                     layerId = ~sec,
                     opacity = 1.0)
})

#input$MAPID_OBJCATEGORY_EVENTNAME

observeEvent(input$map_shape_click, {
    clickId <- input$map_shape_click$id 
    
    DT::dataTableProxy("table") %>%
        DT::selectRows(which(statTable()$Section == clickId))
})

