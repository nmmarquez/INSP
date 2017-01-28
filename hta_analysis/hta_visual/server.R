pacman::p_load(shiny, leaflet, INSP)
source("./utilities.R")

shinyServer(function(input,output){
    df <- reactive({data_map(input$edad, input$sexo, input$modelo)})
    output$mapplot <- renderLeaflet({
        spdf2leaf(df())
    })
    output$hist <- renderPlot({
        hist_plot(df())
    })
})