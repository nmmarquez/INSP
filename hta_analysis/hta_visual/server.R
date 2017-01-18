library(shiny)
library(leaflet)
source("./utilities.R")

shinyServer(function(input,output){
    df <- reactive({data_map(input$edad, input$sexo, input$modelo)})
    output$mapplot <- renderLeaflet({
        leaf_map(df())
    })
    output$hist <- renderPlot({
        hist_plot(df())
    })
})