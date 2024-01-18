# Crear listas para las regiones, donde cada región contiene sus comunas
regiones = list(
  r_arica_y_parinacota = c("c_arica", "c_camarones", "c_putre", "c_general_lagos"),
  r_tarapaca = c("c_iquique", "c_alto_hospicio", "c_pozo_almonte", "c_camina", "c_colchane", "c_huara", "c_pica"),
  r_antofagasta = c("c_antofagasta", "c_mejillones", "c_taltal", "c_sierra_gorda", "c_calama", "c_ollague", "c_san_pedro_de_atacama"),
  r_atacama = c("c_chanaral", "c_diego_de_almagro", "c_caldera", "c_copiapo", "c_tierra_amarilla",
                 "c_alto_del_carmen", "c_freirina", "c_huasco", "c_vallenar", "c_copiapo/caldera"),
  r_coquimbo = c("c_canela", "c_illapel", "c_los_vilos", "c_salamanca", "c_andacollo", "c_coquimbo",
                  "c_la_higuera", "c_la_serena", "c_paiguano", "c_vicuna", "c_combarbala",
                  "c_monte_patria", "c_ovalle", "c_punitaqui", "c_rio_hurtado"),
  r_valparaiso = c("c_isla_de_pascua", "c_calle_larga", "c_los_andes", "c_rinconada", "c_san_esteban",
                    "c_cabildo", "c_la_ligua", "c_papudo", "c_petorca", "c_zapallar", "c_hijuelas",
                    "c_calera", "c_la_cruz", "c_nogales", "c_quillota", "c_algarrobo", "c_cartagena",
                    "c_el_quisco", "c_el_tabo", "c_san_antonio", "c_santo_domingo", "c_catemu",
                    "c_llaillay", "c_panquehue", "c_putaendo", "c_san_felipe", "c_santa_maria",
                    "c_casablanca", "c_concon", "c_juan_fernandez", "c_puchuncavi", "c_quintero",
                    "c_valparaiso", "c_vina_del_mar", "c_limache", "c_olmue", "c_quilpue", "c_villa_alemana"),
  r_metropolitana = c("c_colina", "c_lampa", "c_tiltil", "c_pirque", "c_puente_alto", "c_san_jose_de_maipo",
                       "c_buin", "c_calera_de_tango", "c_paine", "c_san_bernardo", "c_alhue", "c_curacavi",
                       "c_maria_pinto", "c_melipilla", "c_san_pedro", "c_cerrillos", "c_cerro_navia", "c_conchali",
                       "c_el_bosque", "c_estacion_central", "c_huechuraba", "c_independencia", "c_la_cisterna",
                       "c_la_florida", "c_la_granja", "c_la_pintana", "c_la_reina", "c_las_condes", "c_lo_barnechea",
                       "c_lo_espejo", "c_lo_prado", "c_macul", "c_maipu", "c_nunoa", "c_pedro_aguirre_cerda", "c_penalolen",
                       "c_providencia", "c_pudahuel", "c_quilicura", "c_quinta_normal", "c_recoleta", "c_renca", "c_san_joaquin",
                       "c_san_miguel", "c_san_ramon", "c_santiago", "c_vitacura", "c_el_monte", "c_isla_de_maipo",
                       "c_padre_hurtado", "c_penaflor", "c_talagante"),
    r_ohiggins = c("c_codegua", "c_coinco", "c_coltauco", "c_donihue", "c_graneros", "c_las_cabras", "c_machali", "c_malloa",
                  "c_mostazal", "c_olivar", "c_peumo", "c_pichidegua", "c_quinta_de_tilcoco", "c_rancagua", "c_rengo",
                  "c_requinoa", "c_san_vicente", "c_la_estrella", "c_litueche", "c_marchihue", "c_navidad", "c_paredones",
                  "c_pichilemu", "c_chepica", "c_chimbarongo", "c_lolol", "c_nancagua", "c_palmilla", "c_peralillo",
                  "c_placilla", "c_pumanque", "c_san_fernando", "c_santa_cruz"),
  r_maule = c("c_cauquenes", "c_chanco", "c_pelluhue", "c_curico", "c_hualane", "c_licanten", "c_molina", "c_rauco",
               "c_romeral", "c_sagrada_familia", "c_teno", "c_vichuquen", "c_colbun", "c_linares", "c_longavi",
               "c_parral", "c_retiro", "c_san_javier", "c_villa_alegre", "c_yerbas_buenas", "c_constitucion",
               "c_curepto", "c_empedrado", "c_maule", "c_pelarco", "c_pencahue", "c_rio_claro", "c_san_clemente",
               "c_san_rafael", "c_talca"),
  r_nuble = c("c_cobquecura", "c_coelemu", "c_ninhue", "c_portezuelo", "c_quirihue", "c_ranquil",
               "c_treguaco", "c_bulnes", "c_chillan", "c_chillan_viejo", "c_el_carmen", "c_pemuco", "c_pinto", "c_quillon",
               "c_san_ignacio", "c_yungay", "c_coihueco", "c_niquen", "c_san_carlos", "c_san_fabian", "c_san_nicolas"),
  
  # Región del Bío Bío después de 2017
  r_biobio = c("c_arauco", "c_canete", "c_contulmo", "c_curanilahue", "c_lebu", "c_los_alamos","c_tirua", "c_alto_biobio",
                "c_antuco", "c_cabrero", "c_laja", "c_los_angeles", "c_mulchen", "c_nacimiento", "c_negrete", "c_quilaco",
                "c_quilleco", "c_san_rosendo", "c_santa_barbara", "c_tucapel", "c_yumbel", "c_chiguayante", "c_concepcion",
                "c_coronel", "c_florida", "c_hualpen", "c_hualqui", "c_lota", "c_penco", "c_san_pedro_de_la_paz", "c_santa_juana",
                "c_talcahuano", "c_tome"),
  r_araucania = c("c_angol", "c_collipulli", "c_curacautin", "c_ercilla", "c_lonquimay", "c_los_sauces", "c_lumaco",
                   "c_puren", "c_renaico", "c_traiguen", "c_victoria", "c_gorbea", "c_lautaro", "c_loncoche", "c_melipeuco", "c_nueva_imperial",
                  "c_padre_las_casas", "c_perquenco","c_pitrufquen", "c_pucon", "c_saavedra", "c_teodoro_schmidt", "c_tolten", "c_vilcun", "c_villarrica",
                   "c_cholchol", "c_temuco", "c_carahue", "c_cunco", "c_curarrehue", "c_freire", "c_galvarino"),
  r_los_rios = c("c_valdivia", "c_corral", "c_lanco", "c_los_lagos", "c_mafil", "c_mariquina", "c_paillaco", "c_panguipulli",
                  "c_la_union", "c_futrono", "c_lago_ranco", "c_rio_bueno"),
  r_los_lagos = c("c_quinchao", "c_castro", "c_ancud", "c_chonchi", "c_curaco_de_velez", "c_dalcahue", "c_puqueldon",
                   "c_queilen", "c_quellon", "c_quemchi", "c_rio_negro", "c_osorno", "c_puerto_octay", "c_purranque", "c_puyehue",
                   "c_san_juan_de_la_costa", "c_san_pablo", "c_puerto_montt", "c_calbuco", "c_cochamo", "c_fresia", "c_frutillar", "c_los_muermos", 
                   "c_llanquihue","c_maullin", "c_puerto_varas", "c_chaiten", "c_futaleufu", "c_hualaihue", "c_palena")
  )

