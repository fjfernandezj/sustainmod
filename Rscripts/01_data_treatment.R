
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

data_raw <- read_xlsx("data_raw/bd_final.xlsx", col_types = 
                        c("text", "numeric", "text", "text", "text", "text", "text", 
                          "numeric", "numeric", "numeric", "numeric", "numeric"))

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
    # Rendimientos de papa menores a 0.01 toneladas se cambia por rendimiento promedio regional
    Reg == "r_coquimbo" & Act == "poroto" & Yld == 0 ~ 9.66,
    Reg == "r_coquimbo" & Act == "pera" & Yld == 0 ~ 35.4,
    Reg == "r_metropolitana" & Act == "pera" & Yld == 0 ~ 35.4,
    Reg == "r_valparaiso" & Act == "pera" & Yld == 0  ~ 35.4,
    Reg == "r_valparaiso" & Act == "manzana" & Yld == 0  ~ 37.2,
    Reg == "r_coquimbo" & Act == "papa" & Yld < 0.01  ~ 7.74,
    Reg == "r_valparaiso" & Act == "papa" & Yld < 0.01  ~ 3.24,
    Reg == "r_metropolitana" & Act == "papa" & Yld < 0.01  ~ 5.61,
    Reg == "r_ohiggins" & Act == "papa" & Yld < 0.01  ~ 3.32,
    Reg == "r_maule" & Act == "papa" & Yld < 0.01  ~ 5.55,
    Reg == "r_nuble" & Act == "papa" & Yld < 0.01  ~ 4.98,
    Reg == "r_biobio" & Act == "papa" & Yld < 0.01  ~ 2.52,
    TRUE ~ Yld
  )) 



####################################### Tratamiento de datos para llenar vacíos en Lab
Aggr <- c("cereales", "frutales", "forrajeras", "hortalizas", "leguminosas _y_tuberculos")



# Calcular promedios usando un ciclo o lapply para Biobio
Lab_promedios_biobio <- lapply(cultivos, function(cultivo) {
  data_raw_02 %>% 
    filter(Act == cultivo, Reg == "r_biobio") %>% 
    summarise(promedio_Lab = mean(Lab, na.rm = TRUE)) %>% 
    pull(promedio_Lab)
})
names(Lab_promedios_biobio) <- cultivos

# Calcular promedios usando un ciclo o lapply para Biobio
Lab_promedios_coquimbo <- lapply(cultivos, function(cultivo) {
  data_raw_02 %>% 
    filter(Act == cultivo, Reg == "r_coquimbo") %>% 
    summarise(promedio_Lab = mean(Lab, na.rm = TRUE)) %>% 
    pull(promedio_Lab)
})
names(Lab_promedios_coquimbo) <- cultivos


# Convertir Lab_promedios_biobio en un data frame
Lab_promedios_biobio_df <- data.frame(
  Act = names(Lab_promedios_biobio),
  promedio_Lab = unlist(Lab_promedios_biobio)
)

# Convertir Lab_promedios_biobio en un data frame
Lab_promedios_coquimbo_df <- data.frame(
  Act = names(Lab_promedios_coquimbo),
  promedio_Lab = unlist(Lab_promedios_coquimbo)
)


# Actualizar data_raw_02 datos araucania con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(Lab_promedios_biobio_df, by = "Act") %>%
  mutate(
    Lab = if_else(Reg == "r_araucania" & !is.na(promedio_Lab), promedio_Lab, Lab)
  ) %>%
  select(-promedio_Lab)

# Actualizar data_raw_02 datos los rios con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(Lab_promedios_biobio_df, by = "Act") %>%
  mutate(
    Lab = if_else(Reg == "r_los_rios" & !is.na(promedio_Lab), promedio_Lab, Lab)
  ) %>%
  select(-promedio_Lab)


# Actualizar data_raw_02 datos los lagos con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(Lab_promedios_biobio_df, by = "Act") %>%
  mutate(
    Lab = if_else(Reg == "r_los_lagos" & !is.na(promedio_Lab), promedio_Lab, Lab)
  ) %>%
  select(-promedio_Lab)

