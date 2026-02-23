*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   Chilean MMM

   Name      :   sets_sustainmod.gms
   Purpose   :   general sets and mappings
   Author    :   Francisco Fernandez
   Date      :   16 sept 2021
   Since     :   sept 2021
   CalledBy  :   04_load_baseDataChile_megasequia

   Notes     :

$offtext
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$onmulti

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*  COMMON SETS AND MAPPINGS                                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

set
   reg                'regions and regional aggregates'
   prov               'province'
   comm               'communes'
   act                'activities'
   agg                'crop aggregates'
   sys                'production system'
   tech               'irrigation technologies'  
   var                'variables'             /area,tot,yld,prd,vcost,srev,gmar,cir,kg,selast,delast,spre,dpre,Export,Import,CLPip,
                                     CLPep,CCyld,cons,labor/
   comex              'import export'
   map_agg            'mapping aggregates-activities'
   map_reg_comm       'mapping regions-communes'
   map_prov_comm      'mapping provinces-communes'
   map_reg_prov_comm  'mapping regions-provinces-communes'
   map_sys_tech       'mapping system-irrigationtechnologies'  
   yrs                'years 1995-2012'

;

*   ---- activity groups and families
*   ---- current activities
set
  map_cas_2021   'mapping communes-activities-systems 2021'


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*  SETS DEFINITION                                                             *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

$GDXIN ..\data\sets\02_setsChile_censo.gdx
$LOAD reg prov comm agg act sys tech map_agg  prov map_reg_comm map_prov_comm map_reg_prov_comm
$GDXIN

display act



*   ---- subsets
set
   r(reg)    'regions and regional aggregates'
   c(comm)   'communes and regional aggregates'
   pr(prov)  'provinces'
   ag(agg)   'crop aggregates'
   s(sys)    'production system'     
   t(tech)   'irrigation technologies'
  




   crp(act)  'crop activities'
                                /avena_c,
                                cebada_c,
                                maiz_c,
                                trigo,
                                avena_f,
                                ballica,
                                trebol,
                                acelga,
                                arveja_verde,
                                choclo,
                                cilantro,
                                haba,
                                lechuga,
                                poroto_h,
                                poroto_verde,
                                tomate_h,
                                zanahoria,
                                arveja_grano_seco,
                                lenteja,
                                papa,
                                poroto_l,
                                alfalfa,
                                maiz_f,
                                remolacha,
                                tomate_i,
                                cebada_f,
                                cebolla,
                                esparrago,
                                festuca,
                                alcachofa,
                                brocoli,
                                coliflor,
                                espinaca,
                                pepino,
                                pimiento,
                                repollo,
                                apio,
                                ajo,
                                arroz,
                                duraznero,
                                aji,
                                melon,
                                sandia,
                                zapallo,
                                garbanzo,
                                betarraga,
                                zapallo_italiano,
                                arveja_forrajera/
                                
   frt(act)  'fruits activities'
                                /cerezo,
                                manzana,
                                nogal,
                                avellano_europeo,
                                uva_de_mesa,
                                mandarina,
                                almendro,
                                damasco,
                                limonero,
                                naranjo,
                                olivo,
                                palto,
                                duraznero,
                                ciruelo,
                                kiwi,
                                pera/
                                
    a(act)     'activities to be modeled'

;

    r(reg)=yes;
    c(comm)=yes;
    pr(prov)=yes;
    ag(agg)=yes;
    a(act)= crp(act)+ frt(act) ;
    s(sys)= yes;
    t(tech) = yes;


*   ---- sets including aggregates
set Rtot 'regions including totals'  /set.reg,Chile/
;


