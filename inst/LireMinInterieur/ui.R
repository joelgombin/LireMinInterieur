library(shiny)
options(shiny.maxRequestSize=100*1024^2)

shinyUI(fluidPage(
  titlePanel("Transformer les fichiers électoraux du ministère de l'Intérieur"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", label = h3("Sélectionner un fichier csv"), accept=c('text/csv', 'text/comma-separated-values,text/plain')),
      checkboxInput("header", label="Y a-t-il des titres aux colonnes ?", value=TRUE),
      radioButtons("separator", label="Séparateur", c("Virgule" = ",", "Point virgule" = ";")),
      radioButtons("decimal", label="Séparateur décimal", c("Virgule" = ",", "Point" = ".")),
      actionButton("load", "Lire le jeu de données"),
      conditionalPanel(
        condition = "input.load > 0",
        htmlOutput("selectCol"),
        textInput("keepnames", label="noms à donner aux colonnes conservées (doit inclure 'Inscrits' et 'Exprimés'"),
        htmlOutput("selectCol2"),
        numericInput("colStep", label="Combien y a-t-il de colonnes entre les colonnes contenant les nuances politiques ?", value=7, min=1, step=1),
        numericInput("gap", label="Combien y a-t-il de colonnes entre les colonnes avec les étiquettes et celles avec le nombre de voix ?", value=3, min=1, step=1),
        HTML("<BR>"),
        actionButton("validate", "Transformer le fichier")
        ),
      helpText(HTML("<BR><BR><p>Cette application a été développée par <a href='http://www.joelgombin.fr'>Joël Gombin</a>.</p><p>Le code source est disponible sur <a href='http://www.github.com/joelgombin/LireMinInterieur'>mon compte Github</a>.</p>"))
      ),
    mainPanel(
      tabsetPanel(id="tab",
        tabPanel("Fichier avant transformation", dataTableOutput(outputId="tableau_before"), value="before"),
        tabPanel("Fichier après transformation", dataTableOutput(outputId="tableau_after"), downloadButton(outputId="downloadData", label="Télécharger"), value="after"))
      ))
))