# Actualizar data_raw_02 datos los lagos con datos biobio
data_raw_02 <- data_raw_02 %>%
  left_join(Lab_promedios_coquimbo_df, by = "Act") %>%
  mutate(
    Lab = if_else(Reg == "r_atacama" & !is.na(promedio_Lab), promedio_Lab, Lab)
  ) %>%
  select(-promedio_Lab)

#data frame promedio Lab por tipo de cultivo y por region
lab_agg_promedios_reg <- data_raw_02 |> 
  group_by(Reg, Agg) |> 
  summarise(Lab_prom = mean(Lab, na.rm = TRUE))


# Une los promedios con el conjunto de datos original
data_raw_02_joined <- data_raw_02 %>%
  left_join(lab_agg_promedios_reg, by = c("Reg", "Agg"))

# Rellena los NA's con los promedios correspondientes
data_raw_02_completed <- data_raw_02_joined %>%
  mutate(Lab = ifelse(is.na(Lab), Lab_prom, Lab))

# Opcional: Si ya no necesitas la columna de promedios, puedes removerla
data_raw_02_completed <- select(data_raw_02_completed, -Lab_prom) |> 
  mutate(Lab = case_when(
    Agg == "industriales" ~ 64.46, # Basado en JH para remolacha Fuente: Costos Directos de Produccion de cultivos INIA QUILAMAPU
    TRUE ~ Lab
  ))


####################################### Tratamiento de datos para llenar vacíos en Ttl_Cost

