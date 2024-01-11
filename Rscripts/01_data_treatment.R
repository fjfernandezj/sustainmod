
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
  filter(comuna != "c_g1_santiago") |> 
  ### Agregar cero a codigo a cut_comuna
  mutate(cut_comuna = str_pad(cut_comuna, 5, pad = "0")) |> 
  ### codigo cut_proviuncia
  mutate(cut_provincia = str_extract(cut_comuna, "^.{3}")) |> 
  ### Relocacion de variables y cambio de nombres
  relocate(cut_provincia, .after = region) |> 
  rename(Reg = region,
         cut_reg = cut_region,
         cut_prov = cut_provincia,
         Prov = provincia,
         cut_comm = cut_comuna,
         Comm = comuna,
         Act = especie,
         Agg = tipo_cultivo,
         Sys = sistema,
         Area = area_tot,
         Yld = yield,
         Lab = labour,
         Ttl_Cost = ttl_cost,
         CIR = cir) |> 
  relocate(Agg, .after = "Comm") |> 
  relocate(Yld, .after = "Area") |> 
  relocate(Lab, .after = "Yld") |>
  relocate(Ttl_Cost, .after = "Lab") |> 
  ### Filtrar por regiones area de estudio (Atacama a region de Los Lagos)
  filter(Reg %in% c("r_atacama","r_coquimbo", "r_valparaiso", "r_metropolitana",
                       "r_ohiggins", "r_maule", "r_nuble", "r_biobio", "r_araucania",
                       "r_los_rios", "r_los_lagos"))
  

names(data_raw_01)


data_raw_01 |> count(region)
  


colSums(data_raw_01$area_tot)


