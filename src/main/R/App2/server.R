
require(httr)
require(stringr)

function(input, output, session) {
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.DarkMatter", options = tileOptions(maxZoom = 19)) %>%
      setView(lng = 11.52284, lat = 48.15981, zoom = 10)
  })
  
  render <- reactive({
    bounds <- input$map_bounds
    zoom <- input$map_zoom
    
    if (!is.null(zoom) && !is.null(bounds)) {
      tileNortWest <- calcTile(zoom = zoom, lat = bounds$north, lon = bounds$west)
      tileSouthEast <- calcTile(zoom = zoom, lat = bounds$south, lon = bounds$east)
      
      ## render tiles
      x_from <- as.character(round(tileNortWest$x) - 1)
      x_to <- as.character(round(tileSouthEast$x) + 1)
      y_from <- as.character(round(tileNortWest$y) - 1)
      y_to <- as.character(round(tileSouthEast$y) + 1)
      
      cat(paste0("rendering tile for zoom=", zoom, ", x_from=", x_from, ", x_to=", x_to, ", y_from=", y_from, ", y_to=", y_to, "\n"))      
      url <- paste0("http://localhost:7000/render/", zoom, "/", x_from, "/", x_to, "/", y_from, "/", y_to)
      httr::GET(url)   
    }
    
    leafletProxy("map") %>% 
      addTiles(urlTemplate = "http://localhost:4321/tile/{z}_{x}_{y}.png",
               options = tileOptions(maxZoom = 19))
  })
  
  output$text <- renderText({
    render()
    return("rendered")
  })
}