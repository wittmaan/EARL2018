
function(input, output, session) {
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.DarkMatter") %>%
      addCircles(lng = dat.aug$lon, lat = dat.aug$lat) %>%
      setView(lng = 11.52284, lat = 48.15981, zoom = 10)
  })
  
  output$text <- renderText({
    paste0("showing ", nrow(dat.aug), " points")
  })
}