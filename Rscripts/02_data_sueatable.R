# Descripcion de Archivo --------------------------------------------------
## Nombre_archivo: 01_su_eatable_database  
## Versión:        01                               
## Autor:          Francisco Fernández                      
## Deacripción:    Tratamiento de información sue_eatable para su lectura en GAMS 
##
## Notas:  ** Información proviene de:
##                * https://figshare.com/articles/dataset/SU-EATABLE_LIFE_a_comprehensive_database_of_carbon_and_water_footprints_of_food_commodities/13271111?file=27921765
##
##              
##
##---

#install packages
#install.packages("writexl")

# Cargar paquetes Seccion 1 ---------------------------------------------------------
# library
library(tidyverse)   # CRAN v2.0.0 
library(lubridate)   # CRAN v1.7.10 
#library(xlsx)
library(readxl)
library(stringr)
library(writexl)

##%######################################################%##
#                                                          #
#                 Seccion 1: Data Treatment                        ####
#                                                          #
##%######################################################%##

## Cap 1.1 : Importar datos ==================================================

sueatable_data_raw <- read_xlsx("data_raw/SuEatableLife_Food_Fooprint_database.xlsx", sheet = 2) |> 
  filter(`FOOD COMMODITY GROUP` == "CROPS" | `FOOD COMMODITY GROUP` == "ANIMAL HUSBANDRY" )
