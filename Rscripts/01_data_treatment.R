
# Descripcion de Archivo --------------------------------------------------
## Nombre_archivo: 01_data_treatment       
## Versión:        01                               
## Autor:          Francisco Fernández                      
## Deacripción:    Tratamiento de información Pre-tratada para obtener un formato adecuado para                            su lectura en GAMS 
## Notas:  **      
##         **      
##
##---

#install packages

# Cargar paquetes Seccion 1 ---------------------------------------------------------
# library
library(tidyverse)   # CRAN v2.0.0 
library(lubridate)   # CRAN v1.7.10 
library(xlsx)
library(readxl)
library(stringr)


##%######################################################%##
#                                                          #
#                 Seccion 1: EDA                        ####
#                                                          #
##%######################################################%##


## Cap 1.1 : Importar datos ==================================================

data_raw <- read.xlsx("data_raw/bd_final.xlsx", sheetIndex = 1)

## Cap 1.2: Tratamiento de datos ===============================================
### Agregar codigo region
data_raw_01 <- data_raw |>  
  mutate(cut_region = case_when(region == "r_tarapaca" ~ "01",
                                region == "r_antofagasta" ~ "02",
                                region == "r_atacama" ~ "03",
                                region == "r_coquimbo" ~ "04",
                                region == "r_valparaiso" ~ "05",
                                region == "r_ohiggins" ~ "06",
                                region == "r_maule" ~ "07",
                                region == "r_biobio" ~ "08",
                                region == "r_araucania" ~ "09",
                                region == "r_los_lagos" ~ "10",
                                region == "r_aysen" ~ "11",
                                region == "r_magallanes" ~ "12",
                                region == "r_metropolitana" ~ "13",
                                region == "r_los_rios" ~ "14",
                                region == "r_arica_y_parinacota" ~ "15",
                                region == "r_nuble" ~ "16",
                                TRUE ~ "0"
                                )) |> 
  relocate(cut_region, .before = region) |> 
  mutate(comuna = case_when(cut_comuna == 13134 ~ "c_santiago_oeste",
                            cut_comuna == 13135 ~ "c_santiago_sur",
                            TRUE ~ comuna)) |> 
  ### mapping provincias - comunas. Nota: provincias_df from 00_mapping_regiones_provincias_comunas
  left_join(provincias_df, by = "comuna") |> 
  relocate(provincia, .before = cut_comuna) |> 
  ### variables categoricas como factor
  mutate_if(is.character,as.factor) |> 
  filter(comuna != "c_g1_santiago")
  

data_raw_01 |> 
  mutate(cut_provincia = )
  select(cut_comuna, provincia)