data_raw_03 <- data_raw_02_completed |> 
  mutate(Ttl_Cost = case_when(
    Act == "albahaca" ~ 1016925*10, # Ficha técnica albahaca http://www.indap.gob.cl/fichas-tecnicas
    Act == "almendro" ~ 5517446,
    Act == "alcachofa" & Reg == "r_araucania" ~ 5399116, # promedio costos totales Bio Bio
    Act == "alcachofa" & Reg == "r_atacama" ~ 5339583, # promedio costos totales Coquimbo
    Act == "alcachofa" & Reg == "r_los_lagos" ~ 5399116, # promedio costos totales Bio Bio
    Act == "alcachofa" & Reg == "r_los_rios" ~ 5399116, # promedio costos totales Bio Bio
    Act == "apio" & Reg == "r_araucania" ~ 3414652, # promedio costos totales Bio Bio
    Act == "apio" & Reg == "r_atacama" ~ 3680234, # promedio costos totales Coquimbo
    Act == "apio" & Reg == "r_los_lagos" ~ 3414652, # promedio costos totales Bio Bio
    Act == "arveja_grano_seco" ~ 4111275, # Fichas tecnicas INDAP
    Act == "avellano_europeo" ~ 2406301,
    Act == "castaño" ~ 4150125,
    Act == "cebada" ~ 1429575,
    Act == "chicharo" & Reg == "r_araucania" ~ 895718, # costo de produccion poroto en biobio
    Act == "chicharo" & Reg == "r_biobio" ~ 895718, # costo de produccion poroto en biobio
    Act == "chicharo" & Reg == "r_coquimbo" ~ 1990602, # costo de produccion poroto en coquimbo
    Act == "chicharo" & Reg == "r_los_lagos" ~ 1896238, # costo de produccion poroto en los lagos
    Act == "chicharo" & Reg == "r_maule" ~ 1009117, # costo de produccion poroto en maule
    Act == "chicharo" & Reg == "r_metropolitana" ~ 931199, # costo de produccion poroto en metropolitana
    Act == "chicharo" & Reg == "r_nuble" ~ 752659, # costo de produccion poroto en ñuble
    Act == "chicharo" & Reg == "r_ohiggins" ~ 963422, # costo de produccion poroto en ohiggins
    Act == "chicharo" & Reg == "r_valparaiso" ~ 1302831, # costo de produccion poroto en valparaíso
    Act == "cerezo" & Reg == "r_araucania" ~ 1502399, # promedio costos totales Bio Bio
    Act == "cerezo" & Reg == "r_los_lagos" ~ 1502399, # promedio costos totales Bio Bio
    Act == "cerezo" & Reg == "r_los_rios" ~ 1502399, # promedio costos totales Bio Bio
    Act == "ciruelo" & Reg == "r_araucania" ~ 1649297, # promedio costos totales Bio Bio
    Act == "ciruelo" & Reg == "r_atacama" ~ 1382001, # promedio costos totales Coquimbo
    Act == "ciruelo" & Reg == "r_los_lagos" ~ 1649297, # promedio costos totales Bio Bio
    Act == "ciruelo" & Reg == "r_los_rios" ~ 1649297, # promedio costos totales Bio Bio
    Act == "duraznero" & Reg == "r_araucania" ~ 2303879, # promedio costos totales Bio Bio
    Act == "duraznero" & Reg == "r_atacama" ~ 2272462, # promedio costos totales Coquimbo
    Act == "duraznero" & Reg == "r_los_lagos" ~ 2303879, # promedio costos totales Bio Bio
    Act == "duraznero" & Reg == "r_los_rios" ~ 2303879, # promedio costos totales Bio Bio
    Act == "esparrago" & Reg == "r_araucania" ~ 1313627, # promedio costos totales Bio Bio
    Act == "esparrago" & Reg == "r_los_rios" ~ 1313627, # promedio costos totales Bio Bio
    Act == "esparrago" & Reg == "r_metropolitana" ~ 1313627, # promedio costos totales ohiggins
    Act == "esparrago" & Reg == "r_valparaiso" ~ 1313627, # promedio costos totales ohiggins
    Act == "manzana" & Reg == "r_araucania" ~ 2343336, # promedio costos totales Bio Bio
    Act == "manzana" & Reg == "r_atacama" ~ 2326771, # promedio costos totales Coquimbo
    Act == "manzana" & Reg == "r_los_lagos" ~ 2343336, # promedio costos totales Bio Bio
    Act == "manzana" & Reg == "r_los_rios" ~ 2343336, # promedio costos totales Bio Bio
    Act == "melon" & Reg == "r_araucania" ~ 9772478, # promedio costos totales Bio Bio
    Act == "melon" & Reg == "r_atacama" ~ 7742716, # promedio costos totales Coquimbo
    Act == "melon" & Reg == "r_los_lagos" ~ 9772478, # promedio costos totales Bio Bio
    Act == "naranjo" & Reg == "r_araucania" ~ 2055184, # promedio costos totales Bio Bio
    Act == "naranjo" & Reg == "r_atacama" ~ 1624250, # promedio costos totales Coquimbo
    Act == "naranjo" & Reg == "r_los_lagos" ~ 2055184, # promedio costos totales Bio Bio
    Act == "olivo" & Reg == "r_araucania" ~ 1600565, # promedio costos totales Bio Bio
    Act == "olivo" & Reg == "r_atacama" ~ 1605382, # promedio costos totales Coquimbo
    Act == "palto" & Reg == "r_araucania" ~ 2468247, # promedio costos totales Bio Bio
    Act == "palto" & Reg == "r_atacama" ~ 2380246, # promedio costos totales Coquimbo
    Act == "palto" & Reg == "r_los_rios" ~ 2468247, # promedio costos totales Bio Bio
    Act == "papa" & Reg == "r_araucania" ~ 578833, # promedio costos totales Bio Bio
    Act == "papa" & Reg == "r_atacama" ~ 861791, # promedio costos totales Coquimbo
    Act == "papa" & Reg == "r_los_lagos" ~ 578833, # promedio costos totales Bio Bio
    Act == "papa" & Reg == "r_los_rios" ~ 578833, # promedio costos totales Bio Bio
    Act == "pera" & Reg == "r_araucania" ~ 1370312, # promedio costos totales Bio Bio
    Act == "pera" & Reg == "r_atacama" ~ 1296702, # promedio costos totales Coquimbo
    Act == "pera" & Reg == "r_los_lagos" ~ 1370312, # promedio costos totales Bio Bio
    Act == "pera" & Reg == "r_los_rios" ~ 1370312, # promedio costos totales Bio Bio
    Act == "remolacha" & Reg == "r_araucania" ~ 1853569, # promedio costos totales Bio Bio
    Act == "remolacha" & Reg == "r_metropolitana" ~ 1874252, # promedio costos totales maule
    Act == "sandia" & Reg == "r_araucania" ~ 8987341, # promedio costos totales Bio Bio
    Act == "sandia" & Reg == "r_atacama" ~ 6546733, # promedio costos totales Coquimbo
    Act == "sandia" & Reg == "r_los_lagos" ~ 8987341, # promedio costos totales Bio Bio
    Act == "sandia" & Reg == "r_los_rios" ~ 8987341, # promedio costos totales Bio Bio
    Act == "trigo" & Reg == "r_araucania" ~ 350574, # promedio costos totales Bio Bio
    Act == "trigo" & Reg == "r_atacama" ~ 291704, # promedio costos totales Coquimbo
    Act == "trigo" & Reg == "r_los_lagos" ~ 350574, # promedio costos totales Bio Bio
    Act == "trigo" & Reg == "r_los_rios" ~ 350574, # promedio costos totales Bio Bio
    Act == "arveja_verde" & Reg == "r_coquimbo" ~ 2485758, # promedio costos totales Bio Bio
    Act == "arveja_verde" & Reg == "r_atacama" ~ 2485758, # promedio costos totales Coquimbo
    Act == "arveja_verde" & Reg == "r_metropolitana" ~ 2485758, # promedio costos totales Bio Bio
    Act == "arveja_verde" & Reg == "r_valparaiso" ~ 2485758, # promedio costos totales Bio Bio
    Act == "avena" & Reg == "r_atacama" ~ 322969, # promedio costos totales Coquimbo
    Act == "betarraga" & Reg == "r_atacama" ~ 4352544, # promedio costos totales Coquimbo
    Act == "brocoli" & Reg == "r_atacama" ~ 6326676, # promedio costos totales Coquimbo
    Act == "cebolla" & Reg == "r_atacama" ~ 3149998, # promedio costos totales Coquimbo
    Act == "cilantro" & Reg == "r_atacama" ~ 2521455, # promedio costos totales Coquimbo
    Act == "coliflor" & Reg == "r_atacama" ~ 6455012, # promedio costos totales Coquimbo
    Act == "espinaca" & Reg == "r_atacama" ~ 4933553, # promedio costos totales Coquimbo
    Act == "maiz" & Reg == "r_atacama" ~ 862005, # promedio costos totales Coquimbo
    Act == "pepino" & Reg == "r_atacama" ~ 5935951, # promedio costos totales Coquimbo
    Act == "pimiento" & Reg == "r_atacama" ~ 7013240, # promedio costos totales Coquimbo
    Act == "poroto" & Reg == "r_atacama" ~ 1990602, # promedio costos totales Coquimbo
    Act == "poroto_verde" & Reg == "r_atacama" ~ 4359130, # promedio costos totales Coquimbo
    Act == "repollo" & Reg == "r_atacama" ~ 5978905, # promedio costos totales Coquimbo
    Act == "trebol" & Reg == "r_atacama" ~ 1501650, # promedio costos totales Coquimbo
    Act == "trebol" & Reg == "r_coquimbo" ~ 1501650, # promedio costos totales Bio Bio
    Act == "trebol" & Reg == "r_metropolitana" ~ 1501650, # promedio costos totales Bio Bio
    Act == "trebol" & Reg == "r_valparaiso" ~ 1501650, # promedio costos totales Bio Bio
    Act == "zanahoria" & Reg == "r_atacama" ~ 4814998, # promedio costos totales Coquimbo
    Act == "damasco" ~ 3712275, # Ficha Tecnica Indap Illapel
    Act == "garbanzo" ~ 1889979, # Ficha Tecnica Indap Cauquenes
    Act == "kiwi" ~ 4360078, # Ficha Tecnica Indap Maule
    Act == "lenteja" ~ 1916093, # Ficha Tecnica Indap Maule
    Act == "limonero" ~ 3510182, # Ficha Tecnica Indap Maule
    Act == "nogal" ~ 3783848, # Ficha Tecnica Indap Maule
    Act == "uva_de_mesa" ~ 9053756, # Ficha Tecnica Indap Maule
    Act == "ballica" & Reg == "r_coquimbo" ~ 1610048, # promedio costos totales Bio Bio
    Act == "ballica" & Reg == "r_metropolitana" ~ 1610048, # promedio costos totales Bio Bio
    Act == "ballica" & Reg == "r_valparaiso" ~ 1610048, # promedio costos totales Bio Bio
    Act == "aji" ~ 6800131, # Ficha Tecnica Indap Maule
    TRUE ~ Ttl_Cost
  )
         )


