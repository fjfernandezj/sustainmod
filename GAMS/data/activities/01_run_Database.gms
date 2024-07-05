*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   Fondecyt Iniciación - Modelo Oferta 

   Name      :   01_run_Database
   Purpose   :   define model database
   Author    :   Fco. Fernandez
   Date      :   20.02.24
   Since     :   febrero 2024
   CalledBy  :

   Notes     :   Import excel data into gdx
                 Build model database

$offtext
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$onmulti
* Mode database to generate GDX files with base data

$setglobal database on
$setglobal datacheck off

*-------------------------------------------------------------------------------
*
*   Common sets and parameters
*
*-------------------------------------------------------------------------------

set
   reg                'regions and regional aggregates'
   prov               'province'
   comm               'communes'
   act                'activities'
   agg                'crop aggregates'
   sys                'production system'
   tech               'irrigation technologies'  
   var                'variables'             /area,yld,prd/
   comex              'import export'
   map_agg            'mapping aggregates-activities'
   map_reg_comm       'mapping regions-communes'
   map_prov_comm      'mapping provinces-communes'
   map_reg_prov_comm  'mapping regions-provinces-communes'
   map_sys_tech       'mapping system-irrigationtechnologies'  
   yrs                'years 1995-2012'

;

parameter
   p_cropData_2021     'crop management data commune level VIII Censo Nacional Agropecuario año agrícola 2020/2021'
*   p_cropDataPr          'crop management data province level'
*   p_lvstckData          'Livestock management data'
   p_supplyData_2010      'supply data 2010'
*   p_climChange          'impacts of climate change on yields and Cir. Two Scenarios A240-B240'
*   p_climchangePr        'impacts of climate change on yields and Cir (Province leve). Two Scenarios A240-B240'
*   p_comexData           'Export (+) / Imports (-), int_prices (US$/t), local currenct price (clpPrice)Average 1997-2007,'
   p_marketData          'market data'
   p_demandData          'Demand data'
   convf                 'conversion factor actvity - product'
;

$if %database%==on $goto database
$if %datacheck%==on $goto datacheck

$label database
*-------------------------------------------------------------------------------
*
*   Import raw data (from XLS to GDX)
*
*-------------------------------------------------------------------------------

*   ---- auxiliary parameters

parameter
   t_cropData_censo   'crop data'
*   t_costShare         'input use as % of total Cost'
*   t_intPrice          'International Prices (average1997-2007)'
   t_outputPriceReal      'Producer Prices 2010-2020(real Dic 2008)($)'
   t_outputPriceReal_2010 'Producer Prices 2010(real Dic 2008)($)'
   t_outputPriceReal_2011 'Producer Prices 2011(real Dic 2008)($)'
   t_outputPriceReal_2012 'Producer Prices 2012(real Dic 2008)($)'
   t_outputPriceReal_2013 'Producer Prices 2013(real Dic 2008)($)'
   t_outputPriceReal_2014 'Producer Prices 2014(real Dic 2008)($)'
   t_outputPriceReal_2015 'Producer Prices 2015(real Dic 2008)($)'
   t_outputPriceReal_2016 'Producer Prices 2016(real Dic 2008)($)'
   t_outputPriceReal_2017 'Producer Prices 2017(real Dic 2008)($)'
   t_outputPriceReal_2018 'Producer Prices 2018(real Dic 2008)($)'
   t_outputPriceReal_2019 'Producer Prices 2019(real Dic 2008)($)'
   t_outputPriceReal_2020 'Producer Prices 2020(real Dic 2008)($)'

*   t_outputPriceNom    'Producer Prices 1997-2007(Nominal)($)'
*   t_ConsPriceNom      'Consumer Prices (Nominal)($)'
*   t_COnsPriceReal     'Consumer Prices (Real)($)'
   t_selasticities     'supply elasticities'
   t_delasticities     'demand elasticities'
   t_elasticities      'supply and demand elasticities'
*   t_CIR               'Crop Irrigation Requirements mm/h (by AGrimied)'
   t_ttlCost           'Total Cost $/h (Dic 2007)'
*   t_Provcir            'CIR at Province level (average of commune cir)'

;

*   ---- import sets (from xls to gdx)
$call "gdxxrw.exe ..\activities\DataBase_fondecyt.xlsx o=..\sets\setsChile_censo.gdx se=2 index=indexSet!A3"

$gdxin ..\sets\setsChile_censo.gdx
$load  act agg map_agg prov reg sys comm map_reg_comm map_prov_comm map_reg_prov_comm tech map_sys_tech
$gdxin

*   ---- import data (from xls to gdx)
* -- Area, yield, cost, CIR
$call "gdxxrw.exe ..\activities\DataBase_fondecyt.xlsx o=..\activities\production.gdx se=2 index=indexdat!A3"


* -- Precios (Fuente: ODEPA - FAOSTAT)
$call "gdxxrw.exe ..\markets\ProducerPrices_fondecyt.xlsx o=..\markets\ProducerPrices_fondecyt.gdx se=2 index=indexDat!A3"


* -- Elasticidades
$call "gdxxrw.exe ..\markets\Elasticities.xlsx o=..\markets\Elasticities.gdx se=2 index=index!A3"



$gdxin ..\activities\production.gdx
$load  t_cropData_censo
$gdxin

$gdxin ..\markets\ProducerPrices_fondecyt.gdx
$load  t_outputPriceReal
$gdxin

$gdxin ..\markets\Elasticities.gdx
$load  t_selasticities
$gdxin

$gdxin ..\markets\Elasticities.gdx
$load  t_delasticities
$gdxin

$gdxin ..\markets\Elasticities.gdx
$load  t_elasticities
$gdxin


display t_cropData_censo, t_outputPriceReal, t_selasticities, t_delasticities, t_elasticities

;

*-------------------------------------------------------------------------------
*
*   Define model database 2021
*
*-------------------------------------------------------------------------------
*---- total production in 2010 (t/h)
*-------Commune level  ------

**--Area --
p_cropData_2021(reg, prov, comm, agg, act, sys, tech, 'area') = t_cropData_censo(reg, prov, comm, agg, act, sys, tech, 'area');

**--Rendimiento--
p_cropData_2021(reg, prov, comm, agg, act, sys, tech, 'yld') = t_cropData_censo(reg, prov, comm, agg, act, sys, tech, 'yld');

**--Produccion--
p_cropData_2021(reg, prov, comm, agg, act, sys, tech, 'prd')=
     p_cropData_2021(reg, prov, comm, agg, act, sys, tech, 'yld')*p_cropData_2021(reg, prov, comm, agg, act, sys, tech, 'area');

**-- Area Total todos los sistemas todas las tecnologías
p_cropData_2021(reg, prov, comm, agg, act, 'total','tot', 'area')=  p_cropData_2021(reg, prov, comm, agg, act, 'irr','aspersion_movil','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_cobertura_total','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_tazas','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'carrete_de_riego','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'goteo_o_cinta','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'hidroponico','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'microaspersion_o_microjet','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'no_responde','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'otro_tradicional','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'pivote_central_o_avance_frontal','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'dry', 'sin_riego','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'surco','area')+
                                                                p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'tendido','area');

**--Produccion Total todos los sistemas todas las tecnologías --
p_cropData_2021(reg, prov, comm, agg, act, 'total','tot', 'prd')= p_cropData_2021(reg, prov, comm, agg, act, 'irr','aspersion_movil','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_cobertura_total','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_tazas','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'carrete_de_riego','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'goteo_o_cinta','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'hidroponico','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'microaspersion_o_microjet','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'no_responde','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'otro_tradicional','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'pivote_central_o_avance_frontal','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'dry', 'sin_riego','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'surco','prd')+
                                                                         p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'tendido','prd');

** -- Para qué es esto?: Producción por Hectárea?
* p_cropData_2021(reg, prov, comm, agg, act, 'a_total','tot_tech', 'area')$(p_cropData_2021(reg, prov, comm, agg, act, 'a_total','tot_tech', 'prd'))=
* p_cropData_2021(reg, prov, comm, agg, act, 'a_total','tot_tech', 'prd')/p_cropData_2021(reg, prov, comm, agg, act, 'a_total','tot_tech', 'area');


