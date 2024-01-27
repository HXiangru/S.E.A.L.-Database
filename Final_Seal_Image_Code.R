library(shiny)

setwd("/Users/lael/Desktop/SealImage")

# Background for interactive image (names of images arranged in vector)
slidenames <- read.csv("SlideNames.csv")
slidenames.vector <- unique(slidenames$Slide.Name)

# Define UI
ui <- fluidPage(
  titlePanel("Image Viewer"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown menu for image selection
      selectInput("image", "Select an Image:",
                  choices = NULL,
                  selected = NULL)
    ),
    
    mainPanel(
      # Code to display selected image
      imageOutput("selectedImage")
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Function to render selected image
  output$selectedImage <- renderImage({
    # Path to directory containing images
    img_dir <- "www/"
    
    # Full file path to the selected (.png added to the end of the names specified in the vector)
    img_path <- file.path(img_dir, paste0(input$image, ".png"))
    
    # Render the selected image
    list(src = img_path, 
         alt = "Selected Image",
         width = "100%")
  }, deleteFile = FALSE) # The file is stored in the UI once loaded (?)
  
  # Update dropdown choices based on slidenames.vector
  observe({
    updateSelectInput(session, "image", choices = slidenames.vector)
  })
}


# Run the application
shinyApp(ui = ui, server = server)
