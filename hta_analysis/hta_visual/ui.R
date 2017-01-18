rm(list=ls())
library(shiny)
library(shinydashboard)
library(leaflet)
library(data.table)
df <- fread("./prev_data.csv")
ages <- sort(as.numeric(as.character(unique(df$edad_cat2))))
sex <- as.character(unique(df$sexo))

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
    selectInput('sexo', 'Sexo', sex)
)

dashboardPage(
    header,
    sidebar,
    body
)