#==============================================================================#
# Autor(es): Eduard Martinez
# Colaboradores: 
# Fecha creacion: 10/08/2019
# Fecha modificacion: 28/04/2021
# Version de R: 4.0.3.
#==============================================================================#

# intial configuration
rm(list = ls()) # limpia el entorno de R
pacman::p_load(tidyverse,sf,raster,ggmap,ggsn,ggnewscale,viridis,RColorBrewer,scales) # cargar y/o instalar paquetes a usar

#------------------#
# 1. Mapas basicos #
#------------------#

#### 1.1. Cargar shapefiles
browseURL(url = "https://geoportal.dane.gov.co/servicios/descarga-y-metadatos/descarga-mgn-marco-geoestadistico-nacional/", browser = getOption("browser")) # Fuente: MGN 

quilla = st_read(dsn = 'data/input/neigh_barranquilla.shp')

points_quilla = st_read(dsn = 'data/inputpoints_barranquilla.shp') %>%
                subset(MPIO_CCDGO=='08001')
cai_quilla = subset(points_quilla,CSIMBOL %in% c('020202','020204'))

#### 1.2. Pintar capas
ggplot() + geom_sf(data = cai_quilla,colour = "red" ,size = 1, alpha = 0.5) # Puntos
ggplot() + geom_sf(data = quilla, colour = "red" , fill = "blue" , size = 0.3, alpha = 0.5) # Poligonos

#### 1.3. Agregar titulos, labels y tema
p = ggplot() + geom_sf(data = quilla, colour = "red", fill = "blue" , size = 0.5, alpha = 0.5) + 
    ggtitle("Barranquilla") + xlab('') + ylab('') + theme_bw()
p

#### 1.4. Agregar estrella del norte
p + ggsn::north(data = quilla , location = "topleft",symbol = 5)

p = p + ggsn::north(data = quilla , location = "topright",symbol = 1) # Otro simbolo
p

#### 1.5. Agregar barra de escalas
p + ggsn::scalebar(data = quilla, dist = 3, dist_unit = "km",transform = F, model = "WGS84",location = "bottomleft") 

p = p + ggsn::scalebar(data = quilla, dist = 3, dist_unit = "km",transform = F, model = "WGS84",location = "bottomleft") 
p

#### 1.6. Agregar labels
p + geom_sf_text(data = quilla,aes(label=Nombre_Bar),col='black',size=1) 

p = p + geom_sf_text(data = quilla,aes(label=Nombre_Bar),col='black',size=1) 
p

#### 1.7. Exportar un mapa
ggsave(plot = p, filename = 'views/Barranquilla.png',width = 7,height = 7)
ggsave(plot = p, filename = 'views/Barranquilla.pdf',width = 7,height = 7)
rm(p)

#--------------------#
# 2. Mapas tematicos #
#--------------------#

#### 2.1. Cargar shapefiles y bases de datos

#### 2.1.1. Unidades de Planeamiento Zonal
browseURL(url = "https://datosabiertos.bogota.gov.co/dataset/unidad-de-planeamiento-bogota-d-c", browser = getOption("browser")) # Fuente 
upz <- st_read(dsn = "data/input/UPZ.shp") %>% 
       subset(as.character(.$UPlTipo)=="1") %>% 
       mutate(cod_upz = gsub('UPZ','',UPlCodigo) %>% as.numeric()) %>% dplyr::select(cod_upz)

ggplot() + geom_sf(data = upz, colour = "red",size = 1, alpha = 0.5) + # UPZ
geom_sf_text(data = upz,aes(label=cod_upz),size=1)

#### 2.1.2. Casos confirmados COVID-19 en Bogota
browseURL(url = "http://saludata.saludcapital.gov.co/osb/index.php/datos-de-salud/enfermedades-trasmisibles/covid19/", browser = getOption("browser")) # Fuente 
casos_upz = readRDS(file = 'data/original/Casos por UPZ.rds')
casos_upz


#### 2.2. Casos confirmados por UPZ

#### 2.2.1. Agregar informacion al SF
upz = merge(upz,casos_upz,by='cod_upz',all.x=T)

#### 2.2.2. Pintar mapa
ggplot() + geom_sf(data = upz , color = 'red' , aes(fill=casos_09))

#### 2.2.3. Modificar escala de colores
browseURL(url = "https://ggplot2.tidyverse.org/reference/scale_gradient.html", browser = getOption("browser")) # Paletas de viridis

#### 2.2.3.1. Usando gradiente
ggplot() + geom_sf(data = upz , color = 'black' , size = 0.5 , aes(fill=casos_09)) + 
scale_fill_gradient(name="Casos",na.value = "gray",low="bisque", high="brown") 

#### 2.2.3.2. Usando Paletas de colores
browseURL(url = "https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html", browser = getOption("browser")) # Paletas de viridis
browseURL(url = "https://www.r-graph-gallery.com/38-rcolorbrewers-palettes.html", browser = getOption("browser")) # Paletas de Rcolorbrewers

# Viridis
ggplot() + geom_sf(data = upz , color = 'black' , size = 0.5 , aes(fill=casos_09)) + 
scale_fill_viridis(name="Casos",na.value = "gray",direction = 1) 

ggplot() + geom_sf(data = upz , color = 'gray' , size = 0.5 ,aes(fill=casos_09)) + 
scale_fill_viridis(name="Casos",na.value = "white",direction = 1,option = 'magma') 

