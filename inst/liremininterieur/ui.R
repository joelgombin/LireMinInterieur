library(shiny)
options(shiny.maxRequestSize=100*1024^2)
switch(Sys.info()[['sysname']],
       Windows= {Sys.setlocale(category = "LC_ALL", locale = "fra")},
       Linux  = {Sys.setlocale("LC_ALL", "fr_FR.UTF-8")},
       Darwin = {Sys.setlocale("LC_ALL", "fr_FR.UTF-8")})

shinyUI(fluidPage(
  titlePanel("Transforming the French Home Office electoral data files"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = h3("Select a CSV file"), accept=c('text/csv', 'text/comma-separated-values,text/plain')),
      checkboxInput("header", label="Are there headers?", value=TRUE),
      radioButtons("separator", label="Field separator character", c("Comma" = ",", "Semi-colon" = ";")),
      radioButtons("decimal", label="Decimal separator character", c("Comma" = ",", "Period" = ".")),
      actionButton("load", "Load the dataset"),
      conditionalPanel(
        condition = "input.load > 0",
        htmlOutput("selectCol"),
        textInput("keepnames", label="Names to give to the selected columns (must include 'Inscrits' and 'Exprimés')"),
        htmlOutput("selectCol2"),
        numericInput("colStep", label="How many columns between the political labels columns?", value=7, min=1, step=1),
        numericInput("gap", label="How many columns between the political labels and the vote counts?", value=3, min=1, step=1),
        HTML("<BR>"),
        actionButton("validate", "Process file")
        ),
      helpText(HTML("<BR><BR><p>This app was developed by <a href='http://www.joelgombin.fr'>Joël Gombin</a>.</p><p>The source code is available on my <a href='http://www.github.com/joelgombin/LireMinInterieur'>Github account</a>.</p>"))
      ),
    mainPanel(
      tabsetPanel(id="tab",
        tabPanel("File before processing", dataTableOutput(outputId="tableau_before"), value="before"),
        tabPanel("File after processing", dataTableOutput(outputId="tableau_after"), downloadButton(outputId="downloadData", label="Download processed file"), value="after"))
      ))
))