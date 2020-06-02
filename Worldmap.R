
library(geojsonio)
library(leaflet)
library(leaflet.extras)

# you gave me a spreadsheet
library(readxl)

library(readxl)
coronavirus_19<- read_excel("~/Downloads/Rstudio/melon 20th May/coronavirus 19th May.xlsx", 
                                   col_types = c("text", "numeric"))



# import the geojson as sp (spacial format - allows us to work with leaflet)
world_map <- geojson_read("https://opendata.arcgis.com/datasets/a21fdb46d23e4ef896f31475217cbb08_1.geojson", what = "sp")

# tigris has the handy geo_join
library(tigris)
library(dplyr)


# join our datasets - tell it the two files and then the two columns to join by
world_data <- geo_join(world_map, coronavirus_19, "CNTRY_NAME", "map_names")

#test a simple map to see if our shapes work
leaflet(world_data) %>%
  addTiles() %>%
  addPolygons()

# use old-school R (base R) to get rid of the NAs (subset to give us anything not an NA)
world_data <- subset(world_data, !is.na(total.cases))

# testing a text popup
hovertext <- paste0("Total cases: ", as.character(world_data$total.cases), " in ",as.character(world_data$CNTRY_NAME))
# set the colour palette - google this you can do so much better
pal <- colorNumeric("Reds", domain = world_data$total.cases)
# test our map to see if it works
wolrdcase <-leaflet(options = leafletOptions(minZoom = 1,maxZoom = 4,dragging = TRUE)) %>%
            addTiles() %>%  clearBounds() %>%
            addPolygons(data = world_data, fillColor = ~pal(world_data$total.cases), 
               fillOpacity = 0.8, 
               weight = 0.3, 
               smoothFactor = 0.2, 
               label = ~hovertext) %>% addSearchOSM()
       
   
wolrdcase %>% addLegend(pal = pal,
          opacity = 0.75,values = c(10000:300000),
          title = "Total Cases",
          position = "topleft") 