*-----------------Cost per yield 2010 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2021(reg, prov, comm, agg, act, 'irr','aspersion_movil','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr','aspersion_movil','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_cobertura_total','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'aspersion_por_cobertura_total','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'aspersion_por_tazas','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'aspersion_por_tazas','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'carrete_de_riego','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'carrete_de_riego','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'goteo_o_cinta','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'goteo_o_cinta','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'hidroponico','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'hidroponico','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'microaspersion_o_microjet','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'microaspersion_o_microjet','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'no_responde','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'no_responde','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'otro_tradicional','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'otro_tradicional','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'pivote_central_o_avance_frontal','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'pivote_central_o_avance_frontal','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'dry', 'sin_riego','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'dry', 'sin_riego','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'surco','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'surco','Ttl_Cost');
p_cropData_2021(reg, prov, comm, agg, act, 'irr', 'tendido','vcost')= t_cropData_censo(reg, prov, comm, agg, act, 'irr', 'tendido','Ttl_Cost');


display p_cropData_2021;

$exit


p_cropData_2010(reg, comm, act, sys, 'yld') = t_cropData_2010(comm, act, sys, 'yld');

p_cropData_2010(comm, 'Arroz', sys, 'yld')$(p_cropData_2010(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2010(comm, 'Arroz', sys, 'yld');
p_cropData_2010(comm, 'Avena', sys, 'yld')$(p_cropData_2010(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2010(comm, 'Avena', sys, 'yld');
p_cropData_2010(comm,'Maiz', sys, 'yld')$(p_cropData_2010(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2010(comm, 'Maiz', sys, 'yld');
p_cropData_2010(comm, 'Poroto', sys, 'yld')$(p_cropData_2010(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2010(comm,'Poroto', sys, 'yld');
p_cropData_2010(comm, 'Remolacha', sys, 'yld')$(p_cropData_2010(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2010(comm,'Remolacha', sys, 'yld');


p_cropData_2010(comm, act, sys, 'prd')=
     p_cropData_2010(comm, act, sys, 'yld')*p_cropData_2010(comm, act, sys, 'area');


p_cropData_2010(comm, act,'tot','area')= p_cropData_2010(comm, act,'irr','area')+ p_cropData_2010(comm, act,'dry','area');

p_cropData_2010(comm, act,'tot','prd')= p_cropData_2010(comm, act,'irr','prd')+ p_cropData_2010(comm, act,'dry','prd');

p_cropData_2010(comm, act,'tot','yld')$(p_cropData_2010(comm, act,'tot','area'))=
p_cropData_2010(comm, act,'tot','prd')/p_cropData_2010(comm, act,'tot','area');


*-----------------Cost per yield 2010 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2010(comm, act,'irr','vcost')= t_cropData_2010(comm, act,'irr','Ttl_Cost');
p_cropData_2010(comm, act,'dry','vcost')= t_cropData_2010(comm, act,'dry','Ttl_Cost');


*-----------------Revenue 2010 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2010 'average producer price 1997-2007 (real)';
*t_avgeprice_2010(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2010;

p_cropData_2010(comm, act,'irr','srev')$p_cropData_2010(comm, act,'irr','yld')= t_outputPriceReal_2010(act,'2010')*p_cropData_2010(comm, act,'irr','yld');
p_cropData_2010(comm, act,'dry','srev')$p_cropData_2010(comm, act,'dry','yld')= t_outputPriceReal_2010(act,'2010')*p_cropData_2010(comm, act,'dry','yld');


*----------------Gross Margin 2010 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2010(comm, act, sys,'gmar')= P_cropData_2010(comm, act, sys,'srev')- p_cropData_2010(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2010(act,'prd')  = sum((comm,sys),p_cropData_2010(comm, act, sys,'prd'));

p_supplyData_2010(act,'spre')$p_supplyData_2010(act,'prd')= t_outputPriceReal_2010(act,'2010');

p_supplyData_2010(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2010(comm, act, sys,'labor')= t_cropdata_2010(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2010(comm, act,'irr','cir')= t_cropdata_2010(comm, act, 'irr','CIR');

p_cropData_2010(comm, 'Cerezo','irr','cir')= t_cropdata_2010(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Cerezo','irr','cir')$ (p_cropdata_2010(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2010(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2010(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2010(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2010(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2010(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2010(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2010(comm, 'Nogal','irr','cir')= t_cropdata_2010(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Nogal','irr','cir')$ (p_cropdata_2010(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2010(comm, 'Peral','irr','cir')= t_cropdata_2010(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Peral','irr','cir')$ (p_cropdata_2010(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2010(comm, 'Pera asiatica','irr','cir')= t_cropdata_2010(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2010(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2010(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2010(comm, 'Olivo','irr','cir')= t_cropdata_2010(comm, 'Maiz','irr','CIR');
p_cropData_2010(comm, 'Olivo','irr','cir')$ (p_cropdata_2010(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2010(comm, 'Palto','irr','cir')= t_cropdata_2010(comm, 'Naranjo','irr','CIR');
p_cropData_2010(comm, 'Palto','irr','cir')$ (p_cropdata_2010(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2010 ;

*--------------market Data 2010: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata                 ;

*-------------------------------------------------------------------------------
*
*   Define model database 2011
*
*-------------------------------------------------------------------------------
*---- total production in 2011 (t/h)
*-------Commune level  ------
p_cropData_2011(comm, act, sys, 'area') = t_cropData_2011(comm, act, sys, 'area');

p_cropData_2011(comm, act, sys, 'yld') = t_cropData_2011(comm, act, sys, 'yld');

p_cropData_2011(comm, 'Arroz', sys, 'yld')$(p_cropData_2011(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2011(comm, 'Arroz', sys, 'yld');
p_cropData_2011(comm, 'Avena', sys, 'yld')$(p_cropData_2011(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2011(comm, 'Avena', sys, 'yld');
p_cropData_2011(comm,'Maiz', sys, 'yld')$(p_cropData_2011(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2011(comm, 'Maiz', sys, 'yld');
p_cropData_2011(comm, 'Poroto', sys, 'yld')$(p_cropData_2011(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2011(comm,'Poroto', sys, 'yld');
p_cropData_2011(comm, 'Remolacha', sys, 'yld')$(p_cropData_2011(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2011(comm,'Remolacha', sys, 'yld');


p_cropData_2011(comm, act, sys, 'prd')=
     p_cropData_2011(comm, act, sys, 'yld')*p_cropData_2011(comm, act, sys, 'area');


p_cropData_2011(comm, act,'tot','area')= p_cropData_2011(comm, act,'irr','area')+ p_cropData_2011(comm, act,'dry','area');

p_cropData_2011(comm, act,'tot','prd')= p_cropData_2011(comm, act,'irr','prd')+ p_cropData_2011(comm, act,'dry','prd');

p_cropData_2011(comm, act,'tot','yld')$(p_cropData_2011(comm, act,'tot','area'))=
p_cropData_2011(comm, act,'tot','prd')/p_cropData_2011(comm, act,'tot','area');


*-----------------Cost per yield 2011 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2011(comm, act,'irr','vcost')= t_cropData_2011(comm, act,'irr','Ttl_Cost');
p_cropData_2011(comm, act,'dry','vcost')= t_cropData_2011(comm, act,'dry','Ttl_Cost');

*ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2011(comm,'Arroz',sys,'vcost')= p_cropData_2011(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2011('Arroz','2011')-t_outputPriceReal_2010('Arroz','2010')]/t_outputPriceReal_2010('Arroz','2010'));
*Simil maize
p_cropData_2011(comm,'Avena',sys,'vcost')= p_cropData_2011(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2011('Avena','2011')-t_outputPriceReal_2010('Avena','2010')]/t_outputPriceReal_2010('Avena','2010'));

*No disponible
p_cropData_2011(comm,'Cerezo',sys,'vcost')= p_cropData_2011(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2011('Cerezo','2011')-t_outputPriceReal_2010('Cerezo','2010')]/t_outputPriceReal_2010('Cerezo','2010'));
p_cropData_2011(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2011(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2011('Ciruelo europeo','2011')-t_outputPriceReal_2010('Ciruelo europeo','2010')]/t_outputPriceReal_2010('Ciruelo europeo','2010'));
p_cropData_2011(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2011(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2011('Ciruelo japones','2011')-t_outputPriceReal_2010('Ciruelo japones','2010')]/t_outputPriceReal_2010('Ciruelo japones','2010'));
p_cropData_2011(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2011(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2011('Durazno consumo fresco','2011')-t_outputPriceReal_2010('Durazno consumo fresco','2010')]/t_outputPriceReal_2010('Durazno consumo fresco','2010'));

*Frijoles secos
p_cropData_2011(comm,'Poroto',sys,'vcost')= p_cropData_2011(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2011('Poroto','2011')-t_outputPriceReal_2010('Poroto','2010')]/t_outputPriceReal_2010('Poroto','2010'));
p_cropData_2011(comm,'Maiz',sys,'vcost')= p_cropData_2011(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2011('Maiz','2011')-t_outputPriceReal_2010('Maiz','2010')]/t_outputPriceReal_2010('Maiz','2010'));
p_cropData_2011(comm,'Manzano rojo',sys,'vcost')= p_cropData_2011(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2011('Manzano rojo','2011')-t_outputPriceReal_2010('Manzano rojo','2010')]/t_outputPriceReal_2010('Manzano rojo','2010'));
p_cropData_2011(comm,'Manzano verde',sys,'vcost')= p_cropData_2011(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2011('Manzano verde','2011')-t_outputPriceReal_2010('Manzano verde','2010')]/t_outputPriceReal_2010('Manzano verde','2010'));
p_cropData_2011(comm,'Naranjo',sys,'vcost')= p_cropData_2011(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2011('Naranjo','2011')-t_outputPriceReal_2010('Naranjo','2010')]/t_outputPriceReal_2010('Naranjo','2010'));

*Simil apple
p_cropData_2011(comm,'Nogal',sys,'vcost')= p_cropData_2011(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2011('Nogal','2011')-t_outputPriceReal_2010('Nogal','2010')]/t_outputPriceReal_2010('Nogal','2010'));
*Simil Apple
p_cropData_2011(comm,'Olivo',sys,'vcost')= p_cropData_2011(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2011('Olivo','2011')-t_outputPriceReal_2010('Olivo','2010')]/t_outputPriceReal_2010('Olivo','2010'));
p_cropData_2011(comm,'Palto',sys,'vcost')= p_cropData_2011(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2011('Palto','2011')-t_outputPriceReal_2010('Palto','2010')]/t_outputPriceReal_2010('Palto','2010'));
p_cropData_2011(comm,'Papa',sys,'vcost')= p_cropData_2011(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2011('Papa','2011')-t_outputPriceReal_2010('Papa','2010')]/t_outputPriceReal_2010('Papa','2010'));
p_cropData_2011(comm,'Peral',sys,'vcost')= p_cropData_2011(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2011('Peral','2011')-t_outputPriceReal_2010('Peral','2010')]/t_outputPriceReal_2010('Peral','2010'));
p_cropData_2011(comm,'Pera asiatica',sys,'vcost')= p_cropData_2011(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2011('Pera asiatica','2011')-t_outputPriceReal_2010('Pera asiatica','2010')]/t_outputPriceReal_2010('Pera asiatica','2010'));
*Simil wheat
p_cropData_2011(comm,'Remolacha',sys,'vcost')= p_cropData_2011(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2011('Remolacha','2011')-t_outputPriceReal_2010('Remolacha','2010')]/t_outputPriceReal_2010('Remolacha','2010'));
p_cropData_2011(comm,'Trigo',sys,'vcost')= p_cropData_2011(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2011('Trigo','2011')-t_outputPriceReal_2010('Trigo','2010')]/t_outputPriceReal_2010('Trigo','2010'));
p_cropData_2011(comm,'Vid de mesa',sys,'vcost')= p_cropData_2011(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2011('Vid de mesa','2011')-t_outputPriceReal_2010('Vid de mesa','2010')]/t_outputPriceReal_2010('Vid de mesa','2010'));


*-----------------Revenue 2011 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2011 'average producer price 1997-2007 (real)'

*t_avgeprice_2011(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2011;

p_cropData_2011(comm, act,'irr','srev')$p_cropData_2011(comm, act,'irr','yld')= t_outputPriceReal_2011(act,'2011')*p_cropData_2011(comm, act,'irr','yld');
p_cropData_2011(comm, act,'dry','srev')$p_cropData_2011(comm, act,'dry','yld')= t_outputPriceReal_2011(act,'2011')*p_cropData_2011(comm, act,'dry','yld');


*----------------Gross Margin 2011 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2011(comm, act, sys,'gmar')= P_cropData_2011(comm, act, sys,'srev')- p_cropData_2011(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2011(act,'prd')  = sum((comm,sys),p_cropData_2011(comm, act, sys,'prd'));

p_supplyData_2011(act,'spre')$p_supplyData_2011(act,'prd')= t_outputPriceReal_2011(act,'2011');

p_supplyData_2011(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2011(comm, act, sys,'labor')= t_cropdata_2011(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2011(comm, act,'irr','cir')= t_cropdata_2011(comm, act, 'irr','CIR');

p_cropData_2011(comm, 'Cerezo','irr','cir')= t_cropdata_2011(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Cerezo','irr','cir')$ (p_cropdata_2011(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2011(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2011(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2011(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2011(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2011(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2011(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2011(comm, 'Nogal','irr','cir')= t_cropdata_2011(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Nogal','irr','cir')$ (p_cropdata_2011(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2011(comm, 'Peral','irr','cir')= t_cropdata_2011(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Peral','irr','cir')$ (p_cropdata_2011(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2011(comm, 'Pera asiatica','irr','cir')= t_cropdata_2011(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2011(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2011(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2011(comm, 'Olivo','irr','cir')= t_cropdata_2011(comm, 'Maiz','irr','CIR');
p_cropData_2011(comm, 'Olivo','irr','cir')$ (p_cropdata_2011(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2011(comm, 'Palto','irr','cir')= t_cropdata_2011(comm, 'Naranjo','irr','CIR');
p_cropData_2011(comm, 'Palto','irr','cir')$ (p_cropdata_2011(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2011 ;

*--------------market Data 2011: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata      ;

*-------------------------------------------------------------------------------
*
*   Define model database 2013
*
*-------------------------------------------------------------------------------
*---- total production in 2013 (t/h)
*-------Commune level  ------
p_cropData_2013(comm, act, sys, 'area') = t_cropData_2013(comm, act, sys, 'area');

p_cropData_2013(comm, act, sys, 'yld') = t_cropData_2013(comm, act, sys, 'yld');

p_cropData_2013(comm, 'Arroz', sys, 'yld')$(p_cropData_2013(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2013(comm, 'Arroz', sys, 'yld');
p_cropData_2013(comm, 'Avena', sys, 'yld')$(p_cropData_2013(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2013(comm, 'Avena', sys, 'yld');
p_cropData_2013(comm,'Maiz', sys, 'yld')$(p_cropData_2013(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2013(comm, 'Maiz', sys, 'yld');
p_cropData_2013(comm, 'Poroto', sys, 'yld')$(p_cropData_2013(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2013(comm,'Poroto', sys, 'yld');
p_cropData_2013(comm, 'Remolacha', sys, 'yld')$(p_cropData_2013(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2013(comm,'Remolacha', sys, 'yld');


p_cropData_2013(comm, act, sys, 'prd')=
     p_cropData_2013(comm, act, sys, 'yld')*p_cropData_2013(comm, act, sys, 'area');


p_cropData_2013(comm, act,'tot','area')= p_cropData_2013(comm, act,'irr','area')+ p_cropData_2013(comm, act,'dry','area');

p_cropData_2013(comm, act,'tot','prd')= p_cropData_2013(comm, act,'irr','prd')+ p_cropData_2013(comm, act,'dry','prd');

p_cropData_2013(comm, act,'tot','yld')$(p_cropData_2013(comm, act,'tot','area'))=
p_cropData_2013(comm, act,'tot','prd')/p_cropData_2013(comm, act,'tot','area');


*-----------------Cost per yield 2013 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2013(comm, act,'irr','vcost')= t_cropData_2013(comm, act,'irr','Ttl_Cost');
p_cropData_2013(comm, act,'dry','vcost')= t_cropData_2013(comm, act,'dry','Ttl_Cost');

*ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2013(comm,'Arroz',sys,'vcost')= p_cropData_2013(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2013('Arroz','2013')-t_outputPriceReal_2011('Arroz','2011')]/t_outputPriceReal_2011('Arroz','2011'));
*Simil maize
p_cropData_2013(comm,'Avena',sys,'vcost')= p_cropData_2013(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2013('Avena','2013')-t_outputPriceReal_2011('Avena','2011')]/t_outputPriceReal_2011('Avena','2011'));

*No disponible
p_cropData_2013(comm,'Cerezo',sys,'vcost')= p_cropData_2013(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2013('Cerezo','2013')-t_outputPriceReal_2011('Cerezo','2011')]/t_outputPriceReal_2011('Cerezo','2011'));
p_cropData_2013(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2013(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2013('Ciruelo europeo','2013')-t_outputPriceReal_2011('Ciruelo europeo','2011')]/t_outputPriceReal_2011('Ciruelo europeo','2011'));
p_cropData_2013(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2013(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2013('Ciruelo japones','2013')-t_outputPriceReal_2011('Ciruelo japones','2011')]/t_outputPriceReal_2011('Ciruelo japones','2011'));
p_cropData_2013(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2013(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2013('Durazno consumo fresco','2013')-t_outputPriceReal_2011('Durazno consumo fresco','2011')]/t_outputPriceReal_2011('Durazno consumo fresco','2011'));

*Frijoles secos
p_cropData_2013(comm,'Poroto',sys,'vcost')= p_cropData_2013(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2013('Poroto','2013')-t_outputPriceReal_2011('Poroto','2011')]/t_outputPriceReal_2011('Poroto','2011'));
p_cropData_2013(comm,'Maiz',sys,'vcost')= p_cropData_2013(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2013('Maiz','2013')-t_outputPriceReal_2011('Maiz','2011')]/t_outputPriceReal_2011('Maiz','2011'));
p_cropData_2013(comm,'Manzano rojo',sys,'vcost')= p_cropData_2013(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2013('Manzano rojo','2013')-t_outputPriceReal_2011('Manzano rojo','2011')]/t_outputPriceReal_2011('Manzano rojo','2011'));
p_cropData_2013(comm,'Manzano verde',sys,'vcost')= p_cropData_2013(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2013('Manzano verde','2013')-t_outputPriceReal_2011('Manzano verde','2011')]/t_outputPriceReal_2011('Manzano verde','2011'));
p_cropData_2013(comm,'Naranjo',sys,'vcost')= p_cropData_2013(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2013('Naranjo','2013')-t_outputPriceReal_2011('Naranjo','2011')]/t_outputPriceReal_2011('Naranjo','2011'));

*Simil apple
p_cropData_2013(comm,'Nogal',sys,'vcost')= p_cropData_2013(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2013('Nogal','2013')-t_outputPriceReal_2011('Nogal','2011')]/t_outputPriceReal_2011('Nogal','2011'));
*Simil Apple
p_cropData_2013(comm,'Olivo',sys,'vcost')= p_cropData_2013(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2013('Olivo','2013')-t_outputPriceReal_2011('Olivo','2011')]/t_outputPriceReal_2011('Olivo','2011'));
p_cropData_2013(comm,'Palto',sys,'vcost')= p_cropData_2013(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2013('Palto','2013')-t_outputPriceReal_2011('Palto','2011')]/t_outputPriceReal_2011('Palto','2011'));
p_cropData_2013(comm,'Papa',sys,'vcost')= p_cropData_2013(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2013('Papa','2013')-t_outputPriceReal_2011('Papa','2011')]/t_outputPriceReal_2011('Papa','2011'));
p_cropData_2013(comm,'Peral',sys,'vcost')= p_cropData_2013(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2013('Peral','2013')-t_outputPriceReal_2011('Peral','2011')]/t_outputPriceReal_2011('Peral','2011'));
p_cropData_2013(comm,'Pera asiatica',sys,'vcost')= p_cropData_2013(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2013('Pera asiatica','2013')-t_outputPriceReal_2011('Pera asiatica','2011')]/t_outputPriceReal_2011('Pera asiatica','2011'));
*Simil wheat
p_cropData_2013(comm,'Remolacha',sys,'vcost')= p_cropData_2013(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2013('Remolacha','2013')-t_outputPriceReal_2011('Remolacha','2011')]/t_outputPriceReal_2011('Remolacha','2011'));
p_cropData_2013(comm,'Trigo',sys,'vcost')= p_cropData_2013(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2013('Trigo','2013')-t_outputPriceReal_2011('Trigo','2011')]/t_outputPriceReal_2011('Trigo','2011'));
p_cropData_2013(comm,'Vid de mesa',sys,'vcost')= p_cropData_2013(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2013('Vid de mesa','2013')-t_outputPriceReal_2011('Vid de mesa','2011')]/t_outputPriceReal_2011('Vid de mesa','2011'));




*-----------------Revenue 2013 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2013 'average producer price 1997-2007 (real)'

*t_avgeprice_2013(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2013;

p_cropData_2013(comm, act,'irr','srev')$p_cropData_2013(comm, act,'irr','yld')= t_outputPriceReal_2013(act,'2013')*p_cropData_2013(comm, act,'irr','yld');
p_cropData_2013(comm, act,'dry','srev')$p_cropData_2013(comm, act,'dry','yld')= t_outputPriceReal_2013(act,'2013')*p_cropData_2013(comm, act,'dry','yld');


*----------------Gross Margin 2013 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2013(comm, act, sys,'gmar')= P_cropData_2013(comm, act, sys,'srev')- p_cropData_2013(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2013(act,'prd')  = sum((comm,sys),p_cropData_2013(comm, act, sys,'prd'));

p_supplyData_2013(act,'spre')$p_supplyData_2013(act,'prd')= t_outputPriceReal_2013(act,'2013');

p_supplyData_2013(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2013(comm, act, sys,'labor')= t_cropdata_2013(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2013(comm, act,'irr','cir')= t_cropdata_2013(comm, act, 'irr','CIR');

p_cropData_2013(comm, 'Cerezo','irr','cir')= t_cropdata_2013(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Cerezo','irr','cir')$ (p_cropdata_2013(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2013(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2013(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2013(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2013(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2013(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2013(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2013(comm, 'Nogal','irr','cir')= t_cropdata_2013(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Nogal','irr','cir')$ (p_cropdata_2013(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2013(comm, 'Peral','irr','cir')= t_cropdata_2013(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Peral','irr','cir')$ (p_cropdata_2013(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2013(comm, 'Pera asiatica','irr','cir')= t_cropdata_2013(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2013(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2013(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2013(comm, 'Olivo','irr','cir')= t_cropdata_2013(comm, 'Maiz','irr','CIR');
p_cropData_2013(comm, 'Olivo','irr','cir')$ (p_cropdata_2013(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2013(comm, 'Palto','irr','cir')= t_cropdata_2013(comm, 'Naranjo','irr','CIR');
p_cropData_2013(comm, 'Palto','irr','cir')$ (p_cropdata_2013(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2013 ;

*--------------market Data 2013: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata    ;


*-------------------------------------------------------------------------------
*
*   Define model database 2014
*
*-------------------------------------------------------------------------------
*---- total production in 2014 (t/h)
*-------Commune level  ------
p_cropData_2014(comm, act, sys, 'area') = t_cropData_2014(comm, act, sys, 'area');

p_cropData_2014(comm, act, sys, 'yld') = t_cropData_2014(comm, act, sys, 'yld');

p_cropData_2014(comm, 'Arroz', sys, 'yld')$(p_cropData_2014(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2014(comm, 'Arroz', sys, 'yld');
p_cropData_2014(comm, 'Avena', sys, 'yld')$(p_cropData_2014(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2014(comm, 'Avena', sys, 'yld');
p_cropData_2014(comm,'Maiz', sys, 'yld')$(p_cropData_2014(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2014(comm, 'Maiz', sys, 'yld');
p_cropData_2014(comm, 'Poroto', sys, 'yld')$(p_cropData_2014(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2014(comm,'Poroto', sys, 'yld');
p_cropData_2014(comm, 'Remolacha', sys, 'yld')$(p_cropData_2014(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2014(comm,'Remolacha', sys, 'yld');


p_cropData_2014(comm, act, sys, 'prd')=
     p_cropData_2014(comm, act, sys, 'yld')*p_cropData_2014(comm, act, sys, 'area');


p_cropData_2014(comm, act,'tot','area')= p_cropData_2014(comm, act,'irr','area')+ p_cropData_2014(comm, act,'dry','area');

p_cropData_2014(comm, act,'tot','prd')= p_cropData_2014(comm, act,'irr','prd')+ p_cropData_2014(comm, act,'dry','prd');

p_cropData_2014(comm, act,'tot','yld')$(p_cropData_2014(comm, act,'tot','area'))=
p_cropData_2014(comm, act,'tot','prd')/p_cropData_2014(comm, act,'tot','area');


*-----------------Cost per yield 2014 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2014(comm, act,'irr','vcost')= t_cropData_2014(comm, act,'irr','Ttl_Cost');
p_cropData_2014(comm, act,'dry','vcost')= t_cropData_2014(comm, act,'dry','Ttl_Cost');

*ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2014(comm,'Arroz',sys,'vcost')= p_cropData_2014(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2014('Arroz','2014')-t_outputPriceReal_2013('Arroz','2013')]/t_outputPriceReal_2013('Arroz','2013'));
*Simil maize
p_cropData_2014(comm,'Avena',sys,'vcost')= p_cropData_2014(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2014('Avena','2014')-t_outputPriceReal_2013('Avena','2013')]/t_outputPriceReal_2013('Avena','2013'));

*No disponible
p_cropData_2014(comm,'Cerezo',sys,'vcost')= p_cropData_2014(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2014('Cerezo','2014')-t_outputPriceReal_2013('Cerezo','2013')]/t_outputPriceReal_2013('Cerezo','2013'));
p_cropData_2014(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2014(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2014('Ciruelo europeo','2014')-t_outputPriceReal_2013('Ciruelo europeo','2013')]/t_outputPriceReal_2013('Ciruelo europeo','2013'));
p_cropData_2014(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2014(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2014('Ciruelo japones','2014')-t_outputPriceReal_2013('Ciruelo japones','2013')]/t_outputPriceReal_2013('Ciruelo japones','2013'));
p_cropData_2014(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2014(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2014('Durazno consumo fresco','2014')-t_outputPriceReal_2013('Durazno consumo fresco','2013')]/t_outputPriceReal_2013('Durazno consumo fresco','2013'));

*Frijoles secos
p_cropData_2014(comm,'Poroto',sys,'vcost')= p_cropData_2014(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2014('Poroto','2014')-t_outputPriceReal_2013('Poroto','2013')]/t_outputPriceReal_2013('Poroto','2013'));
p_cropData_2014(comm,'Maiz',sys,'vcost')= p_cropData_2014(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2014('Maiz','2014')-t_outputPriceReal_2013('Maiz','2013')]/t_outputPriceReal_2013('Maiz','2013'));
p_cropData_2014(comm,'Manzano rojo',sys,'vcost')= p_cropData_2014(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2014('Manzano rojo','2014')-t_outputPriceReal_2013('Manzano rojo','2013')]/t_outputPriceReal_2013('Manzano rojo','2013'));
p_cropData_2014(comm,'Manzano verde',sys,'vcost')= p_cropData_2014(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2014('Manzano verde','2014')-t_outputPriceReal_2013('Manzano verde','2013')]/t_outputPriceReal_2013('Manzano verde','2013'));
p_cropData_2014(comm,'Naranjo',sys,'vcost')= p_cropData_2014(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2014('Naranjo','2014')-t_outputPriceReal_2013('Naranjo','2013')]/t_outputPriceReal_2013('Naranjo','2013'));

*Simil apple
p_cropData_2014(comm,'Nogal',sys,'vcost')= p_cropData_2014(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2014('Nogal','2014')-t_outputPriceReal_2013('Nogal','2013')]/t_outputPriceReal_2013('Nogal','2013'));
*Simil Apple
p_cropData_2014(comm,'Olivo',sys,'vcost')= p_cropData_2014(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2014('Olivo','2014')-t_outputPriceReal_2013('Olivo','2013')]/t_outputPriceReal_2013('Olivo','2013'));
p_cropData_2014(comm,'Palto',sys,'vcost')= p_cropData_2014(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2014('Palto','2014')-t_outputPriceReal_2013('Palto','2013')]/t_outputPriceReal_2013('Palto','2013'));
p_cropData_2014(comm,'Papa',sys,'vcost')= p_cropData_2014(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2014('Papa','2014')-t_outputPriceReal_2013('Papa','2013')]/t_outputPriceReal_2013('Papa','2013'));
p_cropData_2014(comm,'Peral',sys,'vcost')= p_cropData_2014(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2014('Peral','2014')-t_outputPriceReal_2013('Peral','2013')]/t_outputPriceReal_2013('Peral','2013'));
p_cropData_2014(comm,'Pera asiatica',sys,'vcost')= p_cropData_2014(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2014('Pera asiatica','2014')-t_outputPriceReal_2013('Pera asiatica','2013')]/t_outputPriceReal_2013('Pera asiatica','2013'));
*Simil wheat
p_cropData_2014(comm,'Remolacha',sys,'vcost')= p_cropData_2014(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2014('Remolacha','2014')-t_outputPriceReal_2013('Remolacha','2013')]/t_outputPriceReal_2013('Remolacha','2013'));
p_cropData_2014(comm,'Trigo',sys,'vcost')= p_cropData_2014(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2014('Trigo','2014')-t_outputPriceReal_2013('Trigo','2013')]/t_outputPriceReal_2013('Trigo','2013'));
p_cropData_2014(comm,'Vid de mesa',sys,'vcost')= p_cropData_2014(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2014('Vid de mesa','2014')-t_outputPriceReal_2013('Vid de mesa','2013')]/t_outputPriceReal_2013('Vid de mesa','2013'));




*-----------------Revenue 2014 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2014 'average producer price 1997-2007 (real)'

*t_avgeprice_2014(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2014;

p_cropData_2014(comm, act,'irr','srev')$p_cropData_2014(comm, act,'irr','yld')= t_outputPriceReal_2014(act,'2014')*p_cropData_2014(comm, act,'irr','yld');
p_cropData_2014(comm, act,'dry','srev')$p_cropData_2014(comm, act,'dry','yld')= t_outputPriceReal_2014(act,'2014')*p_cropData_2014(comm, act,'dry','yld');


*----------------Gross Margin 2014 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2014(comm, act, sys,'gmar')= P_cropData_2014(comm, act, sys,'srev')- p_cropData_2014(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2014(act,'prd')  = sum((comm,sys),p_cropData_2014(comm, act, sys,'prd'));

p_supplyData_2014(act,'spre')$p_supplyData_2014(act,'prd')= t_outputPriceReal_2014(act,'2014');

p_supplyData_2014(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2014(comm, act, sys,'labor')= t_cropdata_2014(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2014(comm, act,'irr','cir')= t_cropdata_2014(comm, act, 'irr','CIR');

p_cropData_2014(comm, 'Cerezo','irr','cir')= t_cropdata_2014(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Cerezo','irr','cir')$ (p_cropdata_2014(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2014(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2014(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2014(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2014(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2014(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2014(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2014(comm, 'Nogal','irr','cir')= t_cropdata_2014(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Nogal','irr','cir')$ (p_cropdata_2014(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2014(comm, 'Peral','irr','cir')= t_cropdata_2014(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Peral','irr','cir')$ (p_cropdata_2014(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2014(comm, 'Pera asiatica','irr','cir')= t_cropdata_2014(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2014(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2014(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2014(comm, 'Olivo','irr','cir')= t_cropdata_2014(comm, 'Maiz','irr','CIR');
p_cropData_2014(comm, 'Olivo','irr','cir')$ (p_cropdata_2014(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2014(comm, 'Palto','irr','cir')= t_cropdata_2014(comm, 'Naranjo','irr','CIR');
p_cropData_2014(comm, 'Palto','irr','cir')$ (p_cropdata_2014(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2014 ;

*--------------market Data 2014: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata      ;

*-------------------------------------------------------------------------------
*
*   Define model database 2015
*
*-------------------------------------------------------------------------------
*---- total production in 2015 (t/h)
*-------Commune level  ------
p_cropData_2015(comm, act, sys, 'area') = t_cropData_2015(comm, act, sys, 'area');

p_cropData_2015(comm, act, sys, 'yld') = t_cropData_2015(comm, act, sys, 'yld');

p_cropData_2015(comm, 'Arroz', sys, 'yld')$(p_cropData_2015(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2015(comm, 'Arroz', sys, 'yld');
p_cropData_2015(comm, 'Avena', sys, 'yld')$(p_cropData_2015(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2015(comm, 'Avena', sys, 'yld');
p_cropData_2015(comm,'Maiz', sys, 'yld')$(p_cropData_2015(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2015(comm, 'Maiz', sys, 'yld');
p_cropData_2015(comm, 'Poroto', sys, 'yld')$(p_cropData_2015(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2015(comm,'Poroto', sys, 'yld');
p_cropData_2015(comm, 'Remolacha', sys, 'yld')$(p_cropData_2015(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2015(comm,'Remolacha', sys, 'yld');


p_cropData_2015(comm, act, sys, 'prd')=
     p_cropData_2015(comm, act, sys, 'yld')*p_cropData_2015(comm, act, sys, 'area');


p_cropData_2015(comm, act,'tot','area')= p_cropData_2015(comm, act,'irr','area')+ p_cropData_2015(comm, act,'dry','area');

p_cropData_2015(comm, act,'tot','prd')= p_cropData_2015(comm, act,'irr','prd')+ p_cropData_2015(comm, act,'dry','prd');

p_cropData_2015(comm, act,'tot','yld')$(p_cropData_2015(comm, act,'tot','area'))=
p_cropData_2015(comm, act,'tot','prd')/p_cropData_2015(comm, act,'tot','area');


*-----------------Cost per yield 2015 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2015(comm, act,'irr','vcost')= t_cropData_2015(comm, act,'irr','Ttl_Cost');
p_cropData_2015(comm, act,'dry','vcost')= t_cropData_2015(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2015(comm,'Arroz',sys,'vcost')= p_cropData_2015(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2015('Arroz','2015')-t_outputPriceReal_2014('Arroz','2014')]/t_outputPriceReal_2014('Arroz','2014'));
*Simil maize
p_cropData_2015(comm,'Avena',sys,'vcost')= p_cropData_2015(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2015('Avena','2015')-t_outputPriceReal_2014('Avena','2014')]/t_outputPriceReal_2014('Avena','2014'));

*No disponible
p_cropData_2015(comm,'Cerezo',sys,'vcost')= p_cropData_2015(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2015('Cerezo','2015')-t_outputPriceReal_2014('Cerezo','2014')]/t_outputPriceReal_2014('Cerezo','2014'));
p_cropData_2015(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2015(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2015('Ciruelo europeo','2015')-t_outputPriceReal_2014('Ciruelo europeo','2014')]/t_outputPriceReal_2014('Ciruelo europeo','2014'));
p_cropData_2015(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2015(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2015('Ciruelo japones','2015')-t_outputPriceReal_2014('Ciruelo japones','2014')]/t_outputPriceReal_2014('Ciruelo japones','2014'));
p_cropData_2015(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2015(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2015('Durazno consumo fresco','2015')-t_outputPriceReal_2014('Durazno consumo fresco','2014')]/t_outputPriceReal_2014('Durazno consumo fresco','2014'));

*Frijoles secos
p_cropData_2015(comm,'Poroto',sys,'vcost')= p_cropData_2015(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2015('Poroto','2015')-t_outputPriceReal_2014('Poroto','2014')]/t_outputPriceReal_2014('Poroto','2014'));
p_cropData_2015(comm,'Maiz',sys,'vcost')= p_cropData_2015(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2015('Maiz','2015')-t_outputPriceReal_2014('Maiz','2014')]/t_outputPriceReal_2014('Maiz','2014'));
p_cropData_2015(comm,'Manzano rojo',sys,'vcost')= p_cropData_2015(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2015('Manzano rojo','2015')-t_outputPriceReal_2014('Manzano rojo','2014')]/t_outputPriceReal_2014('Manzano rojo','2014'));
p_cropData_2015(comm,'Manzano verde',sys,'vcost')= p_cropData_2015(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2015('Manzano verde','2015')-t_outputPriceReal_2014('Manzano verde','2014')]/t_outputPriceReal_2014('Manzano verde','2014'));
p_cropData_2015(comm,'Naranjo',sys,'vcost')= p_cropData_2015(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2015('Naranjo','2015')-t_outputPriceReal_2014('Naranjo','2014')]/t_outputPriceReal_2014('Naranjo','2014'));

*Simil apple
p_cropData_2015(comm,'Nogal',sys,'vcost')= p_cropData_2015(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2015('Nogal','2015')-t_outputPriceReal_2014('Nogal','2014')]/t_outputPriceReal_2014('Nogal','2014'));
*Simil Apple
p_cropData_2015(comm,'Olivo',sys,'vcost')= p_cropData_2015(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2015('Olivo','2015')-t_outputPriceReal_2014('Olivo','2014')]/t_outputPriceReal_2014('Olivo','2014'));
p_cropData_2015(comm,'Palto',sys,'vcost')= p_cropData_2015(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2015('Palto','2015')-t_outputPriceReal_2014('Palto','2014')]/t_outputPriceReal_2014('Palto','2014'));
p_cropData_2015(comm,'Papa',sys,'vcost')= p_cropData_2015(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2015('Papa','2015')-t_outputPriceReal_2014('Papa','2014')]/t_outputPriceReal_2014('Papa','2014'));
p_cropData_2015(comm,'Peral',sys,'vcost')= p_cropData_2015(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2015('Peral','2015')-t_outputPriceReal_2014('Peral','2014')]/t_outputPriceReal_2014('Peral','2014'));
p_cropData_2015(comm,'Pera asiatica',sys,'vcost')= p_cropData_2015(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2015('Pera asiatica','2015')-t_outputPriceReal_2014('Pera asiatica','2014')]/t_outputPriceReal_2014('Pera asiatica','2014'));
*Simil wheat
p_cropData_2015(comm,'Remolacha',sys,'vcost')= p_cropData_2015(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2015('Remolacha','2015')-t_outputPriceReal_2014('Remolacha','2014')]/t_outputPriceReal_2014('Remolacha','2014'));
p_cropData_2015(comm,'Trigo',sys,'vcost')= p_cropData_2015(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2015('Trigo','2015')-t_outputPriceReal_2014('Trigo','2014')]/t_outputPriceReal_2014('Trigo','2014'));
p_cropData_2015(comm,'Vid de mesa',sys,'vcost')= p_cropData_2015(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2015('Vid de mesa','2015')-t_outputPriceReal_2014('Vid de mesa','2014')]/t_outputPriceReal_2014('Vid de mesa','2014'));





*-----------------Revenue 2015 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2015 'average producer price 1997-2007 (real)'

*t_avgeprice_2015(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2015;

p_cropData_2015(comm, act,'irr','srev')$p_cropData_2015(comm, act,'irr','yld')= t_outputPriceReal_2015(act,'2015')*p_cropData_2015(comm, act,'irr','yld');
p_cropData_2015(comm, act,'dry','srev')$p_cropData_2015(comm, act,'dry','yld')= t_outputPriceReal_2015(act,'2015')*p_cropData_2015(comm, act,'dry','yld');


*----------------Gross Margin 2015 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2015(comm, act, sys,'gmar')= P_cropData_2015(comm, act, sys,'srev')- p_cropData_2015(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2015(act,'prd')  = sum((comm,sys),p_cropData_2015(comm, act, sys,'prd'));

p_supplyData_2015(act,'spre')$p_supplyData_2015(act,'prd')= t_outputPriceReal_2015(act,'2015');

p_supplyData_2015(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2015(comm, act, sys,'labor')= t_cropdata_2015(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2015(comm, act,'irr','cir')= t_cropdata_2015(comm, act, 'irr','CIR');

p_cropData_2015(comm, 'Cerezo','irr','cir')= t_cropdata_2015(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Cerezo','irr','cir')$ (p_cropdata_2015(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2015(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2015(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2015(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2015(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2015(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2015(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2015(comm, 'Nogal','irr','cir')= t_cropdata_2015(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Nogal','irr','cir')$ (p_cropdata_2015(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2015(comm, 'Peral','irr','cir')= t_cropdata_2015(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Peral','irr','cir')$ (p_cropdata_2015(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2015(comm, 'Pera asiatica','irr','cir')= t_cropdata_2015(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2015(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2015(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2015(comm, 'Olivo','irr','cir')= t_cropdata_2015(comm, 'Maiz','irr','CIR');
p_cropData_2015(comm, 'Olivo','irr','cir')$ (p_cropdata_2015(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2015(comm, 'Palto','irr','cir')= t_cropdata_2015(comm, 'Naranjo','irr','CIR');
p_cropData_2015(comm, 'Palto','irr','cir')$ (p_cropdata_2015(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2015 ;

*--------------market Data 2015: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata        ;

*-------------------------------------------------------------------------------
*
*   Define model database 2016
*
*-------------------------------------------------------------------------------
*---- total production in 2016 (t/h)
*-------Commune level  ------
p_cropData_2016(comm, act, sys, 'area') = t_cropData_2016(comm, act, sys, 'area');

p_cropData_2016(comm, act, sys, 'yld') = t_cropData_2016(comm, act, sys, 'yld');

p_cropData_2016(comm, 'Arroz', sys, 'yld')$(p_cropData_2016(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2016(comm, 'Arroz', sys, 'yld');
p_cropData_2016(comm, 'Avena', sys, 'yld')$(p_cropData_2016(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2016(comm, 'Avena', sys, 'yld');
p_cropData_2016(comm,'Maiz', sys, 'yld')$(p_cropData_2016(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2016(comm, 'Maiz', sys, 'yld');
p_cropData_2016(comm, 'Poroto', sys, 'yld')$(p_cropData_2016(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2016(comm,'Poroto', sys, 'yld');
p_cropData_2016(comm, 'Remolacha', sys, 'yld')$(p_cropData_2016(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2016(comm,'Remolacha', sys, 'yld');


p_cropData_2016(comm, act, sys, 'prd')=
     p_cropData_2016(comm, act, sys, 'yld')*p_cropData_2016(comm, act, sys, 'area');


p_cropData_2016(comm, act,'tot','area')= p_cropData_2016(comm, act,'irr','area')+ p_cropData_2016(comm, act,'dry','area');

p_cropData_2016(comm, act,'tot','prd')= p_cropData_2016(comm, act,'irr','prd')+ p_cropData_2016(comm, act,'dry','prd');

p_cropData_2016(comm, act,'tot','yld')$(p_cropData_2016(comm, act,'tot','area'))=
p_cropData_2016(comm, act,'tot','prd')/p_cropData_2016(comm, act,'tot','area');


*-----------------Cost per yield 2016 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2016(comm, act,'irr','vcost')= t_cropData_2016(comm, act,'irr','Ttl_Cost');
p_cropData_2016(comm, act,'dry','vcost')= t_cropData_2016(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2016(comm,'Arroz',sys,'vcost')= p_cropData_2016(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2016('Arroz','2016')-t_outputPriceReal_2015('Arroz','2015')]/t_outputPriceReal_2015('Arroz','2015'));
*Simil maize
p_cropData_2016(comm,'Avena',sys,'vcost')= p_cropData_2016(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2016('Avena','2016')-t_outputPriceReal_2015('Avena','2015')]/t_outputPriceReal_2015('Avena','2015'));

*No disponible
p_cropData_2016(comm,'Cerezo',sys,'vcost')= p_cropData_2016(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2016('Cerezo','2016')-t_outputPriceReal_2015('Cerezo','2015')]/t_outputPriceReal_2015('Cerezo','2015'));
p_cropData_2016(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2016(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2016('Ciruelo europeo','2016')-t_outputPriceReal_2015('Ciruelo europeo','2015')]/t_outputPriceReal_2015('Ciruelo europeo','2015'));
p_cropData_2016(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2016(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2016('Ciruelo japones','2016')-t_outputPriceReal_2015('Ciruelo japones','2015')]/t_outputPriceReal_2015('Ciruelo japones','2015'));
p_cropData_2016(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2016(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2016('Durazno consumo fresco','2016')-t_outputPriceReal_2015('Durazno consumo fresco','2015')]/t_outputPriceReal_2015('Durazno consumo fresco','2015'));

*Frijoles secos
p_cropData_2016(comm,'Poroto',sys,'vcost')= p_cropData_2016(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2016('Poroto','2016')-t_outputPriceReal_2015('Poroto','2015')]/t_outputPriceReal_2015('Poroto','2015'));
p_cropData_2016(comm,'Maiz',sys,'vcost')= p_cropData_2016(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2016('Maiz','2016')-t_outputPriceReal_2015('Maiz','2015')]/t_outputPriceReal_2015('Maiz','2015'));
p_cropData_2016(comm,'Manzano rojo',sys,'vcost')= p_cropData_2016(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2016('Manzano rojo','2016')-t_outputPriceReal_2015('Manzano rojo','2015')]/t_outputPriceReal_2015('Manzano rojo','2015'));
p_cropData_2016(comm,'Manzano verde',sys,'vcost')= p_cropData_2016(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2016('Manzano verde','2016')-t_outputPriceReal_2015('Manzano verde','2015')]/t_outputPriceReal_2015('Manzano verde','2015'));
p_cropData_2016(comm,'Naranjo',sys,'vcost')= p_cropData_2016(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2016('Naranjo','2016')-t_outputPriceReal_2015('Naranjo','2015')]/t_outputPriceReal_2015('Naranjo','2015'));

*Simil apple
p_cropData_2016(comm,'Nogal',sys,'vcost')= p_cropData_2016(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2016('Nogal','2016')-t_outputPriceReal_2015('Nogal','2015')]/t_outputPriceReal_2015('Nogal','2015'));
*Simil Apple
p_cropData_2016(comm,'Olivo',sys,'vcost')= p_cropData_2016(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2016('Olivo','2016')-t_outputPriceReal_2015('Olivo','2015')]/t_outputPriceReal_2015('Olivo','2015'));
p_cropData_2016(comm,'Palto',sys,'vcost')= p_cropData_2016(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2016('Palto','2016')-t_outputPriceReal_2015('Palto','2015')]/t_outputPriceReal_2015('Palto','2015'));
p_cropData_2016(comm,'Papa',sys,'vcost')= p_cropData_2016(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2016('Papa','2016')-t_outputPriceReal_2015('Papa','2015')]/t_outputPriceReal_2015('Papa','2015'));
p_cropData_2016(comm,'Peral',sys,'vcost')= p_cropData_2016(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2016('Peral','2016')-t_outputPriceReal_2015('Peral','2015')]/t_outputPriceReal_2015('Peral','2015'));
p_cropData_2016(comm,'Pera asiatica',sys,'vcost')= p_cropData_2016(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2016('Pera asiatica','2016')-t_outputPriceReal_2015('Pera asiatica','2015')]/t_outputPriceReal_2015('Pera asiatica','2015'));
*Simil wheat
p_cropData_2016(comm,'Remolacha',sys,'vcost')= p_cropData_2016(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2016('Remolacha','2016')-t_outputPriceReal_2015('Remolacha','2015')]/t_outputPriceReal_2015('Remolacha','2015'));
p_cropData_2016(comm,'Trigo',sys,'vcost')= p_cropData_2016(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2016('Trigo','2016')-t_outputPriceReal_2015('Trigo','2015')]/t_outputPriceReal_2015('Trigo','2015'));
p_cropData_2016(comm,'Vid de mesa',sys,'vcost')= p_cropData_2016(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2016('Vid de mesa','2016')-t_outputPriceReal_2015('Vid de mesa','2015')]/t_outputPriceReal_2015('Vid de mesa','2015'));



*-----------------Revenue 2016 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2016 'average producer price 1997-2007 (real)'

*t_avgeprice_2016(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2016;

p_cropData_2016(comm, act,'irr','srev')$p_cropData_2016(comm, act,'irr','yld')= t_outputPriceReal_2016(act,'2016')*p_cropData_2016(comm, act,'irr','yld');
p_cropData_2016(comm, act,'dry','srev')$p_cropData_2016(comm, act,'dry','yld')= t_outputPriceReal_2016(act,'2016')*p_cropData_2016(comm, act,'dry','yld');


*----------------Gross Margin 2016 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2016(comm, act, sys,'gmar')= P_cropData_2016(comm, act, sys,'srev')- p_cropData_2016(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2016(act,'prd')  = sum((comm,sys),p_cropData_2016(comm, act, sys,'prd'));

p_supplyData_2016(act,'spre')$p_supplyData_2016(act,'prd')= t_outputPriceReal_2016(act,'2016');

p_supplyData_2016(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2016(comm, act, sys,'labor')= t_cropdata_2016(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2016(comm, act,'irr','cir')= t_cropdata_2016(comm, act, 'irr','CIR');

p_cropData_2016(comm, 'Cerezo','irr','cir')= t_cropdata_2016(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Cerezo','irr','cir')$ (p_cropdata_2016(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2016(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2016(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2016(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2016(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2016(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2016(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2016(comm, 'Nogal','irr','cir')= t_cropdata_2016(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Nogal','irr','cir')$ (p_cropdata_2016(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2016(comm, 'Peral','irr','cir')= t_cropdata_2016(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Peral','irr','cir')$ (p_cropdata_2016(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2016(comm, 'Pera asiatica','irr','cir')= t_cropdata_2016(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2016(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2016(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2016(comm, 'Olivo','irr','cir')= t_cropdata_2016(comm, 'Maiz','irr','CIR');
p_cropData_2016(comm, 'Olivo','irr','cir')$ (p_cropdata_2016(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2016(comm, 'Palto','irr','cir')= t_cropdata_2016(comm, 'Naranjo','irr','CIR');
p_cropData_2016(comm, 'Palto','irr','cir')$ (p_cropdata_2016(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2016 ;

*--------------market Data 2016: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata           ;


*-------------------------------------------------------------------------------
*
*   Define model database 2017
*
*-------------------------------------------------------------------------------
*---- total production in 2017 (t/h)
*-------Commune level  ------
p_cropData_2017(comm, act, sys, 'area') = t_cropData_2017(comm, act, sys, 'area');

p_cropData_2017(comm, act, sys, 'yld') = t_cropData_2017(comm, act, sys, 'yld');

p_cropData_2017(comm, 'Arroz', sys, 'yld')$(p_cropData_2017(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2017(comm, 'Arroz', sys, 'yld');
p_cropData_2017(comm, 'Avena', sys, 'yld')$(p_cropData_2017(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2017(comm, 'Avena', sys, 'yld');
p_cropData_2017(comm,'Maiz', sys, 'yld')$(p_cropData_2017(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2017(comm, 'Maiz', sys, 'yld');
p_cropData_2017(comm, 'Poroto', sys, 'yld')$(p_cropData_2017(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2017(comm,'Poroto', sys, 'yld');
p_cropData_2017(comm, 'Remolacha', sys, 'yld')$(p_cropData_2017(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2017(comm,'Remolacha', sys, 'yld');


p_cropData_2017(comm, act, sys, 'prd')=
     p_cropData_2017(comm, act, sys, 'yld')*p_cropData_2017(comm, act, sys, 'area');


p_cropData_2017(comm, act,'tot','area')= p_cropData_2017(comm, act,'irr','area')+ p_cropData_2017(comm, act,'dry','area');

p_cropData_2017(comm, act,'tot','prd')= p_cropData_2017(comm, act,'irr','prd')+ p_cropData_2017(comm, act,'dry','prd');

p_cropData_2017(comm, act,'tot','yld')$(p_cropData_2017(comm, act,'tot','area'))=
p_cropData_2017(comm, act,'tot','prd')/p_cropData_2017(comm, act,'tot','area');


*-----------------Cost per yield 2017 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2017(comm, act,'irr','vcost')= t_cropData_2017(comm, act,'irr','Ttl_Cost');
p_cropData_2017(comm, act,'dry','vcost')= t_cropData_2017(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2017(comm,'Arroz',sys,'vcost')= p_cropData_2017(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2017('Arroz','2017')-t_outputPriceReal_2016('Arroz','2016')]/t_outputPriceReal_2016('Arroz','2016'));
*Simil maize
p_cropData_2017(comm,'Avena',sys,'vcost')= p_cropData_2017(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2017('Avena','2017')-t_outputPriceReal_2016('Avena','2016')]/t_outputPriceReal_2016('Avena','2016'));

*No disponible
p_cropData_2017(comm,'Cerezo',sys,'vcost')= p_cropData_2017(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2017('Cerezo','2017')-t_outputPriceReal_2016('Cerezo','2016')]/t_outputPriceReal_2016('Cerezo','2016'));
p_cropData_2017(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2017(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2017('Ciruelo europeo','2017')-t_outputPriceReal_2016('Ciruelo europeo','2016')]/t_outputPriceReal_2016('Ciruelo europeo','2016'));
p_cropData_2017(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2017(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2017('Ciruelo japones','2017')-t_outputPriceReal_2016('Ciruelo japones','2016')]/t_outputPriceReal_2016('Ciruelo japones','2016'));
p_cropData_2017(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2017(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2017('Durazno consumo fresco','2017')-t_outputPriceReal_2016('Durazno consumo fresco','2016')]/t_outputPriceReal_2016('Durazno consumo fresco','2016'));

*Frijoles secos
p_cropData_2017(comm,'Poroto',sys,'vcost')= p_cropData_2017(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2017('Poroto','2017')-t_outputPriceReal_2016('Poroto','2016')]/t_outputPriceReal_2016('Poroto','2016'));
p_cropData_2017(comm,'Maiz',sys,'vcost')= p_cropData_2017(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2017('Maiz','2017')-t_outputPriceReal_2016('Maiz','2016')]/t_outputPriceReal_2016('Maiz','2016'));
p_cropData_2017(comm,'Manzano rojo',sys,'vcost')= p_cropData_2017(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2017('Manzano rojo','2017')-t_outputPriceReal_2016('Manzano rojo','2016')]/t_outputPriceReal_2016('Manzano rojo','2016'));
p_cropData_2017(comm,'Manzano verde',sys,'vcost')= p_cropData_2017(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2017('Manzano verde','2017')-t_outputPriceReal_2016('Manzano verde','2016')]/t_outputPriceReal_2016('Manzano verde','2016'));
p_cropData_2017(comm,'Naranjo',sys,'vcost')= p_cropData_2017(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2017('Naranjo','2017')-t_outputPriceReal_2016('Naranjo','2016')]/t_outputPriceReal_2016('Naranjo','2016'));

*Simil apple
p_cropData_2017(comm,'Nogal',sys,'vcost')= p_cropData_2017(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2017('Nogal','2017')-t_outputPriceReal_2016('Nogal','2016')]/t_outputPriceReal_2016('Nogal','2016'));
*Simil Apple
p_cropData_2017(comm,'Olivo',sys,'vcost')= p_cropData_2017(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2017('Olivo','2017')-t_outputPriceReal_2016('Olivo','2016')]/t_outputPriceReal_2016('Olivo','2016'));
p_cropData_2017(comm,'Palto',sys,'vcost')= p_cropData_2017(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2017('Palto','2017')-t_outputPriceReal_2016('Palto','2016')]/t_outputPriceReal_2016('Palto','2016'));
p_cropData_2017(comm,'Papa',sys,'vcost')= p_cropData_2017(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2017('Papa','2017')-t_outputPriceReal_2016('Papa','2016')]/t_outputPriceReal_2016('Papa','2016'));
p_cropData_2017(comm,'Peral',sys,'vcost')= p_cropData_2017(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2017('Peral','2017')-t_outputPriceReal_2016('Peral','2016')]/t_outputPriceReal_2016('Peral','2016'));
p_cropData_2017(comm,'Pera asiatica',sys,'vcost')= p_cropData_2017(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2017('Pera asiatica','2017')-t_outputPriceReal_2016('Pera asiatica','2016')]/t_outputPriceReal_2016('Pera asiatica','2016'));
*Simil wheat
p_cropData_2017(comm,'Remolacha',sys,'vcost')= p_cropData_2017(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2017('Remolacha','2017')-t_outputPriceReal_2016('Remolacha','2016')]/t_outputPriceReal_2016('Remolacha','2016'));
p_cropData_2017(comm,'Trigo',sys,'vcost')= p_cropData_2017(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2017('Trigo','2017')-t_outputPriceReal_2016('Trigo','2016')]/t_outputPriceReal_2016('Trigo','2016'));
p_cropData_2017(comm,'Vid de mesa',sys,'vcost')= p_cropData_2017(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2017('Vid de mesa','2017')-t_outputPriceReal_2016('Vid de mesa','2016')]/t_outputPriceReal_2016('Vid de mesa','2016'));



*-----------------Revenue 2017 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2017 'average producer price 1997-2007 (real)'

*t_avgeprice_2017(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2017;

p_cropData_2017(comm, act,'irr','srev')$p_cropData_2017(comm, act,'irr','yld')= t_outputPriceReal_2017(act,'2017')*p_cropData_2017(comm, act,'irr','yld');
p_cropData_2017(comm, act,'dry','srev')$p_cropData_2017(comm, act,'dry','yld')= t_outputPriceReal_2017(act,'2017')*p_cropData_2017(comm, act,'dry','yld');


*----------------Gross Margin 2017 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2017(comm, act, sys,'gmar')= P_cropData_2017(comm, act, sys,'srev')- p_cropData_2017(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2017(act,'prd')  = sum((comm,sys),p_cropData_2017(comm, act, sys,'prd'));

p_supplyData_2017(act,'spre')$p_supplyData_2017(act,'prd')= t_outputPriceReal_2017(act,'2017');

p_supplyData_2017(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2017(comm, act, sys,'labor')= t_cropdata_2017(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2017(comm, act,'irr','cir')= t_cropdata_2017(comm, act, 'irr','CIR');

p_cropData_2017(comm, 'Cerezo','irr','cir')= t_cropdata_2017(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Cerezo','irr','cir')$ (p_cropdata_2017(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2017(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2017(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2017(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2017(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2017(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2017(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2017(comm, 'Nogal','irr','cir')= t_cropdata_2017(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Nogal','irr','cir')$ (p_cropdata_2017(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2017(comm, 'Peral','irr','cir')= t_cropdata_2017(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Peral','irr','cir')$ (p_cropdata_2017(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2017(comm, 'Pera asiatica','irr','cir')= t_cropdata_2017(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2017(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2017(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2017(comm, 'Olivo','irr','cir')= t_cropdata_2017(comm, 'Maiz','irr','CIR');
p_cropData_2017(comm, 'Olivo','irr','cir')$ (p_cropdata_2017(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2017(comm, 'Palto','irr','cir')= t_cropdata_2017(comm, 'Naranjo','irr','CIR');
p_cropData_2017(comm, 'Palto','irr','cir')$ (p_cropdata_2017(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2017 ;

*--------------market Data 2017: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata         ;


*-------------------------------------------------------------------------------
*
*   Define model database 2018
*
*-------------------------------------------------------------------------------
*---- total production in 2018 (t/h)
*-------Commune level  ------
p_cropData_2018(comm, act, sys, 'area') = t_cropData_2018(comm, act, sys, 'area');

p_cropData_2018(comm, act, sys, 'yld') = t_cropData_2018(comm, act, sys, 'yld');

p_cropData_2018(comm, 'Arroz', sys, 'yld')$(p_cropData_2018(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2018(comm, 'Arroz', sys, 'yld');
p_cropData_2018(comm, 'Avena', sys, 'yld')$(p_cropData_2018(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2018(comm, 'Avena', sys, 'yld');
p_cropData_2018(comm,'Maiz', sys, 'yld')$(p_cropData_2018(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2018(comm, 'Maiz', sys, 'yld');
p_cropData_2018(comm, 'Poroto', sys, 'yld')$(p_cropData_2018(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2018(comm,'Poroto', sys, 'yld');
p_cropData_2018(comm, 'Remolacha', sys, 'yld')$(p_cropData_2018(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2018(comm,'Remolacha', sys, 'yld');


p_cropData_2018(comm, act, sys, 'prd')=
     p_cropData_2018(comm, act, sys, 'yld')*p_cropData_2018(comm, act, sys, 'area');


p_cropData_2018(comm, act,'tot','area')= p_cropData_2018(comm, act,'irr','area')+ p_cropData_2018(comm, act,'dry','area');

p_cropData_2018(comm, act,'tot','prd')= p_cropData_2018(comm, act,'irr','prd')+ p_cropData_2018(comm, act,'dry','prd');

p_cropData_2018(comm, act,'tot','yld')$(p_cropData_2018(comm, act,'tot','area'))=
p_cropData_2018(comm, act,'tot','prd')/p_cropData_2018(comm, act,'tot','area');


*-----------------Cost per yield 2018 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2018(comm, act,'irr','vcost')= t_cropData_2018(comm, act,'irr','Ttl_Cost');
p_cropData_2018(comm, act,'dry','vcost')= t_cropData_2018(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2018 de crops y fruits
*No disponible
p_cropData_2018(comm,'Arroz',sys,'vcost')= p_cropData_2018(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2018('Arroz','2018')-t_outputPriceReal_2017('Arroz','2017')]/t_outputPriceReal_2017('Arroz','2017'));
*Simil maize
p_cropData_2018(comm,'Avena',sys,'vcost')= p_cropData_2018(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2018('Avena','2018')-t_outputPriceReal_2017('Avena','2017')]/t_outputPriceReal_2017('Avena','2017'));

*No disponible
p_cropData_2018(comm,'Cerezo',sys,'vcost')= p_cropData_2018(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2018('Cerezo','2018')-t_outputPriceReal_2017('Cerezo','2017')]/t_outputPriceReal_2017('Cerezo','2017'));
p_cropData_2018(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2018(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2018('Ciruelo europeo','2018')-t_outputPriceReal_2017('Ciruelo europeo','2017')]/t_outputPriceReal_2017('Ciruelo europeo','2017'));
p_cropData_2018(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2018(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2018('Ciruelo japones','2018')-t_outputPriceReal_2017('Ciruelo japones','2017')]/t_outputPriceReal_2017('Ciruelo japones','2017'));
p_cropData_2018(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2018(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2018('Durazno consumo fresco','2018')-t_outputPriceReal_2017('Durazno consumo fresco','2017')]/t_outputPriceReal_2017('Durazno consumo fresco','2017'));

*Frijoles secos
p_cropData_2018(comm,'Poroto',sys,'vcost')= p_cropData_2018(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2018('Poroto','2018')-t_outputPriceReal_2017('Poroto','2017')]/t_outputPriceReal_2017('Poroto','2017'));
p_cropData_2018(comm,'Maiz',sys,'vcost')= p_cropData_2018(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2018('Maiz','2018')-t_outputPriceReal_2017('Maiz','2017')]/t_outputPriceReal_2017('Maiz','2017'));
p_cropData_2018(comm,'Manzano rojo',sys,'vcost')= p_cropData_2018(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2018('Manzano rojo','2018')-t_outputPriceReal_2017('Manzano rojo','2017')]/t_outputPriceReal_2017('Manzano rojo','2017'));
p_cropData_2018(comm,'Manzano verde',sys,'vcost')= p_cropData_2018(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2018('Manzano verde','2018')-t_outputPriceReal_2017('Manzano verde','2017')]/t_outputPriceReal_2017('Manzano verde','2017'));
p_cropData_2018(comm,'Naranjo',sys,'vcost')= p_cropData_2018(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2018('Naranjo','2018')-t_outputPriceReal_2017('Naranjo','2017')]/t_outputPriceReal_2017('Naranjo','2017'));

*Simil apple
p_cropData_2018(comm,'Nogal',sys,'vcost')= p_cropData_2018(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2018('Nogal','2018')-t_outputPriceReal_2017('Nogal','2017')]/t_outputPriceReal_2017('Nogal','2017'));
*Simil Apple
p_cropData_2018(comm,'Olivo',sys,'vcost')= p_cropData_2018(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2018('Olivo','2018')-t_outputPriceReal_2017('Olivo','2017')]/t_outputPriceReal_2017('Olivo','2017'));
p_cropData_2018(comm,'Palto',sys,'vcost')= p_cropData_2018(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2018('Palto','2018')-t_outputPriceReal_2017('Palto','2017')]/t_outputPriceReal_2017('Palto','2017'));
p_cropData_2018(comm,'Papa',sys,'vcost')= p_cropData_2018(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2018('Papa','2018')-t_outputPriceReal_2017('Papa','2017')]/t_outputPriceReal_2017('Papa','2017'));
p_cropData_2018(comm,'Peral',sys,'vcost')= p_cropData_2018(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2018('Peral','2018')-t_outputPriceReal_2017('Peral','2017')]/t_outputPriceReal_2017('Peral','2017'));
p_cropData_2018(comm,'Pera asiatica',sys,'vcost')= p_cropData_2018(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2018('Pera asiatica','2018')-t_outputPriceReal_2017('Pera asiatica','2017')]/t_outputPriceReal_2017('Pera asiatica','2017'));
*Simil wheat
p_cropData_2018(comm,'Remolacha',sys,'vcost')= p_cropData_2018(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2018('Remolacha','2018')-t_outputPriceReal_2017('Remolacha','2017')]/t_outputPriceReal_2017('Remolacha','2017'));
p_cropData_2018(comm,'Trigo',sys,'vcost')= p_cropData_2018(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2018('Trigo','2018')-t_outputPriceReal_2017('Trigo','2017')]/t_outputPriceReal_2017('Trigo','2017'));
p_cropData_2018(comm,'Vid de mesa',sys,'vcost')= p_cropData_2018(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2018('Vid de mesa','2018')-t_outputPriceReal_2017('Vid de mesa','2017')]/t_outputPriceReal_2017('Vid de mesa','2017'));



*-----------------Revenue 2018 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2018 'average producer price 1997-2007 (real)'

*t_avgeprice_2018(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2018;

p_cropData_2018(comm, act,'irr','srev')$p_cropData_2018(comm, act,'irr','yld')= t_outputPriceReal_2018(act,'2018')*p_cropData_2018(comm, act,'irr','yld');
p_cropData_2018(comm, act,'dry','srev')$p_cropData_2018(comm, act,'dry','yld')= t_outputPriceReal_2018(act,'2018')*p_cropData_2018(comm, act,'dry','yld');


*----------------Gross Margin 2018 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2018(comm, act, sys,'gmar')= P_cropData_2018(comm, act, sys,'srev')- p_cropData_2018(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2018(act,'prd')  = sum((comm,sys),p_cropData_2018(comm, act, sys,'prd'));

p_supplyData_2018(act,'spre')$p_supplyData_2018(act,'prd')= t_outputPriceReal_2018(act,'2018');

p_supplyData_2018(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2018(comm, act, sys,'labor')= t_cropdata_2018(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2018(comm, act,'irr','cir')= t_cropdata_2018(comm, act, 'irr','CIR');

p_cropData_2018(comm, 'Cerezo','irr','cir')= t_cropdata_2018(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Cerezo','irr','cir')$ (p_cropdata_2018(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2018(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2018(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2018(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2018(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2018(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2018(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2018(comm, 'Nogal','irr','cir')= t_cropdata_2018(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Nogal','irr','cir')$ (p_cropdata_2018(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2018(comm, 'Peral','irr','cir')= t_cropdata_2018(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Peral','irr','cir')$ (p_cropdata_2018(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2018(comm, 'Pera asiatica','irr','cir')= t_cropdata_2018(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2018(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2018(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2018(comm, 'Olivo','irr','cir')= t_cropdata_2018(comm, 'Maiz','irr','CIR');
p_cropData_2018(comm, 'Olivo','irr','cir')$ (p_cropdata_2018(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2018(comm, 'Palto','irr','cir')= t_cropdata_2018(comm, 'Naranjo','irr','CIR');
p_cropData_2018(comm, 'Palto','irr','cir')$ (p_cropdata_2018(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2018 ;

*--------------market Data 2018: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata       ;


*-------------------------------------------------------------------------------
*
*   Define model database 2019
*
*-------------------------------------------------------------------------------
*---- total production in 2019 (t/h)
*-------Commune level  ------
p_cropData_2019(comm, act, sys, 'area') = t_cropData_2019(comm, act, sys, 'area');

p_cropData_2019(comm, act, sys, 'yld') = t_cropData_2019(comm, act, sys, 'yld');

p_cropData_2019(comm, 'Arroz', sys, 'yld')$(p_cropData_2019(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2019(comm, 'Arroz', sys, 'yld');
p_cropData_2019(comm, 'Avena', sys, 'yld')$(p_cropData_2019(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2019(comm, 'Avena', sys, 'yld');
p_cropData_2019(comm,'Maiz', sys, 'yld')$(p_cropData_2019(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2019(comm, 'Maiz', sys, 'yld');
p_cropData_2019(comm, 'Poroto', sys, 'yld')$(p_cropData_2019(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2019(comm,'Poroto', sys, 'yld');
p_cropData_2019(comm, 'Remolacha', sys, 'yld')$(p_cropData_2019(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2019(comm,'Remolacha', sys, 'yld');


p_cropData_2019(comm, act, sys, 'prd')=
     p_cropData_2019(comm, act, sys, 'yld')*p_cropData_2019(comm, act, sys, 'area');


p_cropData_2019(comm, act,'tot','area')= p_cropData_2019(comm, act,'irr','area')+ p_cropData_2019(comm, act,'dry','area');

p_cropData_2019(comm, act,'tot','prd')= p_cropData_2019(comm, act,'irr','prd')+ p_cropData_2019(comm, act,'dry','prd');

p_cropData_2019(comm, act,'tot','yld')$(p_cropData_2019(comm, act,'tot','area'))=
p_cropData_2019(comm, act,'tot','prd')/p_cropData_2019(comm, act,'tot','area');


*-----------------Cost per yield 2019 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2019(comm, act,'irr','vcost')= t_cropData_2019(comm, act,'irr','Ttl_Cost');
p_cropData_2019(comm, act,'dry','vcost')= t_cropData_2019(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2019 de crops y fruits
*No disponible
p_cropData_2019(comm,'Arroz',sys,'vcost')= p_cropData_2019(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2019('Arroz','2019')-t_outputPriceReal_2018('Arroz','2018')]/t_outputPriceReal_2018('Arroz','2018'));
*Simil maize
p_cropData_2019(comm,'Avena',sys,'vcost')= p_cropData_2019(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2019('Avena','2019')-t_outputPriceReal_2018('Avena','2018')]/t_outputPriceReal_2018('Avena','2018'));

*No disponible
p_cropData_2019(comm,'Cerezo',sys,'vcost')= p_cropData_2019(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2019('Cerezo','2019')-t_outputPriceReal_2018('Cerezo','2018')]/t_outputPriceReal_2018('Cerezo','2018'));
p_cropData_2019(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2019(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2019('Ciruelo europeo','2019')-t_outputPriceReal_2018('Ciruelo europeo','2018')]/t_outputPriceReal_2018('Ciruelo europeo','2018'));
p_cropData_2019(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2019(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2019('Ciruelo japones','2019')-t_outputPriceReal_2018('Ciruelo japones','2018')]/t_outputPriceReal_2018('Ciruelo japones','2018'));
p_cropData_2019(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2019(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2019('Durazno consumo fresco','2019')-t_outputPriceReal_2018('Durazno consumo fresco','2018')]/t_outputPriceReal_2018('Durazno consumo fresco','2018'));

*Frijoles secos
p_cropData_2019(comm,'Poroto',sys,'vcost')= p_cropData_2019(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2019('Poroto','2019')-t_outputPriceReal_2018('Poroto','2018')]/t_outputPriceReal_2018('Poroto','2018'));
p_cropData_2019(comm,'Maiz',sys,'vcost')= p_cropData_2019(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2019('Maiz','2019')-t_outputPriceReal_2018('Maiz','2018')]/t_outputPriceReal_2018('Maiz','2018'));
p_cropData_2019(comm,'Manzano rojo',sys,'vcost')= p_cropData_2019(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2019('Manzano rojo','2019')-t_outputPriceReal_2018('Manzano rojo','2018')]/t_outputPriceReal_2018('Manzano rojo','2018'));
p_cropData_2019(comm,'Manzano verde',sys,'vcost')= p_cropData_2019(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2019('Manzano verde','2019')-t_outputPriceReal_2018('Manzano verde','2018')]/t_outputPriceReal_2018('Manzano verde','2018'));
p_cropData_2019(comm,'Naranjo',sys,'vcost')= p_cropData_2019(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2019('Naranjo','2019')-t_outputPriceReal_2018('Naranjo','2018')]/t_outputPriceReal_2018('Naranjo','2018'));

*Simil apple
p_cropData_2019(comm,'Nogal',sys,'vcost')= p_cropData_2019(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2019('Nogal','2019')-t_outputPriceReal_2018('Nogal','2018')]/t_outputPriceReal_2018('Nogal','2018'));
*Simil Apple
p_cropData_2019(comm,'Olivo',sys,'vcost')= p_cropData_2019(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2019('Olivo','2019')-t_outputPriceReal_2018('Olivo','2018')]/t_outputPriceReal_2018('Olivo','2018'));
p_cropData_2019(comm,'Palto',sys,'vcost')= p_cropData_2019(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2019('Palto','2019')-t_outputPriceReal_2018('Palto','2018')]/t_outputPriceReal_2018('Palto','2018'));
p_cropData_2019(comm,'Papa',sys,'vcost')= p_cropData_2019(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2019('Papa','2019')-t_outputPriceReal_2018('Papa','2018')]/t_outputPriceReal_2018('Papa','2018'));
p_cropData_2019(comm,'Peral',sys,'vcost')= p_cropData_2019(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2019('Peral','2019')-t_outputPriceReal_2018('Peral','2018')]/t_outputPriceReal_2018('Peral','2018'));
p_cropData_2019(comm,'Pera asiatica',sys,'vcost')= p_cropData_2019(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2019('Pera asiatica','2019')-t_outputPriceReal_2018('Pera asiatica','2018')]/t_outputPriceReal_2018('Pera asiatica','2018'));
*Simil wheat
p_cropData_2019(comm,'Remolacha',sys,'vcost')= p_cropData_2019(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2019('Remolacha','2019')-t_outputPriceReal_2018('Remolacha','2018')]/t_outputPriceReal_2018('Remolacha','2018'));
p_cropData_2019(comm,'Trigo',sys,'vcost')= p_cropData_2019(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2019('Trigo','2019')-t_outputPriceReal_2018('Trigo','2018')]/t_outputPriceReal_2018('Trigo','2018'));
p_cropData_2019(comm,'Vid de mesa',sys,'vcost')= p_cropData_2019(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2019('Vid de mesa','2019')-t_outputPriceReal_2018('Vid de mesa','2018')]/t_outputPriceReal_2018('Vid de mesa','2018'));



*-----------------Revenue 2019 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2019 'average producer price 1997-2007 (real)'

*t_avgeprice_2019(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2019;

p_cropData_2019(comm, act,'irr','srev')$p_cropData_2019(comm, act,'irr','yld')= t_outputPriceReal_2019(act,'2019')*p_cropData_2019(comm, act,'irr','yld');
p_cropData_2019(comm, act,'dry','srev')$p_cropData_2019(comm, act,'dry','yld')= t_outputPriceReal_2019(act,'2019')*p_cropData_2019(comm, act,'dry','yld');


*----------------Gross Margin 2019 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2019(comm, act, sys,'gmar')= P_cropData_2019(comm, act, sys,'srev')- p_cropData_2019(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2019(act,'prd')  = sum((comm,sys),p_cropData_2019(comm, act, sys,'prd'));

p_supplyData_2019(act,'spre')$p_supplyData_2019(act,'prd')= t_outputPriceReal_2019(act,'2019');

p_supplyData_2019(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2019(comm, act, sys,'labor')= t_cropdata_2019(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2019(comm, act,'irr','cir')= t_cropdata_2019(comm, act, 'irr','CIR');

p_cropData_2019(comm, 'Cerezo','irr','cir')= t_cropdata_2019(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Cerezo','irr','cir')$ (p_cropdata_2019(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2019(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2019(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2019(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2019(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2019(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2019(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2019(comm, 'Nogal','irr','cir')= t_cropdata_2019(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Nogal','irr','cir')$ (p_cropdata_2019(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2019(comm, 'Peral','irr','cir')= t_cropdata_2019(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Peral','irr','cir')$ (p_cropdata_2019(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2019(comm, 'Pera asiatica','irr','cir')= t_cropdata_2019(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2019(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2019(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2019(comm, 'Olivo','irr','cir')= t_cropdata_2019(comm, 'Maiz','irr','CIR');
p_cropData_2019(comm, 'Olivo','irr','cir')$ (p_cropdata_2019(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2019(comm, 'Palto','irr','cir')= t_cropdata_2019(comm, 'Naranjo','irr','CIR');
p_cropData_2019(comm, 'Palto','irr','cir')$ (p_cropdata_2019(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2019 ;

*--------------market Data 2019: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');

display p_marketdata        ;




*-------------------------------------------------------------------------------
*
*   Define model database 2020
*
*-------------------------------------------------------------------------------
*---- total production in 2020 (t/h)
*-------Commune level  ------
p_cropData_2020(comm, act, sys, 'area') = t_cropData_2020(comm, act, sys, 'area');

p_cropData_2020(comm, act, sys, 'yld') = t_cropData_2020(comm, act, sys, 'yld');

p_cropData_2020(comm, 'Arroz', sys, 'yld')$(p_cropData_2020(comm, 'Arroz', sys, 'area'))=
(1/10)* p_cropData_2020(comm, 'Arroz', sys, 'yld');
p_cropData_2020(comm, 'Avena', sys, 'yld')$(p_cropData_2020(comm, 'Avena', sys, 'area'))=
(1/10)* p_cropData_2020(comm, 'Avena', sys, 'yld');
p_cropData_2020(comm,'Maiz', sys, 'yld')$(p_cropData_2020(comm, 'Maiz', sys, 'area'))=
(1/10)* p_cropData_2020(comm, 'Maiz', sys, 'yld');
p_cropData_2020(comm, 'Poroto', sys, 'yld')$(p_cropData_2020(comm,'Poroto', sys, 'area'))=
(1/10)* p_cropData_2020(comm,'Poroto', sys, 'yld');
p_cropData_2020(comm, 'Remolacha', sys, 'yld')$(p_cropData_2020(comm,'Remolacha', sys, 'area'))=
(1/10)* p_cropData_2020(comm,'Remolacha', sys, 'yld');


p_cropData_2020(comm, act, sys, 'prd')=
     p_cropData_2020(comm, act, sys, 'yld')*p_cropData_2020(comm, act, sys, 'area');


p_cropData_2020(comm, act,'tot','area')= p_cropData_2020(comm, act,'irr','area')+ p_cropData_2020(comm, act,'dry','area');

p_cropData_2020(comm, act,'tot','prd')= p_cropData_2020(comm, act,'irr','prd')+ p_cropData_2020(comm, act,'dry','prd');

p_cropData_2020(comm, act,'tot','yld')$(p_cropData_2020(comm, act,'tot','area'))=
p_cropData_2020(comm, act,'tot','prd')/p_cropData_2020(comm, act,'tot','area');


*-----------------Cost per yield 2020 ($/h) ($ Dic 2007)-----------------
*------------------Even if the commune doesnt grown the crop---------

p_cropData_2020(comm, act,'irr','vcost')= t_cropData_2020(comm, act,'irr','Ttl_Cost');
p_cropData_2020(comm, act,'dry','vcost')= t_cropData_2020(comm, act,'dry','Ttl_Cost');

**ACTUALIZACION vcost con variaciones de precios de FAO 2007 a 2020 de crops y fruits
*No disponible
p_cropData_2020(comm,'Arroz',sys,'vcost')= p_cropData_2020(comm,'Arroz',sys,'vcost')*(1+[t_outputPriceReal_2020('Arroz','2020')-t_outputPriceReal_2019('Arroz','2019')]/t_outputPriceReal_2019('Arroz','2019'));
*Simil maize
p_cropData_2020(comm,'Avena',sys,'vcost')= p_cropData_2020(comm,'Avena',sys,'vcost')*(1+[t_outputPriceReal_2020('Avena','2020')-t_outputPriceReal_2019('Avena','2019')]/t_outputPriceReal_2019('Avena','2019'));

*No disponible
p_cropData_2020(comm,'Cerezo',sys,'vcost')= p_cropData_2020(comm,'Cerezo',sys,'vcost')*(1+[t_outputPriceReal_2020('Cerezo','2020')-t_outputPriceReal_2019('Cerezo','2019')]/t_outputPriceReal_2019('Cerezo','2019'));
p_cropData_2020(comm,'Ciruelo europeo',sys,'vcost')= p_cropData_2020(comm,'Ciruelo europeo',sys,'vcost')*(1+[t_outputPriceReal_2020('Ciruelo europeo','2020')-t_outputPriceReal_2019('Ciruelo europeo','2019')]/t_outputPriceReal_2019('Ciruelo europeo','2019'));
p_cropData_2020(comm,'Ciruelo japones',sys,'vcost')= p_cropData_2020(comm,'Ciruelo japones',sys,'vcost')*(1+[t_outputPriceReal_2020('Ciruelo japones','2020')-t_outputPriceReal_2019('Ciruelo japones','2019')]/t_outputPriceReal_2019('Ciruelo japones','2019'));
p_cropData_2020(comm,'Durazno consumo fresco',sys,'vcost')= p_cropData_2020(comm,'Durazno consumo fresco',sys,'vcost')*(1+[t_outputPriceReal_2020('Durazno consumo fresco','2020')-t_outputPriceReal_2019('Durazno consumo fresco','2019')]/t_outputPriceReal_2019('Durazno consumo fresco','2019'));

*Frijoles secos
p_cropData_2020(comm,'Poroto',sys,'vcost')= p_cropData_2020(comm,'Poroto',sys,'vcost')*(1+[t_outputPriceReal_2020('Poroto','2020')-t_outputPriceReal_2019('Poroto','2019')]/t_outputPriceReal_2019('Poroto','2019'));
p_cropData_2020(comm,'Maiz',sys,'vcost')= p_cropData_2020(comm,'Maiz',sys,'vcost')*(1+[t_outputPriceReal_2020('Maiz','2020')-t_outputPriceReal_2019('Maiz','2019')]/t_outputPriceReal_2019('Maiz','2019'));
p_cropData_2020(comm,'Manzano rojo',sys,'vcost')= p_cropData_2020(comm,'Manzano rojo',sys,'vcost')*(1+[t_outputPriceReal_2020('Manzano rojo','2020')-t_outputPriceReal_2019('Manzano rojo','2019')]/t_outputPriceReal_2019('Manzano rojo','2019'));
p_cropData_2020(comm,'Manzano verde',sys,'vcost')= p_cropData_2020(comm,'Manzano verde',sys,'vcost')*(1+[t_outputPriceReal_2020('Manzano verde','2020')-t_outputPriceReal_2019('Manzano verde','2019')]/t_outputPriceReal_2019('Manzano verde','2019'));
p_cropData_2020(comm,'Naranjo',sys,'vcost')= p_cropData_2020(comm,'Naranjo',sys,'vcost')*(1+[t_outputPriceReal_2020('Naranjo','2020')-t_outputPriceReal_2019('Naranjo','2019')]/t_outputPriceReal_2019('Naranjo','2019'));

*Simil apple
p_cropData_2020(comm,'Nogal',sys,'vcost')= p_cropData_2020(comm,'Nogal',sys,'vcost')*(1+[t_outputPriceReal_2020('Nogal','2020')-t_outputPriceReal_2019('Nogal','2019')]/t_outputPriceReal_2019('Nogal','2019'));
*Simil Apple
p_cropData_2020(comm,'Olivo',sys,'vcost')= p_cropData_2020(comm,'Olivo',sys,'vcost')*(1+[t_outputPriceReal_2020('Olivo','2020')-t_outputPriceReal_2019('Olivo','2019')]/t_outputPriceReal_2019('Olivo','2019'));
p_cropData_2020(comm,'Palto',sys,'vcost')= p_cropData_2020(comm,'Palto',sys,'vcost')*(1+[t_outputPriceReal_2020('Palto','2020')-t_outputPriceReal_2019('Palto','2019')]/t_outputPriceReal_2019('Palto','2019'));
p_cropData_2020(comm,'Papa',sys,'vcost')= p_cropData_2020(comm,'Papa',sys,'vcost')*(1+[t_outputPriceReal_2020('Papa','2020')-t_outputPriceReal_2019('Papa','2019')]/t_outputPriceReal_2019('Papa','2019'));
p_cropData_2020(comm,'Peral',sys,'vcost')= p_cropData_2020(comm,'Peral',sys,'vcost')*(1+[t_outputPriceReal_2020('Peral','2020')-t_outputPriceReal_2019('Peral','2019')]/t_outputPriceReal_2019('Peral','2019'));
p_cropData_2020(comm,'Pera asiatica',sys,'vcost')= p_cropData_2020(comm,'Pera asiatica',sys,'vcost')*(1+[t_outputPriceReal_2020('Pera asiatica','2020')-t_outputPriceReal_2019('Pera asiatica','2019')]/t_outputPriceReal_2019('Pera asiatica','2019'));
*Simil wheat
p_cropData_2020(comm,'Remolacha',sys,'vcost')= p_cropData_2020(comm,'Remolacha',sys,'vcost')*(1+[t_outputPriceReal_2020('Remolacha','2020')-t_outputPriceReal_2019('Remolacha','2019')]/t_outputPriceReal_2019('Remolacha','2019'));
p_cropData_2020(comm,'Trigo',sys,'vcost')= p_cropData_2020(comm,'Trigo',sys,'vcost')*(1+[t_outputPriceReal_2020('Trigo','2020')-t_outputPriceReal_2019('Trigo','2019')]/t_outputPriceReal_2019('Trigo','2019'));
p_cropData_2020(comm,'Vid de mesa',sys,'vcost')= p_cropData_2020(comm,'Vid de mesa',sys,'vcost')*(1+[t_outputPriceReal_2020('Vid de mesa','2020')-t_outputPriceReal_2019('Vid de mesa','2019')]/t_outputPriceReal_2019('Vid de mesa','2019'));




*-----------------Revenue 2020 ($/h) ($ Dic 2007)------------------
*parameter t_avgeprice_2020 'average producer price 1997-2007 (real)'

*t_avgeprice_2020(act,'avge')$(sum(yrs,1$t_outputPriceReal(act,yrs)) gt 0)=sum(yrs,t_outputPriceReal(act,yrs))/sum(yrs,1$t_outputPriceReal(act,yrs)) ;

*display t_avgeprice_2020;

p_cropData_2020(comm, act,'irr','srev')$p_cropData_2020(comm, act,'irr','yld')= t_outputPriceReal_2020(act,'2020')*p_cropData_2020(comm, act,'irr','yld');
p_cropData_2020(comm, act,'dry','srev')$p_cropData_2020(comm, act,'dry','yld')= t_outputPriceReal_2020(act,'2020')*p_cropData_2020(comm, act,'dry','yld');


*----------------Gross Margin 2020 ($/h) ($ Dic 2007)----------------
*------Comune---

p_cropData_2020(comm, act, sys,'gmar')= P_cropData_2020(comm, act, sys,'srev')- p_cropData_2020(comm, act, sys,'vcost');

*   ---- supply data: elasticities, production and producer prices ($ Dic 2007)--------
p_supplyData_2020(act,'prd')  = sum((comm,sys),p_cropData_2020(comm, act, sys,'prd'));

p_supplyData_2020(act,'spre')$p_supplyData_2020(act,'prd')= t_outputPriceReal_2020(act,'2020');

p_supplyData_2020(act,'selast')= t_elasticities(act,'selas');

*--------------labor demand: workers/h----------
*--------Comune-----
p_cropData_2020(comm, act, sys,'labor')= t_cropdata_2020(comm, act, sys,'labor');

*----------------Crop Irrigation requirements at the Base Line(th m3/h/yr)---------
*------Comune level----
p_cropData_2020(comm, act,'irr','cir')= t_cropdata_2020(comm, act, 'irr','CIR');

p_cropData_2020(comm, 'Cerezo','irr','cir')= t_cropdata_2020(comm,'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Cerezo','irr','cir')$ (p_cropdata_2020(comm,'Cerezo','irr','area') > 0) = 8 ;

p_cropData_2020(comm, 'Ciruelo europeo','irr','cir')= t_cropdata_2020(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Ciruelo europeo','irr','cir')$ (p_cropdata_2020(comm,'Ciruelo europeo','irr','area') > 0) = 8 ;


p_cropData_2020(comm, 'Ciruelo japones','irr','cir')= t_cropdata_2020(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Ciruelo japones','irr','cir')$ (p_cropdata_2020(comm,'Ciruelo japones','irr','area') > 0) = 8 ;

p_cropData_2020(comm, 'Nogal','irr','cir')= t_cropdata_2020(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Nogal','irr','cir')$ (p_cropdata_2020(comm,'Nogal','irr','area') > 0) = 8 ;

p_cropData_2020(comm, 'Peral','irr','cir')= t_cropdata_2020(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Peral','irr','cir')$ (p_cropdata_2020(comm,'Peral','irr','area') > 0) = 8 ;

p_cropData_2020(comm, 'Pera asiatica','irr','cir')= t_cropdata_2020(comm, 'Duraznero consumo fresco','irr','CIR');
p_cropData_2020(comm, 'Pera asiatica','irr','cir')$ (p_cropdata_2020(comm,'Pera asiatica','irr','area') > 0) = 8 ;


p_cropData_2020(comm, 'Olivo','irr','cir')= t_cropdata_2020(comm, 'Maiz','irr','CIR');
p_cropData_2020(comm, 'Olivo','irr','cir')$ (p_cropdata_2020(comm,'Olivo','irr','area') > 0) = 5 ;

p_cropData_2020(comm, 'Palto','irr','cir')= t_cropdata_2020(comm, 'Naranjo','irr','CIR');
p_cropData_2020(comm, 'Palto','irr','cir')$ (p_cropdata_2020(comm,'Palto','irr','area') > 0) = 10 ;

Display p_cropdata_2020 ;

*--------------market Data 2020: Elasticities--------------*
p_marketdata(act,'selast')= t_elasticities(act,'selas');





*   ---- create gdx file with model data
execute_unload '..\results\Chile_db_megasequia.gdx' p_cropData_2010  p_cropData_2011  p_cropData_2013  p_cropData_2014  p_cropData_2015  p_cropData_2016
                                                                          p_cropData_2017  p_cropData_2018  p_cropData_2019  p_cropData_2020 p_marketdata p_supplyData_2010
                                                                          p_supplyData_2011  p_supplyData_2013  p_supplyData_2014  p_supplyData_2015  p_supplyData_2016  p_supplyData_2017
                                                                           p_supplyData_2018  p_supplyData_2019 p_supplyData_2020;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2010 rng=cropData2010!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2011 rng=cropData2011!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2013 rng=cropData2013!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2014 rng=cropData2014!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2015 rng=cropData2015!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2016 rng=cropData2016!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2017 rng=cropData2017!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2018 rng=cropData2018!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2019 rng=cropData2019!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_cropData_2020 rng=cropData2020!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_marketdata rng=marketData2010!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2010 rng=supplyData2010!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2011 rng=supplyData2011!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2013 rng=supplyData2013!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2014 rng=supplyData2014!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2015 rng=supplyData2015!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2016 rng=supplyData2016!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2017 rng=supplyData2017!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2018 rng=supplyData2018!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2019 rng=supplyData2019!A1' ;
execute 'gdxxrw.exe ..\results\Chile_db_megasequia.gdx o=..\results\Chile_db_megasequia.xlsx par=p_supplyData_2020 rng=supplyData2020!A1' ;
