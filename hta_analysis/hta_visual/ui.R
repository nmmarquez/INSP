rm(list=ls())
pacman::p_load(shiny, shinydashboard, leaflet, data.table)

df <- fread(list.files("./models", full.names=T)[1])
ages <- sort(as.numeric(as.character(unique(df$edad_cat2))))
sex <- as.character(unique(df$sexo))
models <- gsub(".csv", "", list.files("./models/"))

header <- dashboardHeader(
    title = 'Prevelencia HTA'
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