####################################### Tratamiento de datos para llenar vacíos en CIR
# Información de Informes DGA ESTIMACIONES DE DEMANDA DE AGUA Y PROYECCIONES FUTURAS. ZONA I NORTE. REGIONES I A IV dga 2007
# Pags 237 y 240 para atacama

data_raw_04 <- data_raw_03 |> 
  mutate(CIR = case_when(
    Reg == "r_atacama" & Act == "cebada" & is.na(CIR) ~ 53.59,
    Reg == "r_atacama" & Act == "maiz" & is.na(CIR) ~ 4.65,
    Reg == "r_atacama" & Act == "acelga" & is.na(CIR) ~ 0.396,
    Reg == "r_atacama" & Act == "arveja_verde" & is.na(CIR) ~ 7.804,
    Reg == "r_atacama" & Act == "betarraga" & is.na(CIR) ~ 12.06,
    Reg == "r_atacama" & Act == "cebolla" & is.na(CIR) ~ 354.77,
    Reg == "r_atacama" & Act == "choclo" & is.na(CIR) ~ 1.79,
    Reg == "r_atacama" & Act == "haba" & is.na(CIR) ~ 130.33,
    Reg == "r_atacama" & Act == "lechuga" & is.na(CIR) ~ 2.906,
    Reg == "r_atacama" & Act == "melon" & is.na(CIR) ~ 155.22/53.4,
    Reg == "r_atacama" & Act == "pimenton" & is.na(CIR) ~ 3.89,
    Reg == "r_atacama" & Act == "poroto_verde" & is.na(CIR) ~ 14.015,
    Reg == "r_atacama" & Act == "repollo" & is.na(CIR) ~ 7.993,
    Reg == "r_atacama" & Act == "sandia" & is.na(CIR) ~ 209.21,
    Reg == "r_atacama" & Act == "tomate" & is.na(CIR) ~ 314.06,
    Reg == "r_atacama" & Act == "zapallo_italiano" & is.na(CIR) ~ 19.48,
    Reg == "r_atacama" & Act == "zapallo"  & is.na(CIR) ~ 11.52,
    Reg == "r_atacama" & Act == "naranjo" & is.na(CIR) ~ 575.98,
    Reg == "r_atacama" & Act == "uva_de_mesa" & is.na(CIR) ~ 73579/6835,
    TRUE ~ CIR
  ))

summary(data_raw_04)






data_raw_04|>
  group_by(Reg, Act) |> 
  filter(Reg == "r_atacama" | Reg == "r_coquimbo") |> 
  summarise(CIR_prom = mean(CIR, na.rm = TRUE)) |>
  print(n = 588)
  

data_raw_03 |>
  group_by(Reg, Act) |> 
  summarise(cir_mean = mean(CIR, na.rm = TRUE)) |>
    filter(Act == "naranjo")


data_raw_02_completed |> 
  group_by(Reg, Act) |> 
  summarise(Lab_prom = mean(Lab, na.rm = TRUE)) |> 
  print(n=588)
