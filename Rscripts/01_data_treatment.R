
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

data_raw <- read_xlsx("data_raw/bd_final.xlsx")


## Mapping Regions- Provinces - Communes
source("Rscripts/00_mapping_regiones_provincias_comunas_v02.R")


## Cap 1.3: Tratamiento de datos ===============================================
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
                       "r_los_rios", "r_los_lagos")) |> 
  # Seleccion de cultivos a trabajar
  group_by(Act) |> 
  mutate(count = n()) %>%
  filter(count > 100) %>%
  ungroup() |> 
  select(-count) |> # Remove the count column, if not needed 
  filter(Act != "huerta_casera_(princ._autoconsumo)",
         Act != "quinta_frutal",
         Act != "ostra",
         Act != "tintas",
         Act != "blancas",
         Act != "tomate_cherry_(u_otros_mini)",
         Act != "cebollin_(incl._baby_y_otros)",
         Act != "ciboultte",
         Act != "perejil",
         Act != "puerro",
         Act != "mezcla_de_forrajeras",
         Act != "berries",
         Act != "moras_murta_zarzaparrilla",
         Act != "membrillo",
         Act != "praderas"
  ) |> 
  mutate(Act = case_when(
    Act == "pimiento_(incl._todos_los_tipos)" ~ "pimiento",
    TRUE ~ Act
  ))


####################################### Tratamiento de datos para llenar vacíos en Yld
# Definir una lista de cultivos
cultivos <- c("cerezo", "apio", "alcachofa", "sandia", "esparrago", "melon", 
              "ciruelo", "duraznero", "manzana", "naranjo", "olivo", 
              "palto", "pera", "aji", "arveja_grano_seco", "avena",
              "betarraga", "brocoli", "cebada", "cebolla", "choclo", "cilantro",
              "coliflor", "espinaca", "maiz", "papa", "pepino", "pimiento", "poroto",
              "poroto_verde", "repollo", "trebol", "trigo", "zanahoria")

# Calcular promedios usando un ciclo o lapply para Biobio
yld_promedios_biobio <- lapply(cultivos, function(cultivo) {
  data_raw_01 %>% 
    filter(Act == cultivo, Reg == "r_biobio") %>% 
    summarise(promedio_yld = mean(Yld, na.rm = TRUE)) %>% 
    pull(promedio_yld)
})
names(yld_promedios_biobio) <- cultivos


# Calcular promedios usando un ciclo o lapply para Atacama
yld_promedios_coquimbo <- lapply(cultivos, function(cultivo) {
  data_raw_01 %>% 
    filter(Act == cultivo, Reg == "r_biobio") %>% 
    summarise(promedio_yld = mean(Yld, na.rm = TRUE)) %>% 
    pull(promedio_yld)
})
names(yld_promedios_coquimbo) <- cultivos


# Crear un vector para los rendimientos de hortalizas y otros
yld_otros <- c(albahaca = (900 * 10 * 100)/(1000*1000), 
               almendro = 6.3, 
               damasco = 30, 
               limonero = 37.8, 
               kiwi = 10.8, 
               nogal = 3.5, 
               uva_de_mesa = 22.95,
               garbanzo = 0.5,
               arveja_verde = 7.25)

# Convertir yld_promedios_biobio en un data frame
yld_promedios_biobio_df <- data.frame(
  Act = names(yld_promedios_biobio),
  promedio_yld = unlist(yld_promedios_biobio)
)

# Convertir yld_promedios_coqiombo en un data frame
yld_promedios_coquimbo_df <- data.frame(
  Act = names(yld_promedios_coquimbo),
  promedio_yld = unlist(yld_promedios_coquimbo)
)


# Preparar yld_otros como un data frame
yld_otros_df <- data.frame(
  Act = names(yld_otros),
  promedio_yld = unlist(yld_otros)
)

# Combinar yld_promedios_df y yld_otros_df
yld_total_biobio_df <- rbind(yld_promedios_biobio_df, yld_otros_df)
yld_total_coquimbo_df <- rbind(yld_promedios_coquimbo_df, yld_otros_df)

