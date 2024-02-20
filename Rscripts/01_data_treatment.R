
# Descripcion de Archivo --------------------------------------------------
## Nombre_archivo: 01_data_treatment       
## Versión:        01                               
## Autor:          Francisco Fernández                      
## Deacripción:    Tratamiento de información Pre-tratada para obtener un formato adecuado para su lectura en GAMS 
##
## Notas:  ** Información pre-tratada proviene de:
##                * Censo Agropecuario (INE, 2021- 2022)
##                * Fichas de Costos Odepa (ODEPA)
##                * Fichas Técnicas INDAP 
##                * Información de modeos anteriores
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

data_raw <- read_xlsx("data_raw/bd_final.xlsx", col_types = 
                        c("text", "numeric", "text", "text", "text", "text", "text", 
                          "numeric", "numeric", "numeric", "numeric", "numeric")) |>  
  mutate(especie = as.factor(especie))

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
  group_by(Reg, Act) |> 
  mutate(sum_area = sum(Area)) %>%
  filter(sum_area > 100) %>% # Se consideran aquellos cultivos cuya superficie sea 100 hectareas o más en total por region (75)
  ungroup() |> 
  select(-sum_area) |> # Remove the sum_area column, if not needed 
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
         Act != "praderas",
         Act != "chicharo",
         Act != "alcayota",
         Act != "bounching_(consumo)",
         Act != "camote",
         Act != "achicoria",
         Act != "raps",
         Act != "maravilla",
         Act != "triticale"
  ) |> 
  mutate(Act = case_when(
    Act == "pimiento_(incl._todos_los_tipos)" ~ "pimiento",
    TRUE ~ Act
  )) %>% 
  mutate(Act = as.factor(Act)) 


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
  )) |> 
  filter(!is.na(Yld))



####################################### Tratamiento de datos para llenar vacíos en Lab
Aggr <- c("cereales", "frutales", "forrajeras", "hortalizas", "leguminosas _y_tuberculos")



# Calcular promedios regionales usando un ciclo o lapply para Biobio
Lab_promedios_biobio <- lapply(cultivos, function(cultivo) {
  data_raw_02 %>% 
    filter(Act == cultivo, Reg == "r_biobio") %>% 
    summarise(promedio_Lab = mean(Lab, na.rm = TRUE)) %>% 
    pull(promedio_Lab)
})
names(Lab_promedios_biobio) <- cultivos

# Calcular promedios regionales usando un ciclo o lapply para Coquimbo
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

# Convertir Lab_promedios_coquimbo en un data frame
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

# Actualizar data_raw_02 datos atacama con datos coquimbo
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
  mutate(Lab = ifelse(is.na(Lab), Lab_prom, Lab)) |> 
  mutate(Lab = ifelse(is.nan(Lab), Lab_prom, Lab))

# Opcional: Si ya no necesitas la columna de promedios, puedes removerla
data_raw_02_completed <- select(data_raw_02_completed, -Lab_prom) |> 
  mutate(Lab = case_when(
    Agg == "industriales" ~ 64.46, # Basado en JH para remolacha Fuente: Costos Directos de Produccion de cultivos INIA QUILAMAPU
    TRUE ~ Lab
  )) |> 
  # Cultivos restantes en Atacama Labour basado en mano de obra región de Coquimbo
  mutate(Lab = case_when(
    Reg == "r_atacama" & Act == "alfalfa" ~ 3.441667,
    Reg == "r_atacama" & Act == "tomate" ~ 58.235,
    Reg == "r_atacama" & Act == "uva_de_mesa" ~ 65.72498,
    Reg == "r_atacama" & Act == "mandarina" ~ 65.72498,
    TRUE ~ Lab
  )) |> 
  # Cultivos restantes en Los Lagos Labour basado en mano de obra región de Ohiggins
  mutate(Lab = case_when(
    Reg == "r_los_lagos" & Act == "ajo" ~ 44.845,
    TRUE ~ Lab
))
    
summary(data_raw_02_completed)

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
    Act == "pimiento" & Reg == "r_valparaiso" ~ 7013240, # promedio costos totales Coquimbo --> Corrección antes estaba el valos de ficha técnica para pimentón en invernadero 
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
    Act == "mandarina" ~ 2673619,# https://bibliotecadigital.ciren.cl/server/api/core/bitstreams/14fa17da-fdcb-4b78-8f22-5630baca15db/content Costo ajustado a IPC (DIC 2011 - DIC 2023)
    TRUE ~ Ttl_Cost
  )
         )

data_raw_03 |> 
  group_by(Reg, Act) |> 
  summarise(no_data = is.na(Ttl_Cost))

####################################### Tratamiento de datos para llenar vacíos en CIR
# Información de Informes DGA ESTIMACIONES DE DEMANDA DE AGUA Y PROYECCIONES FUTURAS. ZONA I NORTE. REGIONES I A IV dga 2007 y ESTIMACIONES DE DEMANDA DE AGUA Y PROYECCIONES FUTURAS. ZONA II. REGIONES V A XII Y REGIÓN METROPOLITANA


