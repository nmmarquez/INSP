rm(list=ls())
pacman::p_load(shiny, shinydashboard, leaflet, data.table)

source("./utilities.R")

ages <- sort(unique(DF$edad))
sex <- sort(unique(DF$sexo))
models <- sort(unique(DF$model_name))

header <- dashboardHeader(
    title = 'Prevelencia'
)

body <- dashboardBody(
    fluidRow(
        column(width=12,
               tabBox(id='tabvals', width=NULL,
                   tabPanel('Map', leafletOutput('mapplot'), value=1),
                   tabPanel('Histogram', plotOutput('hist'), value=2)
               )
        ) 
    ),
    tags$head(tags$style(HTML('
                              section.content {
                              height: 2500px;
                              }
                              ')))
    )



sidebar <- dashboardSidebar(
    selectInput('edad', 'Edad', ages),
    selectInput('sexo', 'Sexo', sex),
    selectInput('modelo', 'Modelo', models)
)

dashboardPage(
    header,
    sidebar,
    body
)