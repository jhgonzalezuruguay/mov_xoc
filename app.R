############################################################
# TMS - Movilidad Ocupacional Uruguay
# José González Gómez
# Versión 3.2 DEFINITIVA (Con ME y MC integrados)
############################################################

library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(plotly)
library(vcd)
library(reshape2)

############################################################
# MATRIZ REAL (PORCENTAJES)
############################################################

categorias <- c(
  "1.L,o,d","2.Prof","3.Tec","4.Ofi","5.Ser,ve",
  "6a.Rp","6b.Rt","7.O y m","8.Op pl","9.T.noC"
)

matriz_mov <- matrix(c(
  0.61,1.34,0.82,1.16,1.02,0.01,0.14,0.69,0.25,0.70,
  0.34,2.14,1.00,0.73,0.47,0.03,0.12,0.19,0.03,0.19,
  0.12,0.77,0.67,0.91,0.69,0.02,0.05,0.45,0.18,0.56,
  0.44,1.77,1.08,1.85,1.74,0.02,0.18,1.00,0.65,1.55,
  0.36,0.86,0.73,1.15,2.39,0.05,0.19,1.52,0.62,2.20,
  0.11,0.36,0.26,0.24,0.56,0.32,0.36,0.47,0.29,0.97,
  0.19,0.39,0.23,0.43,0.68,0.15,0.65,0.61,0.34,1.33,
  0.47,1.91,1.55,2.56,5.08,0.03,0.39,5.53,1.79,5.56,
  0.28,1.04,0.91,1.51,2.81,0.02,0.26,1.76,1.37,2.74,
  0.41,0.67,0.62,1.20,3.16,0.09,0.95,2.90,1.21,5.47
), nrow=10, byrow=TRUE)

dimnames(matriz_mov) <- list(Origen=categorias,
                             Destino=categorias)

############################################################
# INDICADORES
############################################################

movilidad_total <- 100 - sum(diag(matriz_mov))
inmovilidad <- sum(diag(matriz_mov))

marg_origen  <- rowSums(matriz_mov)
marg_destino <- colSums(matriz_mov)

mov_estructural  <- 0.5 * sum(abs(marg_origen - marg_destino))
mov_circulatoria <- movilidad_total - mov_estructural

freq <- round(matriz_mov * 100)
tabla <- as.table(freq)

############################################################
# UI
############################################################