data_raw_04 <- data_raw_03 |> 
  mutate(CIR = case_when(
    # Región de Atacama (Falta agregar Ají, albahaca, Almendro, apio, manzana, pepino, pera, poroto, trebol)
    Reg == "r_atacama" & Act == "acelga"  ~ 2.201/0.41,
    Reg == "r_atacama" & Act == "aji"  ~ 0, # Buscar
    Reg == "r_atacama" & Act == "ajo"    ~ 3.188/0.16,
    Reg == "r_atacama" & Act == "albahaca"    ~ 0, # Buscar
    Reg == "r_atacama" & Act == "alcachofa"    ~ 315.72/13.22,
    Reg == "r_atacama" & Act == "almendro"    ~ 0, # Buscar
    Reg == "r_atacama" & Act == "apio"    ~ 0, # Buscar
    Reg == "r_atacama" & Act == "arveja_verde"  ~ 4.359/0.4,
    Reg == "r_atacama" & Act == "cebada"  ~ 23.473/1.2,
    Reg == "r_atacama" & Act == "maiz" ~ 2.541/0.27,
    Reg == "r_atacama" & Act == "papa"   ~ 5.880/0.66,
    Reg == "r_atacama" & Act == "betarraga"   ~ 13.922/1.14,
    Reg == "r_atacama" & Act == "brocoli"   ~ 0.296/0.02,
    Reg == "r_atacama" & Act == "cebolla" ~ 191.517/7.86,
    Reg == "r_atacama" & Act == "choclo"   ~ 14.922/1.18,
    Reg == "r_atacama" & Act == "cilantro"   ~ 0.531/0.06,
    Reg == "r_atacama" & Act == "coliflor"   ~ 3.784/0.64,
    Reg == "r_atacama" & Act == "esparrago"   ~ 44.37/3.6,
    Reg == "r_atacama" & Act == "espinaca"   ~ 0.223/0.04,
    Reg == "r_atacama" & Act == "haba"  ~ 394.617/36.21,
    Reg == "r_atacama" & Act == "lechuga"   ~ 25.550/2.52,
    Reg == "r_atacama" & Act == "manzana"   ~ 0, # Buscar
    Reg == "r_atacama" & Act == "melon"   ~ 169.521/12.41,
    Reg == "r_atacama" & Act == "pepino"   ~ 0, # Buscar
    Reg == "r_atacama" & Act == "pera"   ~ 0, # Buscar
    Reg == "r_atacama" & Act == "pimiento"   ~ 189.356/16.654,
    Reg == "r_atacama" & Act == "poroto"   ~ 0, # Buscar
    Reg == "r_atacama" & Act == "poroto_verde"   ~ 6.014/0.659,
    Reg == "r_atacama" & Act == "repollo"   ~ 10.24/1.01,
    Reg == "r_atacama" & Act == "sandia"   ~ 269.785/19.75,
    Reg == "r_atacama" & Act == "tomate"   ~ 1182.725/72.801,
    Reg == "r_atacama" & Act == "trebol"   ~ 0, # Buscar
    Reg == "r_atacama" & Act == "zanahoria"   ~ 45.829/2.72,
    Reg == "r_atacama" & Act == "zapallo_italiano"   ~ 149.671/12.67,
    Reg == "r_atacama" & Act == "zapallo"    ~ 120.616/10.17,
    Reg == "r_atacama" & Act == "ciruelo"    ~ 2.563/0.2,
    Reg == "r_atacama" & Act == "duraznero"    ~ 8.084/0.7,
    Reg == "r_atacama" & Act == "limonero"  ~ 193.543/18.698,
    Reg == "r_atacama" & Act == "naranjo"  ~ 186.942/18.125,
    Reg == "r_atacama" & Act == "nogal"    ~ 71.133/3.1,
    Reg == "r_atacama" & Act == "palto"  ~ 504.953/37,
    Reg == "r_atacama" & Act == "olivo"  ~ 1849.613/220.192,
    Reg == "r_atacama" & Act == "uva_de_mesa"  ~ 16717.182/1955.226,
   # Región de Coquimbo (Falta albahaca y Kiwi)
    Reg == "r_coquimbo" & Act == "acelga"  ~ 1.201/0.4,
    Reg == "r_coquimbo" & Act == "aji"  ~ 91.67/14,
    Reg == "r_coquimbo" & Act == "ajo"  ~ 1.450/0.1,
    Reg == "r_coquimbo" & Act == "albahaca"  ~ 0, # Buscar
    Reg == "r_coquimbo" & Act == "alcachofa"  ~ 1865.133/138,
    Reg == "r_coquimbo" & Act == "almendro"  ~ 540.399/76.8,
    Reg == "r_coquimbo" & Act == "apio"  ~ 88.464/5.2,
    Reg == "r_coquimbo" & Act == "arveja_grano_seco"  ~ 1.681/0.2,
    Reg == "r_coquimbo" & Act == "arveja_verde"  ~ 232.045/29.5,
    Reg == "r_coquimbo" & Act == "avena"  ~ 6.953/0.7,
    Reg == "r_coquimbo" & Act == "betarraga"  ~ 5.173/0.6,
    Reg == "r_coquimbo" & Act == "brocoli"  ~ 1.807/0.2,
    Reg == "r_coquimbo" & Act == "cebada"  ~ 178.842/17,
    Reg == "r_coquimbo" & Act == "cebolla"  ~ 66.738/4.7,
    Reg == "r_coquimbo" & Act == "choclo"  ~ 529.939/61.1,
    Reg == "r_coquimbo" & Act == "cilantro"  ~ 47.384/9.6,
    Reg == "r_coquimbo" & Act == "coliflor"  ~ 3.261/1.8,
    Reg == "r_coquimbo" & Act == "damasco"  ~ 22.352/1.9,
    Reg == "r_coquimbo" & Act == "espinaca"  ~ 0.102/0.1,
    Reg == "r_coquimbo" & Act == "haba"  ~ 297.872/37.9,
    Reg == "r_coquimbo" & Act == "kiwi"  ~ 0, # Buscar
    Reg == "r_coquimbo" & Act == "lechuga"  ~ 109.240/15.2,
    Reg == "r_coquimbo" & Act == "limonero"  ~ 728.186/124.7,
    Reg == "r_coquimbo" & Act == "melon"  ~ 45.643/6.4,
    Reg == "r_coquimbo" & Act == "nogal"  ~ 386.368/32.9,
    Reg == "r_coquimbo" & Act == "pepino"  ~ 70.702/15.6,
    Reg == "r_coquimbo" & Act == "pera"  ~ 54.701/7.3,
    Reg == "r_coquimbo" & Act == "pimiento"  ~ 2034.989/264.6,
    Reg == "r_coquimbo" & Act == "poroto_verde"  ~ 227.692/56.7,
    Reg == "r_coquimbo" & Act == "repollo"  ~ 11.566/1.6,
    Reg == "r_coquimbo" & Act == "sandia"  ~ 10.773/1.5,
    Reg == "r_coquimbo" & Act == "tomate"  ~ 568.463/77.5,
    Reg == "r_coquimbo" & Act == "uva_de_mesa"  ~ 3417.078/568.5,
    Reg == "r_coquimbo" & Act == "zanahoria"  ~ 8.536/0.7,
    Reg == "r_coquimbo" & Act == "zapallo"  ~ 2.944/0.5,
    Reg == "r_coquimbo" & Act == "zapallo_italiano"  ~ 301.833/42.4,
    # Región de Valparaíso (Falta Albahaca y Avellano Europeo)
    Reg == "r_valparaiso" & Act == "acelga"  ~ 1.642/2.3,
    Reg == "r_valparaiso" & Act == "aji"  ~ 8.534/1,
    Reg == "r_valparaiso" & Act == "ajo"  ~ 65.583/6.5,
    Reg == "r_valparaiso" & Act == "albahaca"  ~ 0, #Buscar
    Reg == "r_valparaiso" & Act == "alcachofa"  ~  139.897/9.9,
    Reg == "r_valparaiso" & Act == "almendro"  ~ 214.015/32.9,
    Reg == "r_valparaiso" & Act == "apio"  ~ 9.682/0.5,
    Reg == "r_valparaiso" & Act == "arveja_grano_seco"  ~ 5.203/0.5,
    Reg == "r_valparaiso" & Act == "arveja_verde"  ~ 14.056/2.2,
    Reg == "r_valparaiso" & Act == "avellano_europeo"  ~ 0, # Buscar
    Reg == "r_valparaiso" & Act == "avena"  ~ 78.555/15,
    Reg == "r_valparaiso" & Act == "betarraga"  ~ 3.411/0.4,
    Reg == "r_valparaiso" & Act == "brocoli"  ~ 133.745/13.4,
    Reg == "r_valparaiso" & Act == "cebada"  ~ 8.379/1.6,
    Reg == "r_valparaiso" & Act == "cebolla"  ~ 138.621/11.5,
    Reg == "r_valparaiso" & Act == "choclo"  ~ 87.296/12.8,
    Reg == "r_valparaiso" & Act == "cilantro"  ~ 1.864/0.6,
    Reg == "r_valparaiso" & Act == "coliflor"  ~ 4.040/6.7,
    Reg == "r_valparaiso" & Act == "damasco"  ~ 748.976/79.2,
    Reg == "r_valparaiso" & Act == "espinaca"  ~ 0.388/2,
    Reg == "r_valparaiso" & Act == "esparrago"  ~ 740.662/69.5,
    Reg == "r_valparaiso" & Act == "garbanzo"  ~ 6.090/0.5,
    Reg == "r_valparaiso" & Act == "haba"  ~ 116.644/19.1,
    Reg == "r_valparaiso" & Act == "kiwi"  ~ 8.759/0.7,
    Reg == "r_valparaiso" & Act == "lechuga"  ~ 466.432/61.3,
    Reg == "r_valparaiso" & Act == "lenteja"  ~ 11.372/1,
    Reg == "r_valparaiso" & Act == "limonero"  ~ 48.512/7.5,
    Reg == "r_valparaiso" & Act == "melon"  ~ 69.014/9.1,
    Reg == "r_valparaiso" & Act == "nogal"  ~ 14244.670/1004.8,
    Reg == "r_valparaiso" & Act == "pepino"  ~ 5.789/0.8,
    Reg == "r_valparaiso" & Act == "pera"  ~ 1842.258/140.9,
    Reg == "r_valparaiso" & Act == "pimiento"  ~ 251.134/30.6,
    Reg == "r_valparaiso" & Act == "poroto_verde"  ~ 101.376/28.8,
    Reg == "r_valparaiso" & Act == "repollo"  ~ 44.132/5.8,
    Reg == "r_valparaiso" & Act == "sandia"  ~ 64.464/8.5,
    Reg == "r_valparaiso" & Act == "tomate"  ~ 422.644/34.2,
    Reg == "r_valparaiso" & Act == "uva_de_mesa"  ~ 55030.482/6153.5,
    Reg == "r_valparaiso" & Act == "zanahoria"  ~ 398.913/28.6,
    Reg == "r_valparaiso" & Act == "zapallo"  ~ 21.6/4.5,
    Reg == "r_valparaiso" & Act == "zapallo_italiano"  ~ 60.476/7.7,
   # Región Metropolitana (Falta Albahaca, Garbanzo, Lenteja, Uva de mesa)
    Reg == "r_metropolitana" & Act == "acelga"  ~ 114.237/57.9,
    Reg == "r_metropolitana" & Act == "aji"  ~ 227.957/19.8,
    Reg == "r_metropolitana" & Act == "ajo"  ~ 7367.485/535,
    Reg == "r_metropolitana" & Act == "albahaca"  ~ 0, #Buscar
    Reg == "r_metropolitana" & Act == "alcachofa"  ~  3055.408/209.8,
    Reg == "r_metropolitana" & Act == "almendro"  ~ 18984.344/1748.4,
    Reg == "r_metropolitana" & Act == "apio"  ~ 844.057/42.4,
    Reg == "r_metropolitana" & Act == "arveja_grano_seco"  ~ 4.435/0.6,
    Reg == "r_metropolitana" & Act == "arveja_verde"  ~ 3491.007/396.3,
    Reg == "r_metropolitana" & Act == "avena"  ~ 738.521/78.7,
    Reg == "r_metropolitana" & Act == "betarraga"  ~ 798.965/72.2,
    Reg == "r_metropolitana" & Act == "brocoli"  ~ 1345.016/130.8,
    Reg == "r_metropolitana" & Act == "cebada"  ~ 694.416/74,
    Reg == "r_metropolitana" & Act == "cebolla"  ~ 19166.762/1166.5,
    Reg == "r_metropolitana" & Act == "choclo"  ~ 7547.142/779.1,
    Reg == "r_metropolitana" & Act == "cilantro"  ~ 61.674/12.1,
    Reg == "r_metropolitana" & Act == "coliflor"  ~ 128.423/227.7,
    Reg == "r_metropolitana" & Act == "damasco"  ~ 9278.205/717.4,
    Reg == "r_metropolitana" & Act == "espinaca"  ~ 1.523/8.1,
    Reg == "r_metropolitana" & Act == "esparrago"  ~ 918.540/84,
    Reg == "r_metropolitana" & Act == "garbanzo"  ~ 0, #Buscar
    Reg == "r_metropolitana" & Act == "haba"  ~ 4512.270/718.4,
    Reg == "r_metropolitana" & Act == "kiwi"  ~ 6588.141/524.5,
    Reg == "r_metropolitana" & Act == "lechuga"  ~ 842.748/108.1,
    Reg == "r_metropolitana" & Act == "lenteja"  ~ 0, #Buscar
    Reg == "r_metropolitana" & Act == "limonero"  ~ 6026.722/797.1,
    Reg == "r_metropolitana" & Act == "melon"  ~ 1280.048/164.7,
    Reg == "r_metropolitana" & Act == "nogal"  ~ 60883.381/3864.6,
    Reg == "r_metropolitana" & Act == "pepino"  ~ 377.678/50.9,
    Reg == "r_metropolitana" & Act == "pera"  ~ 8845.885/568.1,
    Reg == "r_metropolitana" & Act == "pimiento"  ~ 1076.992/128,
    Reg == "r_metropolitana" & Act == "poroto_verde"  ~ 3738.236/1044.2,
    Reg == "r_metropolitana" & Act == "remolacha"  ~ 277.932/23,
    Reg == "r_metropolitana" & Act == "repollo"  ~ 1014.260/130.1,
    Reg == "r_metropolitana" & Act == "sandia"  ~ 1454.918/187.2,
    Reg == "r_metropolitana" & Act == "tomate"  ~ 16013.481/1261.5,
    Reg == "r_metropolitana" & Act == "uva_de_mesa"  ~ 0, #Buscar
    Reg == "r_metropolitana" & Act == "zanahoria"  ~ 1192.102/82.9,
    Reg == "r_metropolitana" & Act == "zapallo"  ~ 4488.999/919.5,
    Reg == "r_metropolitana" & Act == "zapallo_italiano"  ~ 1066.939/131.9,
    # Region de Ohiggins (Falta Albahaca, espinaca)
    Reg == "r_ohiggins" & Act == "acelga"  ~ 21.141/17.3,
    Reg == "r_ohiggins" & Act == "aji"  ~ 851.037/81.4,
    Reg == "r_ohiggins" & Act == "ajo"  ~ 3878.192/320.3,
    Reg == "r_ohiggins" & Act == "albahaca"  ~ 0, #Buscar
    Reg == "r_ohiggins" & Act == "alcachofa"  ~  540.263/43.7,
    Reg == "r_ohiggins" & Act == "almendro"  ~ 19303.277/2748.6,
    Reg == "r_ohiggins" & Act == "apio"  ~ 169.171/9.6,
    Reg == "r_ohiggins" & Act == "arveja_grano_seco"  ~ 287.971/29.7,
    Reg == "r_ohiggins" & Act == "arveja_verde"  ~ 1661.964/209.5,
    Reg == "r_ohiggins" & Act == "avena"  ~ 700.289/98.3,
    Reg == "r_ohiggins" & Act == "betarraga"  ~ 309.060/30.3,
    Reg == "r_ohiggins" & Act == "brocoli"  ~ 411.953/45.2,
    Reg == "r_ohiggins" & Act == "cebada"  ~ 438.413/57.8,
    Reg == "r_ohiggins" & Act == "cebolla"  ~ 10290.365/723.4,
    Reg == "r_ohiggins" & Act == "choclo"  ~ 34941.438/2483.4,
    Reg == "r_ohiggins" & Act == "cilantro"  ~ 36.347/8.4,
    Reg == "r_ohiggins" & Act == "coliflor"  ~ 14.245/122.8,
    Reg == "r_ohiggins" & Act == "damasco"  ~ 4339.371/617.9,
    Reg == "r_ohiggins" & Act == "espinaca"  ~ 0, #Buscar
    Reg == "r_ohiggins" & Act == "esparrago"  ~ 353.700/36,
    Reg == "r_ohiggins" & Act == "garbanzo"  ~ 10.557/1,
    Reg == "r_ohiggins" & Act == "haba"  ~ 877.682/124.6,
    Reg == "r_ohiggins" & Act == "kiwi"  ~ 16402.716/1210.9,
    Reg == "r_ohiggins" & Act == "lechuga"  ~ 3375.797/349.1,
    Reg == "r_ohiggins" & Act == "lenteja"  ~ 10.557/1,
    Reg == "r_ohiggins" & Act == "limonero"  ~ 5270.160/722.9,
    Reg == "r_ohiggins" & Act == "melon"  ~ 11160.121/1141,
    Reg == "r_ohiggins" & Act == "nogal"  ~ 19512.817/1324,
    Reg == "r_ohiggins" & Act == "pepino"  ~ 868.634/132.9,
    Reg == "r_ohiggins" & Act == "pera"  ~ 35708.621/2416.5,
    Reg == "r_ohiggins" & Act == "pimiento"  ~ 661.919/91.4,
    Reg == "r_ohiggins" & Act == "poroto_verde"  ~ 2370.547/230.8,
    Reg == "r_ohiggins" & Act == "remolacha"  ~ 5987.279/410.2,
    Reg == "r_ohiggins" & Act == "repollo"  ~ 1338.597/201.9,
    Reg == "r_ohiggins" & Act == "sandia"  ~ 15912.481/1302.7,
    Reg == "r_ohiggins" & Act == "tomate"  ~ 22504.212/1344.9,
    Reg == "r_ohiggins" & Act == "uva_de_mesa"  ~ 71709/9055.3,
    Reg == "r_ohiggins" & Act == "zanahoria"  ~ 2247.283/174.1,
    Reg == "r_ohiggins" & Act == "zapallo"  ~ 2455.022/666.4,
    Reg == "r_ohiggins" & Act == "zapallo_italiano"  ~ 821.417/115.4,
    # Región del Maule (Falta alfalfa, ballica, festuca, trebol -> se asume consumo de praderas )
    Reg == "r_maule" & Act == "aji"  ~ 1032.721/106.51,
    Reg == "r_maule" & Act == "ajo"  ~ 13.647/1.1,
    Reg == "r_maule" & Act == "alcachofa"  ~  24684.065/1530.51,
    Reg == "r_maule" & Act == "alfalfa"  ~  183235.219/6426.6,
    Reg == "r_maule" & Act == "arroz"  ~ 8492.887/771.8, 
    Reg == "r_maule" & Act == "arveja_grano_seco"  ~ 2.932/0.3,
    Reg == "r_maule" & Act == "arveja_verde"  ~ 4.007/0.5,
    Reg == "r_maule" & Act == "avellano_europeo"  ~ 13839.599/774.2,
    Reg == "r_maule" & Act == "avena"  ~ 4073.196/680.34,
    Reg == "r_maule" & Act == "ballica"  ~ 183235.219/6426.6,
    Reg == "r_maule" & Act == "brocoli"  ~ 27.810/5,
    Reg == "r_maule" & Act == "cebada"  ~ 1722.819/287.76,
    Reg == "r_maule" & Act == "cebolla"  ~ 32.816/2.3,
    Reg == "r_maule" & Act == "choclo"  ~ 28.166/2,
    Reg == "r_maule" & Act == "cilantro"  ~ 2.065/1,
    Reg == "r_maule" & Act == "coliflor"  ~ 0.673/3.8,
    Reg == "r_maule" & Act == "esparrago"  ~ 223.985/32.5,
    Reg == "r_maule" & Act == "festuca"  ~ 183235.219/6426.6,
    Reg == "r_maule" & Act == "garbanzo"  ~ 368.490/37.79,
    Reg == "r_maule" & Act == "haba"  ~ 1.520/0.2,
    Reg == "r_maule" & Act == "kiwi"  ~ 37971.829/4313.51,
    Reg == "r_maule" & Act == "lechuga"  ~ 14.826/1.5,
    Reg == "r_maule" & Act == "lenteja"  ~ 21.753/2.8,
    Reg == "r_maule" & Act == "melon"  ~ 8.870/0.9,
    Reg == "r_maule" & Act == "nogal"  ~ 285.180/28,
    Reg == "r_maule" & Act == "pepino"  ~ 9.989/2.4,
    Reg == "r_maule" & Act == "pera"  ~ 1383.696/134.85,
    Reg == "r_maule" & Act == "pimiento"  ~ 2159.032/328.27,
    Reg == "r_maule" & Act == "poroto_verde"  ~ 8.299/0.8,
    Reg == "r_maule" & Act == "remolacha"  ~ 21643.495/1294.39,
    Reg == "r_maule" & Act == "repollo"  ~ 6.895/1,
    Reg == "r_maule" & Act == "sandia"  ~ 2159.032/328.27,
    Reg == "r_maule" & Act == "tomate"  ~ 13007.363/828.6,
    Reg == "r_maule" & Act == "trebol"  ~ 183235.219/6426.6,
    Reg == "r_maule" & Act == "uva_de_mesa"  ~ 177.675/23,
    Reg == "r_maule" & Act == "zanahoria"  ~ 9.178/0.7,
    Reg == "r_maule" & Act == "zapallo"  ~ 0.412/0.1,
    Reg == "r_maule" & Act == "zapallo_italiano"  ~ 1.468/0.2,
    # Región del Ñuble (Se utiliza información disponible de la parte norte de la región del Bio Bio. En caso de no existir información se recurre a zonas de más al sur de la región)
    Reg == "r_nuble" & Act == "alfalfa"  ~ 53230.615/4485.6,
    Reg == "r_nuble" & Act == "arroz"  ~ 43218.141/2337,
    Reg == "r_nuble" & Act == "arveja_grano_seco"  ~ 8.001/1.8,
    Reg == "r_nuble" & Act == "arveja_verde"  ~ 822.465/185.7,
    Reg == "r_nuble" & Act == "avellano_europeo"  ~ 6.278/0.7,
    Reg == "r_nuble" & Act == "avena"  ~ 807.312/336.1,
    Reg == "r_nuble" & Act == "ballica"  ~ 53230.615/4485.6,
    Reg == "r_nuble" & Act == "castaño"  ~ 93.592/8.9,
    Reg == "r_nuble" & Act == "cebada"  ~ 849.889/779,
    Reg == "r_nuble" & Act == "cebolla"  ~ 214.691/28.5,
    Reg == "r_nuble" & Act == "cerezo"  ~ 885.189/163.5,
    Reg == "r_nuble" & Act == "choclo"  ~ 5381.188/576.7,
    Reg == "r_nuble" & Act == "esparrago"  ~ 2686.342/484.2,
    Reg == "r_nuble" & Act == "festuca"  ~ 53230.615/4485.6,
    Reg == "r_nuble" & Act == "kiwi"  ~ 845.345/86.8,
    Reg == "r_nuble" & Act == "lechuga"  ~ 60.075/13.7,
    Reg == "r_nuble" & Act == "lenteja"  ~ 22.042/4.2,
    Reg == "r_nuble" & Act == "maiz"  ~ 2828.050/359.3,
    Reg == "r_nuble" & Act == "manzana"  ~ 2527.014/299.8,
    Reg == "r_nuble" & Act == "nogal"  ~ 98.289/18.3,
    Reg == "r_nuble" & Act == "olivo"  ~ 22.390/22.8,
    Reg == "r_nuble" & Act == "papa"  ~ 2286.629/272.9,
    Reg == "r_nuble" & Act == "poroto"  ~ 15588.014/1861.7,
    Reg == "r_nuble" & Act == "poroto_verde"  ~ 906.275/152.7,
    Reg == "r_nuble" & Act == "remolacha"  ~ 53647.184/4616.4,
    Reg == "r_nuble" & Act == "tomate"  ~ 1572.367/178.8,
    Reg == "r_nuble" & Act == "trebol"  ~ 53230.615/4485.6,
    Reg == "r_nuble" & Act == "trigo"  ~ 36095.609/7447,
    Reg == "r_nuble" & Act == "zanahoria"  ~ 924.253/150.8,
    Reg == "r_nuble" & Act == "zapallo"  ~ 6.130/11.5,
    # Región del BioBio (ok)
    Reg == "r_biobio" & Act == "alfalfa"  ~ 53230.615/4485.6,
    Reg == "r_biobio" & Act == "arveja_grano_seco"  ~ 8.001/1.8,
    Reg == "r_biobio" & Act == "arveja_verde"  ~ 305.991/82.3,
    Reg == "r_biobio" & Act == "avellano_europeo"  ~ 6.278/0.7,
    Reg == "r_biobio" & Act == "avena"  ~ 486.041/445.5,
    Reg == "r_biobio" & Act == "ballica"  ~ 53230.615/4485.6,
    Reg == "r_biobio" & Act == "castaño"  ~ 524.628/58.5,
    Reg == "r_biobio" & Act == "cebolla"  ~ 214.691/28.5,
    Reg == "r_biobio" & Act == "cerezo"  ~ 2186.870/490,
    Reg == "r_biobio" & Act == "choclo"  ~ 758.128/93.4,
    Reg == "r_biobio" & Act == "esparrago"  ~ 211.698/473.9,
    Reg == "r_biobio" & Act == "festuca"  ~ 53230.615/4485.6,
    Reg == "r_biobio" & Act == "lechuga"  ~ 60.075/13.7,
    Reg == "r_biobio" & Act == "lenteja"  ~ 22.042/4.2,
    Reg == "r_biobio" & Act == "maiz"  ~ 2828.050/359.3,
    Reg == "r_biobio" & Act == "manzana"  ~ 651.147/92.1,
    Reg == "r_biobio" & Act == "nogal"  ~ 98.289/18.3,
    Reg == "r_biobio" & Act == "papa"  ~ 14489/2013.2,
    Reg == "r_biobio" & Act == "poroto"  ~ 7361.102/1067.6,
    Reg == "r_biobio" & Act == "remolacha"  ~ 31895.686/3212.7,
    Reg == "r_biobio" & Act == "tomate"  ~ 1572.367/178.8,
    Reg == "r_biobio" & Act == "trebol"  ~ 53230.615/4485.6,
    Reg == "r_biobio" & Act == "trigo"  ~ 14365.250/4274,
    Reg == "r_biobio" & Act == "uva_de_mesa"  ~ 16.201/5.6,
    Reg == "r_biobio" & Act == "zanahoria"  ~ 924.253/150.8,
    # Región de la Araucanía (Para lenteja se asume cir de poroto y alfalfa, ballica y trebol cir de forrajeras)
    Reg == "r_araucania" & Act == "acelga"  ~ 0.277/1.90,
    Reg == "r_araucania" & Act == "alfalfa"  ~ 61588.824/3689.50,
    Reg == "r_araucania" & Act == "arveja_grano_seco"  ~ 24.964/4,
    Reg == "r_araucania" & Act == "arveja_verde"  ~ 1193.696/233.6,
    Reg == "r_araucania" & Act == "avellano_europeo"  ~ 23.946/2, 
    Reg == "r_araucania" & Act == "avena"  ~ 1534.091/505.80,
    Reg == "r_araucania" & Act == "ballica"  ~ 61588.824/3689.50,
    Reg == "r_araucania" & Act == "castaño"  ~ 83.811/7,
    Reg == "r_araucania" & Act == "cebada"  ~ 738.839/243.6,
    Reg == "r_araucania" & Act == "cerezo"  ~ 9.629/1.9,
    Reg == "r_araucania" & Act == "choclo"  ~ 384.820/36.5,
    Reg == "r_araucania" & Act == "cilantro"  ~ 12.303/6.9,
    Reg == "r_araucania" & Act == "haba"  ~ 59.080/21.10,
    Reg == "r_araucania" & Act == "lechuga"  ~ 55.163/9.20,
    Reg == "r_araucania" & Act == "lenteja"  ~ 301.419/31.30,
    Reg == "r_araucania" & Act == "maiz"  ~ 58.811/5.6,
    Reg == "r_araucania" & Act == "manzana"  ~ 1533.848/223.3,
    Reg == "r_araucania" & Act == "nogal"  ~ 17.251/1.80,
    Reg == "r_araucania" & Act == "papa"  ~ 2613.106/374.80,
    Reg == "r_araucania" & Act == "poroto"  ~ 301.419/31.30,
    Reg == "r_araucania" & Act == "poroto_verde"  ~ 233.005/34.10,
    Reg == "r_araucania" & Act == "remolacha"  ~ 4003.929/483.8,
    Reg == "r_araucania" & Act == "tomate"  ~ 60.440/8,
    Reg == "r_araucania" & Act == "trebol"  ~ 61588.824/3689.50,
    Reg == "r_araucania" & Act == "trigo"  ~ 6562.471/1150.10,
    Reg == "r_araucania" & Act == "zanahoria"  ~ 364.682/48.80,
    # Región de los Ríos (Falta por cambiar completo)
    Reg == "r_los_rios" & Act == "alfalfa"  ~ 1165.034/220.4,
    Reg == "r_los_rios" & Act == "arveja_grano_seco"  ~ 0.175/0.1,
    Reg == "r_los_rios" & Act == "arveja_verde"  ~ 1.904/1.5,
    Reg == "r_los_rios" & Act == "avena"  ~ 1534.091/505.80, # Información usada de Bio Bio
    Reg == "r_los_rios" & Act == "ballica"  ~ 1165.034/220.4,
    Reg == "r_los_rios" & Act == "castaño"  ~ 0.341/0.9,
    Reg == "r_los_rios" & Act == "cebada"  ~ 738.839/243.6, # Información usada de Bio Bio
    Reg == "r_los_rios" & Act == "cerezo"  ~ 6.683/5.3,
    Reg == "r_los_rios" & Act == "maiz"  ~ 58.811/5.6, # Información usada de Bio Bio
    Reg == "r_los_rios" & Act == "manzana"  ~ 181.155/95.9,
    Reg == "r_los_rios" & Act == "papa"  ~ 1.445/0.8,
    Reg == "r_los_rios" & Act == "trebol"  ~ 1165.034/220.4,
    Reg == "r_los_rios" & Act == "trigo"  ~ 0.138/0.4,
    # Región de los Lagos (Falta por cambiar completo)
    Reg == "r_los_lagos" & Act == "ajo"  ~ 0.062/0.1,
    Reg == "r_los_lagos" & Act == "avellano_europeo"  ~ 20.544/4.7,
    Reg == "r_los_lagos" & Act == "avena"  ~ 1534.091/505.80, # Información usada de Bio Bio
    Reg == "r_los_lagos" & Act == "ballica"  ~ 7.980/2.8,
    Reg == "r_los_lagos" & Act == "cerezo"  ~ 5.037/4.9,
    Reg == "r_los_lagos" & Act == "maiz"  ~ 58.811/5.6, # Información usada de Bio Bio
    Reg == "r_los_lagos" & Act == "manzana"  ~ 7.130/4.6,
    Reg == "r_los_lagos" & Act == "papa"  ~ 1.481/1,
    Reg == "r_los_lagos" & Act == "trigo"  ~ 0.710/1.1,
    TRUE ~ CIR
  )) |> 
  mutate(CIR = case_when(
    Sys == "secano" ~ 0,
    TRUE ~ CIR
  )) |> 
  mutate(Act = case_when(
    Agg == "forrajeras" & Act == "avena" ~ "avena_f",
    Agg == "cereales" & Act == "avena" ~ "avena_c",
    Agg == "forrajeras" & Act == "cebada" ~ "cebada_f",
    Agg == "cereales" & Act == "cebada" ~ "cebada_c",
    Agg == "forrajeras" & Act == "maiz" ~ "maiz_f",
    Agg == "cereales" & Act == "maiz" ~ "maiz_c",
    Agg == "hortalizas" & Act == "poroto" ~ "poroto_h",
    Agg == "leguminosas_y_tuberculos" & Act == "poroto" ~ "poroto_l",
    Agg == "hortalizas" & Act == "tomate" ~ "tomate_h",
    Agg == "industriales" & Act == "tomate" ~ "tomate_i",
    TRUE ~ Act
  )) 