# Actualizar data_raw_02 datos araucania con datos biobio
data_raw_02 <- data_raw_01 %>%
  left_join(yld_total_biobio_df, by = "Act") %>%
  mutate(
    Yld = if_else(Reg == "r_araucania" & !is.na(promedio_yld), promedio_yld, Yld)
  ) %>%
  select(-promedio_yld)

# Actualizar data_raw_02 datos atacama con datos coquimbo
data_raw_02 <- data_raw_02 %>%
  left_join(yld_total_coquimbo_df, by = "Act") %>%
  mutate(
    Yld = if_else(Reg == "r_atacama" & !is.na(promedio_yld), promedio_yld, Yld)
  ) %>%
  select(-promedio_yld)

# Actualizar data_raw_02 datos frutales
data_raw_02 <- data_raw_02 %>%
  left_join(yld_otros_df, by = "Act") %>%
  mutate(
    Yld = if_else(!is.na(promedio_yld), promedio_yld, Yld)
  ) %>%
  select(-promedio_yld)

# Actualizar data_raw_02 datos los lagos con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(yld_total_biobio_df, by = "Act") %>%
  mutate(
    Yld = if_else(Reg == "r_los_lagos" & !is.na(promedio_yld), promedio_yld, Yld)
  ) %>%
  select(-promedio_yld)

# Actualizar data_raw_02 datos los rios con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(yld_total_biobio_df, by = "Act") %>%
  mutate(
    Yld = if_else(Reg == "r_los_rios" & !is.na(promedio_yld), promedio_yld, Yld)
  ) %>%
  select(-promedio_yld)


data_raw_02 <- data_raw_02 |> 
  mutate(Yld = case_when(
    Reg == "r_coquimbo" & Act == "ballica" ~ 12.5,
    Reg == "r_metropolitana" & Act == "ballica" ~ 12.5,
    Reg == "r_valparaiso" & Act == "ballica" ~ 12.5,
    Reg == "r_coquimbo" & Act == "trebol" ~ 15,
    Reg == "r_metropolitana" & Act == "trebol" ~ 15,
    Reg == "r_valparaiso" & Act == "trebol" ~ 15,
    Reg == "r_metropolitana" & Act == "lenteja" ~ 0.681,
    Reg == "r_valparaiso" & Act == "lenteja" ~ 0.681,
    Reg == "r_metropolitana" & Act == "esparrago" ~ 5,
    Reg == "r_valparaiso" & Act == "esparrago" ~ 5,
    Reg == "r_metropolitana" & Act == "remolacha" ~ 733, # Asumiendo rendimiento de region más cercana (maule)
    Reg == "r_valparaiso" & Act == "avellano_europeo" ~ 1.6, # Asumiendo rendimiento de region más cercana (ohiggins)
    Act == "arveja_grano_seco" ~ 3, #  https://biblioteca.inia.cl/bitstream/handle/20.500.14001/69095/NR43242.pdf?sequence=1&isAllowed=y
    Act == "chicharo" ~ 0.8, # https://biblioteca.inia.cl/bitstream/handle/20.500.14001/7062/NR33205.pdf?sequence=6
    Reg == "r_coquimbo" & Act == "poroto" & Yld == 0 ~ 9.66,
    Reg == "r_coquimbo" & Act == "pera" & Yld == 0 ~ 35.4,
    Reg == "r_metropolitana" & Act == "pera" & Yld == 0 ~ 35.4,
    Reg == "r_valparaiso" & Act == "pera" & Yld == 0  ~ 35.4,
    Reg == "r_valparaiso" & Act == "manzana" & Yld == 0  ~ 37.2,
    TRUE ~ Yld
  )) 

summary(data_raw_02)



data_raw_02 |> 
  filter(Yld == 0) |> 
  group_by(Reg, Act) |> 
  count(sort = TRUE) |> 
  print(n=34)


data_raw_02 |> 
  group_by(Reg, Act) |> 
  summarise(Yld_prom = mean(Yld)) |>
  filter(Act == "manzana") 