ui <- dashboardPage(
  skin="blue",
  
  dashboardHeader(title="Movilidad Ocupacional - Uruguay"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName="inicio", icon=icon("home")),
      menuItem("Matriz de Movilidad", tabName="matriz", icon=icon("table")),
      menuItem("Visualización", tabName="visual", icon=icon("chart-bar")),
      menuItem("Indicadores", tabName="indicadores", icon=icon("chart-line"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      tabItem(tabName="inicio",
              fluidRow(
                box(width=12, status="primary", solidHeader=TRUE,
                    title="Presentación",
                    
                    h4("Movilidad Ocupacional Intergeneracional - Uruguay"),
                    h4("Mag. José González "),
                    p("Fuente: Encuesta Longitudinal de Protección Social (ELPS)."),
                    p("Clasificación ocupacional basada en ISCO-88."),
                    
                    p("Clasificación armonizada con criterios de la OIT y el INE Uruguay.")
                )
              )
      ),
      
      ########################################################
      # MATRIZ + MARCO CONCEPTUAL (RESTURADO COMPLETO)
      ########################################################
      
      tabItem(tabName="matriz",
              
              fluidRow(
                box(width=12, title="Cuadro 5. Tabla de movilidad ocupacional (%)",
                    status="primary", solidHeader=TRUE,
                    DTOutput("tabla_mov"),
                    br(),
                    actionButton("toggle_def",
                                 "Mostrar / Ocultar Marco Conceptual",
                                 icon = icon("book"))
                )
              ),
              
              fluidRow(
                conditionalPanel(
                  condition="input.toggle_def % 2 == 1",
                  box(width=12, status="info", solidHeader=TRUE,
                      title="Marco Conceptual y Definición de Categorías",
                      
                      p("Para la construcción de la estructura ocupacional se utilizaron las variables:"),
                      tags$ul(
                        tags$li("a) Código oficio del Padre (escala cod_a16a)"),
                        tags$li("b) ¿Cuál es la tarea que realiza en este trabajo? (escala cod_e7)")
                      ),
                      
                      p("A partir de dichas variables se construyeron las siguientes sub-categorías basadas en ISCO-88:"),
                      
                      tags$ol(
                        tags$li(strong("Legisladores, oficiales, directivos y gerentes (L,o,d): "),
                                "Grupo 0 (0001–0120) y Grupo 1 (1000–1999)."),
                        tags$li(strong("Profesionales: "),
                                "Grupo 2 (2000–2999)."),
                        tags$li(strong("Técnicos: "),
                                "Grupo 3 (3000–3999)."),
                        tags$li(strong("Oficinistas: "),
                                "Grupo 4 (4000–4999)."),
                        tags$li(strong("Servicio y ventas: "),
                                "Grupo 5 (5000–5999)."),
                        tags$li(strong("6a. Patrón rural: "),
                                "Subgrupos 6129 y 6130."),
                        tags$li(strong("6b. Trabajador rural: "),
                                "Subgrupos 6000–6128 y 6131–6999."),
                        tags$li(strong("Oficiales, operarios y mecánicos: "),
                                "Grupo 7 (7000–7999)."),
                        tags$li(strong("Operadores de planta y maquinaria: "),
                                "Grupo 8 (8000–8999) y subgrupos 121–999."),
                        tags$li(strong("Trabajadores no calificados: "),
                                "Grupo 9 (9000–9999).")
                      ),
                      
                      p("Clasificación armonizada con ISCO-88 y criterios metodológicos del INE Uruguay.")
                  )
                )
              )
      ),
      
      tabItem(tabName="visual",
              fluidRow(
                box(width=12, title="Heatmap Movilidad (%)",
                    status="primary", solidHeader=TRUE,
                    plotlyOutput("heatmap", height=600))
              ),
              fluidRow(
                box(width=6, title="Gráfico Mosaico",
                    status="primary", solidHeader=TRUE,
                    plotOutput("mosaico")),
                box(width=6, title="Gráfico Asociación (Residuos Pearson)",
                    status="primary", solidHeader=TRUE,
                    plotOutput("assoc"))
              )
      ),
      
      tabItem(tabName="indicadores",
              fluidRow(
                valueBoxOutput("movTotal"),
                valueBoxOutput("inmovilidad")
              ),
              fluidRow(
                valueBoxOutput("movEstructural"),
                valueBoxOutput("movCirculatoria")
              )
      )
    )
  )
)

############################################################
# SERVER
############################################################

server <- function(input, output) {
  
  output$tabla_mov <- renderDT({
    datatable(round(matriz_mov,2),
              options=list(pageLength=10),
              caption="Fuente: Elaboración propia en base a datos de la ELPS")
  })
  
  output$heatmap <- renderPlotly({
    df <- melt(matriz_mov)
    df$Origen <- factor(df$Origen, levels=rev(categorias))
    
    p <- ggplot(df, aes(Destino, Origen, fill=value)) +
      geom_tile(color="white") +
      scale_fill_gradient(low="white", high="red") +
      labs(x="Destino", y="Origen", fill="%") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$mosaico <- renderPlot({
    mosaic(tabla, shade=TRUE, legend=TRUE)
  })
  
  output$assoc <- renderPlot({
    assoc(tabla, shade=TRUE)
  })
  
  output$movTotal <- renderValueBox({
    valueBox(round(movilidad_total,2),
             "Movilidad Total (%)",
             icon=icon("exchange-alt"),
             color="blue")
  })
  
  output$inmovilidad <- renderValueBox({
    valueBox(round(inmovilidad,2),
             "Inmovilidad (%)",
             icon=icon("lock"),
             color="red")
  })
  
  output$movEstructural <- renderValueBox({
    valueBox(round(mov_estructural,2),
             "Movilidad Estructural (%)",
             icon=icon("industry"),
             color="yellow")
  })
  
  output$movCirculatoria <- renderValueBox({
    valueBox(round(mov_circulatoria,2),
             "Movilidad Circulatoria (%)",
             icon=icon("sync"),
             color="green")
  })
}

shinyApp(ui, server)

