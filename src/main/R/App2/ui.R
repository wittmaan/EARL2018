
navbarPage("App2",
  tabPanel("map",
    div(class = "outer",
        tags$head(# Include our custom CSS
        includeCSS("style.css")),
                      
        # If not using custom CSS, set height of leafletOutput to a number instead of percent
        leafletOutput("map", width = "100%", height = "100%"), 
        
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                      width = 330, height = "auto",
                      br(),
                      textOutput("text"))
    )
  )
)