# Crear listas para las provincias, donde cada provincia contiene sus comunas
provincias = list(
  p_arica = c("c_arica", "c_camarones"),
  p_parinacota = c("c_putre", "c_general_lagos"),
  p_iquique = c("c_iquique", "c_alto_hospicio"),
  p_el_tamarugal = c("c_pozo_almonte", "c_camina", "c_colchane", "c_huara", "c_pica"),
  ## Región de Antofagasta
  p_antofagasta = c("c_antofagasta", "c_mejillones", "c_taltal" ,"c_sierra_gorda", "c_mejillones/sierra_gorda"),
  p_el_loa = c("c_calama","c_ollague","c_san_pedro_de_atacama", "c_calama/ollague"),
  p_tocopilla = c("c_maria_elena", "c_tocopilla", "c_tocopilla/maria_elena"),
  ## Region de Atacama
  p_chanaral = c("c_chanaral", "c_diego_de_almagro", "c_chanaral/diego_de_almagro"),
  p_copiapo = c("c_caldera", "c_copiapo", "c_tierra_amarilla", "c_copiapo/caldera"),
  p_huasco = c("c_alto_del_carmen", "c_freirina", "c_huasco", "c_vallenar"),
  ## Región de Coquimbo
  p_choapa = c("c_canela", "c_illapel", "c_los_vilos", "c_salamanca"),
  p_elqui = c("c_andacollo", "c_coquimbo","c_la_higuera", "c_la_serena", "c_paiguano", "c_vicuna"),
  p_limari = c("c_combarbala","c_monte_patria", "c_ovalle", "c_punitaqui", "c_rio_hurtado"),
  ## Región de Valparaíso
  p_isla_de_pascua = c("c_isla_de_pascua"),
  p_los_andes = c("c_calle_larga", "c_los_andes", "c_rinconada", "c_san_esteban"),
  p_petorca = c("c_cabildo", "c_la_ligua", "c_papudo", "c_petorca", "c_zapallar"),
  p_quillota = c("c_hijuelas","c_calera", "c_la_cruz", "c_nogales", "c_quillota"),
  p_san_antonio = c("c_algarrobo", "c_cartagena","c_el_quisco", "c_el_tabo", "c_san_antonio",
                     "c_santo_domingo", "c_el_quisco/el_tabo"),
  p_san_felipe = c("c_catemu","c_llaillay", "c_panquehue", "c_putaendo", "c_san_felipe", "c_santa_maria"),
  p_valparaiso = c("c_casablanca", "c_concon", "c_juan_fernandez", "c_puchuncavi", "c_quintero",
                    "c_valparaiso", "c_vina_del_mar", "c_valparaiso/vina_del_mar/_concon"),
  p_marga_marga = c("c_limache", "c_olmue", "c_quilpue", "c_villa_alemana"),
  ## Región metropolitana
  p_chacabuco = c("c_colina", "c_lampa", "c_tiltil"),
  p_cordillera = c("c_pirque", "c_puente_alto", "c_san_jose_de_maipo"), 
  p_maipo = c("c_buin", "c_calera_de_tango", "c_paine", "c_san_bernardo"),
  p_melipilla = c("c_alhue", "c_curacavi","c_maria_pinto", "c_melipilla", "c_san_pedro"),
  p_santiago = c("c_cerrillos", "c_cerro_navia", "c_conchali","c_el_bosque", "c_estacion_central",
                  "c_huechuraba", "c_independencia", "c_la_cisterna","c_la_florida", "c_la_granja",
                  "c_la_pintana", "c_la_reina", "c_las_condes", "c_lo_barnechea","c_lo_espejo", 
                  "c_lo_prado", "c_macul", "c_maipu", "c_nunoa", "c_pedro_aguirre_cerda", "c_penalolen",
                  "c_providencia", "c_pudahuel", "c_quilicura", "c_quinta_normal", "c_recoleta",
                  "c_renca", "c_san_joaquin","c_san_miguel", "c_san_ramon", "c_santiago", "c_vitacura",
                  "c_santiago_sur", "c_santiago_oeste"),
  p_talagante = c( "c_el_monte", "c_isla_de_maipo","c_padre_hurtado", "c_penaflor", "c_talagante"),
    ## Región de Ohiggins
  p_cachapoal = c("c_codegua", "c_coinco", "c_coltauco", "c_donihue", "c_graneros", "c_las_cabras", "c_machali", "c_malloa",
                   "c_mostazal", "c_olivar", "c_peumo", "c_pichidegua", "c_quinta_de_tilcoco", "c_rancagua", "c_rengo",
                   "c_requinoa", "c_san_vicente"),
  p_cardenal_caro = c("c_la_estrella", "c_litueche", "c_marchihue", "c_navidad", "c_paredones",
                       "c_pichilemu"),
  p_colchagua = c("c_chepica", "c_chimbarongo", "c_lolol", "c_nancagua", "c_palmilla", "c_peralillo",
                   "c_placilla", "c_pumanque", "c_san_fernando", "c_santa_cruz"),
  ## Región del Maule 
  p_cauquenes = c("c_cauquenes", "c_chanco", "c_pelluhue"),
  p_curico = c("c_curico", "c_hualane", "c_licanten", "c_molina", "c_rauco",
              "c_romeral", "c_sagrada_familia", "c_teno", "c_vichuquen"),
  p_linares = c("c_colbun", "c_linares", "c_longavi","c_parral", "c_retiro", "c_san_javier",
                 "c_villa_alegre", "c_yerbas_buenas"),
  p_talca = c("c_constitucion","c_curepto", "c_empedrado", "c_maule", "c_pelarco", "c_pencahue", 
               "c_rio_claro", "c_san_clemente","c_san_rafael", "c_talca"),
  ## Region del Bio Bio 
  p_arauco = c("c_arauco", "c_canete", "c_contulmo", "c_curanilahue", "c_lebu", "c_los_alamos","c_tirua"),
  p_biobio = c("c_alto_biobio",
                "c_antuco", "c_cabrero", "c_laja", "c_los_angeles", "c_mulchen", "c_nacimiento",
                "c_negrete", "c_quilaco","c_quilleco", "c_san_rosendo", "c_santa_barbara", "c_tucapel",
                "c_yumbel"),
  p_concepcion = c("c_chiguayante", "c_concepcion","c_coronel", "c_florida", "c_hualpen", "c_hualqui", 
                    "c_lota", "c_penco", "c_san_pedro_de_la_paz", "c_santa_juana","c_talcahuano",
                    "c_tome", "c_chiguayante/hualqui", "c_coronel/lota", "c_talcahuano/hualpen"),
  ### Region del Ñuble Después de 2017
  p_diguillin = c("c_bulnes", "c_chillan", "c_chillan_viejo", "c_el_carmen", "c_pemuco", "c_pinto", "c_quillon",
                   "c_san_ignacio", "c_yungay"),
  p_punilla = c("c_coihueco", "c_niquen", "c_san_carlos", "c_san_fabian", "c_san_nicolas"),
  p_itata = c("c_cobquecura", "c_coelemu", "c_ninhue", "c_portezuelo", "c_quirihue", "c_ranquil",
               "c_treguaco"),
  ### Región de la Araucanía
  p_malleco = c("c_angol", "c_collipulli", "c_curacautin", "c_ercilla", "c_lonquimay", "c_los_sauces", "c_lumaco",
                 "c_puren", "c_renaico", "c_traiguen", "c_victoria"),
  p_cautin = c("c_gorbea", "c_lautaro", "c_loncoche", "c_melipeuco", "c_nueva_imperial", "c_padre_las_casas", "c_perquenco",
                "c_pitrufquen", "c_pucon", "c_saavedra", "c_teodoro_schmidt", "c_tolten", "c_vilcun", "c_villarrica",
                "c_cholchol", "c_temuco", "c_carahue", "c_cunco", "c_curarrehue", "c_freire", "c_galvarino"),
  ### Region de Los Ríos
  p_valdivia = c("c_valdivia", "c_corral", "c_lanco", "c_los_lagos", "c_mafil", "c_mariquina", "c_paillaco", "c_panguipulli"),
  p_ranco = c("c_la_union", "c_futrono", "c_lago_ranco", "c_rio_bueno"),
  ### Región de Los Lagos
  p_chiloe = c("c_quinchao", "c_castro", "c_ancud", "c_chonchi", "c_curaco_de_velez", "c_dalcahue", "c_puqueldon",
                "c_queilen", "c_quellon", "c_quemchi"),
  p_osorno = c("c_rio_negro", "c_osorno", "c_puerto_octay", "c_purranque", "c_puyehue",
                "c_san_juan_de_la_costa", "c_san_pablo"),
  p_llanquihue = c("c_puerto_montt", "c_calbuco", "c_cochamo", "c_fresia", "c_frutillar", "c_los_muermos", "c_llanquihue",
                    "c_maullin", "c_puerto_varas"),
  p_palena = c("c_chaiten", "c_futaleufu", "c_hualaihue", "c_palena")
  
  # Continúa con las demás provincias...
)


#Crear data frame mapping comunas provincias
provincias_df <- lapply(names(provincias), function(provincia) {
  data.frame(
    comuna = provincias[[provincia]],
    provincia = provincia,
    stringsAsFactors = FALSE
  )
}) %>% 
  bind_rows()
