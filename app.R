#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

require(shiny)
require(tidyverse)
require(ggparliament)
require(electoral)
require(readxl)
require(DT)
require(shinythemes)
require(showtext)
require(scales)

font_add_google(name = "Source Sans Pro", family = "Source Sans Pro",
                regular.wt = 300, bold.wt = 700)
showtext_auto()
showtext_opts(dpi = 160)

provincias <- read_csv("data/data.csv")

# Creo objetos con los promedios de las encuestas para cada partido para introducir en los valores iniciales del app
PP.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "PP"])
PSOE.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "PSOE"])
UP.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "UP"])
Cs.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "C's"])
VOX.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "VOX"])
ERC.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "ERC-CATSÍ"])
CDC.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "CDC"])
PNV.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "EAJ-PNV"])
Bildu.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "EH.Bildu"])
CC.mean <- unique(provincias$promedio.encuestas[provincias$siglas == "CCa-PNC"])


# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("cosmo"),
   
   # Application title
   titlePanel("Simulación reparto escaños"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(

     sidebarPanel(
       HTML("<p style='text-align:justify'>Este simulador permite hacer un pronóstico de reparto de escaños en función de un resultado sobre voto 
            válido introducido por el usuario. Los valores iniciales corresponden a la media que a día de hoy dan las 
            encuestas a cada partido según <a href = 'https://elpais.com/politica/2019/02/13/actualidad/1550063083_680240.html'>Kiko Llaneras</a>.</p>"), 
        HTML("<p style='text-align:justify'>Los votos de cada partido* a nivel nacional se distribuyen a nivel provincial según 
            las variaciones de los resultados de cada uno de ellos respecto a su media nacional en las elecciones generales de 2016.</p>"),
       HTML("<p style='text-align:justify'>La asignación de escaños a las provincias está actualizada en base a las informaciones confirmadas por el 
            <a href = 'https://www.europapress.es/asturias/noticia-bajada-poblacion-asturias-reduce-representacion-congreso-diputados-proximas-generales-20190220102710.html'>
            Ministerio del Interior</a> según las cuales Asturias y Valencia pierden un diputado a costa de Madrid y Barcelona.</p>"),
        HTML("<p style='text-align:justify'>* Al ser un fenómeno nuevo y no tener resultados anteriores en algunas provincias, se ha realizado 
              un tratamiento especial para Vox en base a las transferencias de voto de las encuestas (sabemos que aproximadamente el 60% de su voto viene 
              del PP, el 18% de C's, el 4% de Podemos, el 3% del PSOE y el 15% de la abstención). Se asume que estas transferencias son iguales en todas las provincias.</p>"),
       
       sliderInput("PP",
                   "Partido Popular:",
                   round = -1, step = 0.1, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 25.82,
                   value = PP.mean),
       sliderInput("PSOE",
                   "Partido Socialista:", 
                   round = -1, step = 0.1, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 29.52,
                   value = PSOE.mean),
       sliderInput("UP",
                   "Unidos Podemos:",
                   round = -1, step = 0.1, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 20.12,
                   value = UP.mean),
       sliderInput("Cs",
                   "Ciudadanos:",
                   round = -1, step = 0.1, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 23.12,
                   value = Cs.mean),
       sliderInput("Vox",
                   "Vox:",
                   round = -1, step = 0.1, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 15.72,
                   value = VOX.mean),
       sliderInput("ERC",
                   "ERC:",
                   round = -2, step = 0.01, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 7.48,
                   value = ERC.mean),
       sliderInput("CDC",
                   "CDC:",
                   round = -2, step = 0.01, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 6.64,
                   value = CDC.mean),
       sliderInput("PNV",
                   "PNV:",
                   round = -2, step = 0.01, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 6.26,
                   value = PNV.mean),
       sliderInput("Bildu",
                   "EH Bildu:",
                   round = -2, step = 0.01, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 5.95,
                   value = Bildu.mean),
       sliderInput("CC",
                   "Coalición Canaria:",
                   round = -2, step = 0.01, sep = "" , post = "%", ticks = FALSE,
                   min = 0,
                   max = 5.45,
                   value = CC.mean),
       HTML("<p>Creado por <a href='https://hmeleiro.github.io/'>Héctor Meleiro</a></p>"),
       HTML("<p><a href='https://github.com/hmeleiro/SeatSimulator'>Show me the code</a></p>")
     ),
     
     # Show a plot of the generated distribution
     mainPanel(
       tabsetPanel(
         tabPanel("Nacional", 
                  verticalLayout(h3("Reparto de escaños a nivel nacional"),
                                 plotOutput("congreso", height = "500px"),
                                 splitLayout(
                                   dataTableOutput("seats"),
                                   dataTableOutput("bloques")))),
         tabPanel("CCAA", 
                  h3("Reparto de escaños por comunidades autónomas"),
                  dataTableOutput("ccaa")),
         tabPanel("Provincias", 
                  h3("Reparto de escaños por provincias"),
                  plotOutput("stepplot", height = "500px"),
                  dataTableOutput("provincias")))
     )
   )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observe(updateSliderInput(session, "PP",  max = 100 - (input$PSOE + input$UP + input$Cs + input$Vox + input$ERC + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "PSOE", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$ERC + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "UP", max = 100 - (input$PP + input$PSOE + input$Cs + input$Vox + input$ERC + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "Cs", max = 100 - (input$PP + input$UP + input$PSOE + input$Vox + input$ERC + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "Vox", max = 100 - (input$PP + input$UP + input$Cs + input$PSOE + input$ERC + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "ERC", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$PSOE + input$CDC + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "CDC", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$ERC + input$PSOE + input$PNV + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "PNV", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$ERC + input$CDC + input$PSOE + input$Bildu + input$CC)))
  observe(updateSliderInput(session, "Bildu", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$ERC + input$CDC + input$PNV + input$PSOE + input$CC)))
  observe(updateSliderInput(session, "CC", max = 100 - (input$PP + input$UP + input$Cs + input$Vox + input$ERC + input$CDC + input$PNV + input$Bildu + input$PSOE)))
   
  ###############################
  ### GRÁFICO PARLAMENTO ###
  ###############################
  output$congreso <- renderPlot({
    
    
    # Creo un array con los inputs
    media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                         "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
    
    # Creo un array con los ids de los partidos 
    parties <- unique(provincias$siglas)
    
    provincias$sobrevalido2019 <- NA
    
    for (p in parties) {
      
      provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
      
      
    }
    
    
    ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
    
    results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
    provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
    
    for (p in provs) {
      
      x <- provincias[provincias$Código.de.Provincia == p,]
      
      parties <- x$siglas # Crea un objeto con los partidos en la provincia p
      votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
      escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
      prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
      
      votos[votos < 3] <- 0
      
      d <- seats_ha(parties = parties, 
                    votes = votos, 
                    n_seats = escaños,
                    method = "dhondt")
      
      data <- tibble(cod.prov = p,
                     provincia = prov,
                     Party = names(d),
                     Seats = as.numeric(d))
      
      
      # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
      # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
      results <- rbind(results, data) 
    }
    
    results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
    
    # AGREGACION DE RESULTADOS

    nacional_results <- results %>% group_by(Party) %>% summarise(seats = sum(Seats)) %>% arrange(-seats) # A nivel nacional (escaños)
    

    ## GRAFICO DEL PARLAMENTO 
    
    ### Creo una variable para ordenar el gráfico
    nacional_results$order <- NA
    nacional_results$order[nacional_results$Party == "PSOE"] <- 1
    nacional_results$order[nacional_results$Party == "UP"] <- 2
    nacional_results$order[nacional_results$Party == "ERC-CATSÍ"] <- 3
    nacional_results$order[nacional_results$Party == "CDC"] <- 4
    nacional_results$order[nacional_results$Party == "EAJ-PNV"] <- 5
    nacional_results$order[nacional_results$Party == "EH.Bildu"] <- 6
    nacional_results$order[nacional_results$Party == "CCa-PNC"] <- 7
    nacional_results$order[nacional_results$Party == "C's"] <- 8
    nacional_results$order[nacional_results$Party == "VOX"] <- 9
    nacional_results$order[nacional_results$Party == "PP"] <- 10
    
    
    color <- c("#EF1C25", "#612d62", "#C10F19", "#4388bc", "#00914A", 
               "#B1CE00", "#FFDD02", "#FB5000", "#66bc29", "#03A2DD") # Creo un array con los colores
    
    # Asigno los colores a los partidos
    nacional_results$color <- NA
    nacional_results$color[nacional_results$Party == "PSOE"] <- color[1]
    nacional_results$color[nacional_results$Party == "UP"] <- color[2]
    nacional_results$color[nacional_results$Party == "ERC-CATSÍ"] <- color[3]
    nacional_results$color[nacional_results$Party == "CDC"] <- color[4]
    nacional_results$color[nacional_results$Party == "EAJ-PNV"] <- color[5]
    nacional_results$color[nacional_results$Party == "EH.Bildu"] <- color[6]
    nacional_results$color[nacional_results$Party == "CCa-PNC"] <- color[7]
    nacional_results$color[nacional_results$Party == "C's"] <- color[8]
    nacional_results$color[nacional_results$Party == "VOX"] <- color[9]
    nacional_results$color[nacional_results$Party == "PP"] <- color[10]
    
    
    nacional_results <- nacional_results %>% arrange(order)
    
    
    congreso <- parliament_data(election_data = nacional_results,
                                type = "semicircle",
                                parl_rows = 8,
                                party_seats = nacional_results$seats)
    
    
    representatives <- ggplot(congreso, aes(x, y, colour = Party)) +
      geom_parliament_seats(size = 5) +
      draw_majoritythreshold(n = 175, label = F, type = 'semicircle') +
      theme_ggparliament() + theme(text = element_text(family = "Source Sans Pro"), 
                                   legend.text = element_text(size = 12)) +
      labs(colour = NULL) +
      scale_colour_manual(values = congreso$color, limits = congreso$Party)
    
    representatives

    
    
  })
  

  
  ###############################
  ### TABLA MAYORÍAS BLOQUES ###
  ###############################
  output$bloques <- renderDataTable({
    
    
    # Creo un array con los inputs
    media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                         "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
    
    # Creo un array con los ids de los partidos 
    parties <- unique(provincias$siglas)
    
    provincias$sobrevalido2019 <- NA
    
    for (p in parties) {
      
      provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
      
      
    }
    
    
    ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
    
    results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
    provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
    
    for (p in provs) {
      
      x <- provincias[provincias$Código.de.Provincia == p,]
      
      parties <- x$siglas # Crea un objeto con los partidos en la provincia p
      votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
      escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
      prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
      
      votos[votos < 3] <- 0
      
      d <- seats_ha(parties = parties, 
                    votes = votos, 
                    n_seats = escaños,
                    method = "dhondt")
      
      data <- tibble(cod.prov = p,
                     provincia = prov,
                     Party = names(d),
                     Seats = as.numeric(d))
      
      
      # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
      # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
      results <- rbind(results, data) 
    }
    
    results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
    
    
    # AGREGACION DE RESULTADOS
    
    provs <- provincias[, c(2,3,4)] 
    provs <- provs[!duplicated(provs$Código.de.Provincia),]
    
    results <- merge(results, provs, by.x = "cod.prov", by.y = "Código.de.Provincia")
    
    ccaa <- results %>% group_by(Nombre.de.Comunidad, Party) %>% summarise(seats = sum(Seats))
    
    
    ccaa_results <- spread(ccaa, "Party", "seats") # A nivel de CCA (escaños)
    prov_results <- spread(results, key = "Party", value = "Seats") # A nivel de provincia (escaños)
    nacional_results <- results %>% group_by(Party) %>% summarise(seats = sum(Seats)) %>% arrange(-seats) # A nivel nacional (escaños)
    
    # Imprimo los resultados
    nacional_results
    ccaa_results
    prov_results
    
    out <- nacional_results
    
    PP <- out$seats[out$Party == "PP"]
    PSOE <- out$seats[out$Party == "PSOE"]
    UP <- out$seats[out$Party == "UP"]
    Cs <- out$seats[out$Party == "C's"]
    VOX <- out$seats[out$Party == "VOX"]
    PNV <- out$seats[out$Party == "EAJ-PNV"]
    
    PSOEUP <- PSOE + UP
    PPCsVOX <- PP + Cs + VOX
    PSOECs <- PSOE + Cs
    PSOEUPPNV <- PSOE + UP + PNV
    
    gobs <- c("PSOE + UP", "PP + C's + Vox", "PSOE + C's", "PSOE + UP + PNV")
    gobseats <- c(PSOEUP, PPCsVOX, PSOECs, PSOEUPPNV)
    
    out <- tibble("Posibles acuerdos" = gobs,
                "Escaños" = gobseats) %>% arrange(-`Escaños`)
    
    out$MA <- NA
    out$MA[out$`Escaños` > 175] <- "Sí"
    out$MA[out$`Escaños` <= 175] <- "No"
    
    
    datatable(data = out, options = list(sDom  = '<"top">rt<"bottom">', pageLength = 20), 
              rownames = FALSE, style = "bootstrap", 
              fillContainer = F, height = 1000, colnames = c("", "Escaños", "Mayoría absoluta")) %>% formatStyle(names(out)[2],
                                                                                                                 background = styleColorBar(range(out[, 2]), 'lightblue'),
                                                                                                                 backgroundSize = '98% 88%',
                                                                                                                 backgroundRepeat = 'no-repeat',
                                                                                                                 backgroundPosition = 'center')

    
  })
  
  
  ###########################################
  ### TABLA DE ESCAÑOS Y VOTOS NACIONALES ###
  ###########################################
   output$seats <- renderDataTable({
     
     
     # Creo un array con los inputs
     media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                          "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
     
     # Creo un array con los ids de los partidos 
     parties <- unique(provincias$siglas)
     
     provincias$sobrevalido2019 <- NA
     
     for (p in parties) {
       
       provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
       
       
     }
     
     
     ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
     
     results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
     provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
     
     for (p in provs) {
       
       x <- provincias[provincias$Código.de.Provincia == p,]
       
       parties <- x$siglas # Crea un objeto con los partidos en la provincia p
       votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
       escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
       prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
       
       votos[votos < 3] <- 0
       
       d <- seats_ha(parties = parties, 
                     votes = votos, 
                     n_seats = escaños,
                     method = "dhondt")
       
       data <- tibble(cod.prov = p,
                      provincia = prov,
                      Party = names(d),
                      Seats = as.numeric(d))
       
       
       # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
       # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
       results <- rbind(results, data) 
     }
     
     results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
     
     
     # AGREGACION DE RESULTADOS
     
     #results <- as_tibble(data_tot[, c(1,2,4)]) 
     
     provs <- provincias[, c(2,3,4)] 
     provs <- provs[!duplicated(provs$Código.de.Provincia),]
     
     results <- merge(results, provs, by.x = "cod.prov", by.y = "Código.de.Provincia")

     nacional_results <- results %>% group_by(Party) %>% summarise(seats = sum(Seats)) %>% arrange(-seats) # A nivel nacional (escaños)
     
     # Imprimo los resultados

     out <- nacional_results
     
     datatable(data = out, options = list(sDom  = '<"top">rt<"bottom">'), 
                   rownames = FALSE, style = "bootstrap", 
                   fillContainer = F, height = 1000, width = 200, 
               colnames = c("Partido", "Escaños")) %>% formatStyle(names(out)[2],
                                                                   background = styleColorBar(range(out[, 2]), 'lightblue'),
                                                                   backgroundSize = '98% 88%',
                                                                   backgroundRepeat = 'no-repeat',
                                                                   backgroundPosition = 'center')
    
     
   }, server = T)
   
   output$ccaa <- renderDataTable({
     
     
     # Creo un array con los inputs
     media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                          "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
     
     # Creo un array con los ids de los partidos 
     parties <- unique(provincias$siglas)
     
     provincias$sobrevalido2019 <- NA
     
     for (p in parties) {
       
       provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
       
       
     }
     
     
     ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
     
     results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
     provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
     
     for (p in provs) {
       
       x <- provincias[provincias$Código.de.Provincia == p,]
       
       parties <- x$siglas # Crea un objeto con los partidos en la provincia p
       votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
       escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
       prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
       
       votos[votos < 3] <- 0
       
       d <- seats_ha(parties = parties, 
                     votes = votos, 
                     n_seats = escaños,
                     method = "dhondt")
       
       data <- tibble(cod.prov = p,
                      provincia = prov,
                      Party = names(d),
                      Seats = as.numeric(d))
       
       
       # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
       # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
       results <- rbind(results, data) 
     }
     
     results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
     
     
     # AGREGACION DE RESULTADOS
     
     #results <- as_tibble(data_tot[, c(1,2,4)]) 
     
     provs <- provincias[, c(2,3,4)] 
     provs <- provs[!duplicated(provs$Código.de.Provincia),]
     
     results <- merge(results, provs, by.x = "cod.prov", by.y = "Código.de.Provincia")
     
     ccaa <- results %>% group_by(Nombre.de.Comunidad, Party) %>% summarise(seats = sum(Seats))
    
     ccaa_results <- spread(ccaa, "Party", "seats") # A nivel de CCA (escaños)

     ccaa_results <- ccaa_results[, c(1,8,9,10,2,11,7,4,5,6,3)]

     datatable(data = ccaa_results, options = list(sDom  = '<"top">rt<"bottom">', pageLength = 20), 
               rownames = FALSE, style = "bootstrap", 
               fillContainer = FALSE, height = 400, width = 400, colnames = c("CCAA", "PP", "PSOE", "Unidos Podemos", "Ciudadanos", 
                                                                              "Vox", "ERC", "CDC", "PNV", "EH Bildu", "CC"))
     
   }, server = T)
   
   #################
   ### STEP PLOT ###
   #################
   output$stepplot <- renderPlot({
     
     
     
     # Creo un array con los inputs
     media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                          "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
     
     # Creo un array con los ids de los partidos 
     parties <- unique(provincias$siglas)
     
     provincias$sobrevalido2019 <- NA
     
     for (p in parties) {
       
       provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
       
       
     }
     
     
     ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
     
     results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
     provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
     
     for (p in provs) {
       
       x <- provincias[provincias$Código.de.Provincia == p,]
       
       parties <- x$siglas # Crea un objeto con los partidos en la provincia p
       votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
       escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
       prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
       
       votos[votos < 3] <- 0
       
       d <- seats_ha(parties = parties, 
                     votes = votos, 
                     n_seats = escaños,
                     method = "dhondt")
       
       data <- tibble(cod.prov = p,
                      provincia = prov,
                      Party = names(d),
                      Seats = as.numeric(d))
       
       
       # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
       # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
       results <- rbind(results, data) 
     }
     
     results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
     
     
     # AGREGACION DE RESULTADOS
     
     provs <- provincias[, c(2,3,4)] 
     provs <- provs[!duplicated(provs$Código.de.Provincia),]
     
     results <- merge(results, provs, by.x = "cod.prov", by.y = "Código.de.Provincia")
     
     
     seatprovs <- provincias[, c("Código.de.Provincia", "seats")]
     print(seatprovs)
     print(results)
     
     x <- merge(results, seatprovs, by.x = "cod.prov", by.y = "Código.de.Provincia")
     
     x$seats_pct <- x$Seats / x$seats
     
     x <- x[x$Party %in% c("PP", "PSOE", "C's", "UP", "VOX"),]
     
     x$Party <- factor(x$Party, levels = c("PSOE", "PP", "C's", "UP", "VOX"))
     
     colores <- c("#EF1C25", "#03A2DD", "#FB5000", "#612d62", "#66bc29")
     
     x %>% ggplot(aes(x = seats, y = seats_pct)) + 
       geom_step(aes(color = Party), show.legend = F, size = 1) + 
       scale_color_manual(values = colores) + 
       scale_y_continuous(minor_breaks = F, labels = percent, breaks = c(0, 0.5, 1)) + 
       scale_x_log10(minor_breaks = F, limits = c(1, 37), breaks = c(1,5,37), labels = c("Ceuta\ny Melilla", "Jaén,\nNavarra,\nCantabria,\netc...", "Madrid")) +
       facet_wrap(~Party) +
       labs(x = "\nNúmero de escaños de la provincia",
            y = "% de escaños conseguidos\n",
            color = NULL,
            subtitle = "Ceuta y Melilla reparten 1 escaño cada una, Jaén, Navarra y Cantabria 5 y Madrid 37.",
            title = "Las provincias pequeñas para los partidos grandes") +
       theme_minimal(base_family = "Source Sans Pro", base_size = 11) + 
       theme(plot.title = element_text(face = "bold"), 
             strip.text = element_text(face = "bold"), 
             panel.spacing.x = unit(1.5, "lines"), 
             plot.margin = unit(c(1,1,1,1), "lines"))

   })
   
   #######################
   ### TABLA PROVINCIAS ###
   #######################
   output$provincias <- renderDataTable({
     
     
     # Creo un array con los inputs
     media.encuestas <- c(PP = input$PP, PSOE = input$PSOE, UP = input$UP, "C's" =  input$Cs, VOX = input$Vox, 
                          "ERC-CATSÍ" = input$ERC, CDC = input$CDC, "EAJ-PNV" = input$PNV, "EH.Bildu" = input$Bildu, "CCa-PNC" = input$CC)
     
     # Creo un array con los ids de los partidos 
     parties <- unique(provincias$siglas)
     
     provincias$sobrevalido2019 <- NA
     
     for (p in parties) {
       
       provincias$sobrevalido2019[provincias$siglas == p] <- provincias$swingfactor[provincias$siglas == p] * media.encuestas[names(media.encuestas) == p]
       
       
     }
     
     
     ## UNA VEZ QUE TENEMOS EL NÚMERO DE VOTOS POR PROVINCIAS DE CADA PARTIDO ITERAMOS POR CADA PROVINCIA PARA HACER EL REPARTO DE ESCAÑOS
     
     results <- NA # Creo in data frame vacío en el que voy a ir acumulando los resultados de cada provincia
     provs <- unique(provincias$Código.de.Provincia) # Creo un array con los códigos de las provincias para que itere por ellos el bucle
     
     for (p in provs) {
       
       x <- provincias[provincias$Código.de.Provincia == p,]
       
       parties <- x$siglas # Crea un objeto con los partidos en la provincia p
       votos <- x$sobrevalido2019 # Crea un objeto con los votos a los partidos de la provincia p
       escaños <- unique(x$seats) # Crea un objeto con el número de escaños a repartir en la provincia p
       prov <- unique(x$Nombre.de.Provincia) # Crea un objeto con el nombre de la provincia p
       
       votos[votos < 3] <- 0
       
       d <- seats_ha(parties = parties, 
                     votes = votos, 
                     n_seats = escaños,
                     method = "dhondt")
       
       data <- tibble(cod.prov = p,
                      provincia = prov,
                      Party = names(d),
                      Seats = as.numeric(d))
       
       
       # Unimos el resultado con el data frame vacío que hemos creado al principio, pero la segunda 
       # y sucesivas veces que itere el bucle ya no estará vacío, sino que irá acumulando cada una de las provincias
       results <- rbind(results, data) 
     }
     
     results <- results[-1,] # Le quitamos la primera fila al data frame acumulado porque al crear el objeto vacía hay una linea con NAs
     
     
     # AGREGACION DE RESULTADOS
     
     provs <- provincias[, c(2,3,4)] 
     provs <- provs[!duplicated(provs$Código.de.Provincia),]
     
     results <- merge(results, provs, by.x = "cod.prov", by.y = "Código.de.Provincia")
     
     prov_results <- spread(results, key = "Party", value = "Seats") # A nivel de provincia (escaños)
     prov_results <- prov_results[, c(3,1,11,12,13,5,14,10,7,8,9,6)]
     
     datatable(data = prov_results, options = list(sDom  = '<"top">rt<"bottom">', pageLength = 53), 
               rownames = FALSE, style = "bootstrap",
               fillContainer = FALSE, height = 400, width = 400, colnames = c("CCAA", "Provincia", "PP", "PSOE", "Unidos Podemos", "Ciudadanos", 
                                                                              "Vox", "ERC", "CDC", "PNV", "EH Bildu", "CC"))
     
   }, server = T)
   
}

# Run the application 
shinyApp(ui = ui, server = server)

