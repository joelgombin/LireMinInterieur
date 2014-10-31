library(shiny)
library(LireMinInterieur)
switch(Sys.info()[['sysname']],
       Windows= {Sys.setlocale(category = "LC_ALL", locale = "fra")},
       Linux  = {Sys.setlocale("LC_ALL", "fr_FR.UTF-8")},
       Darwin = {Sys.setlocale("LC_ALL", "fr_FR.UTF-8")})

shinyServer(function(input, output, session) {
  df <- reactive({
    input$load
    isolate({
      if (input$load==0) df <- NULL
      else {
        # petit hack pour gérer l'encodage. Faut-il intégrer d'autres encodages ?
        df <- tryCatch(read.csv((input$file)$datapath, header=input$header, sep=input$separator, dec=input$decimal, stringsAsFactor=FALSE),
                      error = function(c) read.csv((input$file)$datapath, header=input$header, sep=input$separator, dec=input$decimal, stringsAsFactor=FALSE, fileEncoding="ISO8859-1"))  
        names(df) <- iconv(names(df), from="", to="UTF-8")
      }
    })
    return(df)
  })
  
  output$tableau_before <- renderDataTable({
    df()
  }, options=list(pageLength=10))
  
  
  output$selectCol <- renderUI({
    selectizeInput("keep", label="Quelles colonnes faut-il conserver en l'état ?", choices=names(df()), multiple=TRUE)
  })

  observe({
    updateTextInput(session, "keepnames", label="noms à donner aux colonnes conservées (doit inclure 'Inscrits' et 'Exprimés'", value=input$keep)
  })  
  
  
  output$selectCol2 <- renderUI({
    selectizeInput("colInit", label="Quelle est la première colonne dans laquelle sont situées les nuances politiques ?", choices=names(df()), multiple=FALSE)
  })
  

  # transfomation du jeu de données quand il change
  
  df_trans <- reactive({
    # est dépendant de input$validate
    input$validate
    if (input$validate == 0) return(NULL)
    # on isole la suite
    
    isolate({
      index <- match(input$colInit, names(df()))
      col <- (dim(df())[2] - index) %/% input$colStep
      df_trans <- lire(df(), keep=input$keep, col=seq(from=index, by=input$colStep, length.out=col), keep.names=strsplit(input$keepnames, split=",")[[1]], gap=input$gap)
    })
    return(df_trans)
  })
  
  output$tableau_after <- renderDataTable({
    df_trans()
  }, options=list(pageLength=10))
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(con) {
      write.csv(df_trans(), con, row.names=FALSE)
    }
  )
  
})