data_raw_05 <- data_raw_04 |> 
  group_by(Reg, Prov, Comm, Agg, Act, Sys, tech) |> 
  summarise(area = sum(Area, na.rm = TRUE),
            yld = mean(Yld, na.rm = TRUE),
            lab = mean(Lab, na.rm = TRUE),
            ttl_Cost = mean(Ttl_Cost, na.rm = TRUE),
            cir = mean(CIR, na.rm = TRUE)) |> 
  mutate(Sys = case_when(
    Sys == "riego" ~ "irr",
    Sys == "secano" ~ "dry",
  ))


summary(data_raw_05)

# Es necesario revisar costos totales de hortalizas tales como tomate, pepino, ajo y otros!!!!!


write_xlsx(data_raw_05, "data_raw/db_forgams.xlsx")


data_raw_04 |>
  group_by(Reg, Agg) |> 
  summarise(total_reg_area = sum(Area)) |> 
  ggplot(aes(fct_reorder(Reg, total_reg_area), total_reg_area))+
    geom_col(aes(fill= Agg))

Activities <- data_raw_04 |>
  group_by(Agg, Act) |> 
  count()
  
write_xlsx(Activities, "data_raw/activities.xlsx")

Regions <- data_raw_04 |>
  group_by(Reg) |> 
  count()

write_xlsx(Regions, "data_raw/regions.xlsx")

Provinces <- data_raw_04 |>
  group_by(Prov) |> 
  count() 

write_xlsx(Provinces, "data_raw/provinces.xlsx")

map_reg_comm <- data_raw_04 |> 
  group_by(Reg, Comm) |> 
  count()

write_xlsx(map_reg_comm, "data_raw/map_reg_comm.xlsx")

map_prov_comm <- data_raw_04 |> 
  group_by(Prov, Comm) |> 
  count() 

write_xlsx(map_prov_comm, "data_raw/map_prov_comm.xlsx")

map_reg_prov_comm <- data_raw_04 |> 
  group_by(Reg, Prov, Comm) |> 
  count() 

write_xlsx(map_reg_prov_comm, "data_raw/map_reg_prov_comm.xlsx")

tech <- data_raw_04 |> 
  group_by(tech) |> 
  count() 

write_xlsx(tech, "data_raw/tech.xlsx")

map_sys_tech <- data_raw_04 |> 
  group_by(Sys, tech) |> 
  count() 

write_xlsx(map_sys_tech, "data_raw/map_sys_tech.xlsx")