# Rcolorbrewers
ggplot() + geom_sf(data = upz , color = 'gray' , size = 0.5 ,aes(fill=casos_09)) + 
scale_fill_distiller(name = "Casos", palette = "Reds",direction = 1, breaks = scales::pretty_breaks(n = 5)) 

ggplot() + geom_sf(data = upz , color = 'gray' , size = 0.5 ,aes(fill=casos_09)) + 
scale_fill_distiller(name = "Casos", palette = "YlOrRd",direction = 1, breaks = scales::pretty_breaks(n = 5)) 

#### 2.3. Agregar detalles al mapa
ggplot() + geom_sf(data = upz , color = 'gray' , size = 0.5 ,aes(fill=casos_09)) + 
scale_fill_viridis(name="Casos",na.value = "white",direction = 1,option = 'inferno') +
ggsn::north(data = upz , location = "topleft") + 
ggsn::scalebar(data = upz, dist = 5, dist_unit = "km",transform = T, model = "WGS84",location = "bottomleft") +
ggtitle('Casos de Covid-19 por UPZ en septiembre') + xlab('') + ylab('') +
theme_bw()
ggsave(filename = 'views/Casos por UPZ.png',width = 5,height = 7)

#------------------------------------#
# 3. Mapas con varias capas a la vez #
#------------------------------------#

#### 3.1. Cargar datos
ips_quilla = subset(points_quilla,CSIMBOL %in% c('021001','021002','021003','021004'))
educ_quilla = subset(points_quilla,CSIMBOL %in% c('020901','020902','020903'))

#### 3.2. Varias capas en un mapa
ggplot() + 
geom_sf(data = quilla, colour = "black", fill = 'white' , size = 0.5, alpha = 1) + 
geom_sf(data = ips_quilla, colour = "blue",size = 2, shape=2) +
geom_sf(data = educ_quilla, colour = "green",size = 2, shape=3) 
  
#### 3.3. Agregar leyendas
p = ggplot() + 
    geom_sf(data = quilla, aes(colour = "barrios"), fill = 'white' , size = 0.5, alpha = 0.5) + 
    scale_color_manual('Poligonos',values = c('barrios'='black'), labels=c('Barrios')) +
    new_scale("color") +
    geom_sf(data = ips_quilla, aes(colour = "ips"),size = 2, shape=1) + 
    geom_sf(data = cai_quilla, aes(colour = "cai"),size = 2, shape=1) +
    geom_sf(data = educ_quilla, aes(colour = "educ"),size = 2, shape=1) +
    scale_color_manual('Puntos',values = c('ips'='blue','educ'='green','cai'='red'), 
                                   labels=c('CAI','C. Educacioon','IPS'))
p

#### 2.4. Agregar detalles al mapa
p + ggsn::north(data = quilla , location = "topleft") + 
    ggsn::scalebar(data = quilla, dist = 3, dist_unit = "km",transform = F, model = "WGS84",location = "bottomleft") +
    xlab('') + ylab('') + theme_bw()
ggsave(filename = 'views/Barranquilla servicios puublicos.png',width = 10,height = 9)

#--------------------------#
# 4. Otras visualizaciones #
#--------------------------#

#### 4.1. Obtener informacion de Google Maps o Open Streetmaps
browseURL(url = "https://ggplot2tutor.com/streetmaps/streetmaps/", browser = getOption("browser")) # Open Streetmaps
browseURL(url = "https://developers.google.com/maps/documentation/geocoding/get-api-key?hl=es", browser = getOption("browser")) # Get API key
browseURL(url = "https://github.com/eduard-martinez/geocode-addresses", browser = getOption("browser")) # Geocode direcciones usando Google Maps

#### 4.2. Mapas usando imagenes satelitales
register_google(key = "AIzaSyB3Kf6_KFwUbRWBTnvOK75CCSrfmVc9rSQ")
get_map(location = 'Barranquilla',maptype = 'satellite',zoom = 12) %>% ggmap()
get_map(location = 'Barranquilla',maptype = 'satellite',zoom = 14) %>% ggmap()

#### 4.3. Agregar otras capas

#### 4.3.1. Crear objeto con imagen
satelite = get_map(location = 'Barranquilla',maptype = 'satellite',zoom = 14) %>% ggmap()

#### 4.3.2. Cargar capas
restric = st_read('data/input/restric_man.shp') 
restric = st_transform(restric,crs = 4326)

#### 4.3.3. PLot mapa 
satelite + geom_sf(data = restric,color='red',fill=NA,size=0.5,inherit.aes = FALSE)

#### 4.4. Agregar detalles al mapa

#### 4.4.1. Cargar capas
bandas =readRDS('data/input/bandas.rds') 
bandas = st_transform(bandas,crs = 4326)

#### 4.4.2. PLot mapa 
p = satelite + 
    geom_sf(data = restric,aes(color='restric'),fill=NA,size=0.5,inherit.aes = FALSE) +
    scale_color_manual('Limite',values = c('restric'='red'),labels=c('Restriccion')) +
    geom_sf(data = bandas,color=NA,aes(fill=dummy),alpha=0.2,inherit.aes = FALSE) +
    scale_fill_manual('Zonas',labels = c("Tratamiento","Excluida","Spillover","Control"),
                              values = c("darkgreen","yellow","darkblue","darkorange")) + theme_bw() + xlab('') + ylab('')
p
ggsave(plot = p, filename = 'views/Restriccion Barranquilla.png',width = 10,height = 8)

