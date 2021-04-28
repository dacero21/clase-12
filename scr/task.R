#==============================================================================#
# Autor:
# Creacion: 19-03-2021
# Ultima modificacion: 19-03-2021
# Version de R: 4.0.3
#==============================================================================#

# configuracion inicial
rm(list = ls())
library(pacman)
pacman::p_load(here,tidyverse,sf,maps,viridis,ggsn,raster,lwgeom)

# Usando la capa de victimas map-muse, responda a la pregunta:
cat("Distancias a centros poblados, rios y/o vias afectan la probabilidad de ser una victima fatal?")

# 1. cargar bases de datos
mapmuse = readRDS(here("data/input/victimas_map-muse.rds"))

vias = st_read(here("data/input/VIAS.shp"))

infraestructura = st_read(here("data/input/MGN_URB_TOPONIMIA.shp")) %>%
                  subset(cod_vereda)

c_poblado = here("data/input/c_poblado.rds") %>%
            subset()

# 2. Visualizar informacion


# 3. calcular distancias


# 4. agregar informacion de otras capas


# 5. estimar probabilidad
