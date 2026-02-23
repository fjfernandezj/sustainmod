*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   Chilean MMM

   Name      :   03_load_base_data_sustainmod.gms
   Purpose   :   Base model data definition
   Author    :   Francisco Fernandez
   Date      :   Sept 2021
   Since     :   Sept 2021
   CalledBy  :   run1_calPMP

   Notes     :   load gdx data + parameters definition

$offtext
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                         SETS AND PARAMETERS                                  *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*~~~~~~~~  sets and parameters declaration   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

$onGlobal

*$include "C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\data\sets\02_setsChile_censo.gms"

$include "C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\data\sets_sustainmod.gms"
$include "C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\data\02_pars_Chile_sustainmod.gms"

*;
$offGlobal


*~~~~~~~~  original data (comming from data folder) ~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*execute_load "C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\results\sustainmod.gdx"
*p_cropData_2021;

$GDXIN "C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\results\sustainmod.gdx"
$LOAD   p_cropData_2021
$LOAD   p_marketData
$LOAD   p_supplyData_2021
$GDXIN



display p_cropData_2021;


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                         DEFINE MODEL DATA                                    *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ---- crop area (ha) (only activities with gmar >0) commune level-----
x0_2021(r,pr,c,ag,a,s,t, 'tot')$(p_cropData_2021(r,pr,c,ag,a,s,t,'gmar') gt 0)= p_cropData_2021(r,pr,c,ag,a,s,t,'area');


display x0_2021;

*---- Total area (ha) por comuna:
tland_2021(c) = 
   sum((r,pr,ag,a,s,t),
       x0_2021(r,pr,c,ag,a,s,t,'tot')
   );

*---- Área irrigada (ha) por comuna:
iland_2021(c) =
  sum((r,pr,ag,a,t),
      x0_2021(r,pr,c,ag,a,'irr',t,'tot')
  );

*   ---- crop data commune
yld_2021(r,pr,c,ag,a,s,t)= p_cropData_2021(r,pr,c,ag,a,s,t,'yld');
lab_2021(r,pr,c,ag,a,s,t)= p_cropData_2021(r,pr,c,ag,a,s,t,'labor');


*   ---- market data
selas_2021(a) = p_marketdata(a,'selast');



*   ---- supply data
*---- Prices in mill CLP, Qtty in ton
ps0_2021(a) = (1/1000000)*p_supplyData_2021(a,'sPre');

*----  Qtty in ton
qs0_2021(a) =
   sum((r,pr,c,ag,s,t),
       yld_2021(r,pr,c,ag,a,s,t)
     * x0_2021(r,pr,c,ag,a,s,t,'tot')
   );


*   ---- water data
*  water requirements commune (th m3/h/yr)
fir_2021(r,pr,c,ag,a,'irr',t) = p_cropData_2021(r,pr,c,ag,a,'irr',t,'cir');

hd(c) = 0.6 ;

gir_2021(r,pr,c,ag,a,'irr',t) = fir_2021(r,pr,c,ag,a,'irr',t)/hd(c);


* => water delivery
w0_2021(c) = 
    sum((r,pr,ag,a,t),
        gir_2021(r,pr,c,ag,a,'irr',t)
      * x0_2021(r,pr,c,ag,a,'irr',t,'tot')
    );

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                  AGREGADOS DE ENTREGA DE AGUA 2021                          *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

Parameter
   w0_provincia_2021(reg,prov)   'agua entregada por provincia (th m3) en 2021'
   w0_regional_2021  (reg)     'agua entregada por región (th m3) en 2021'
   w0_nacional_2021         'agua total nacional (th m3) en 2021'
;

*--  Nivel Provincia: suma comunas según mapeo provincia–comuna
w0_provincia_2021(r,pr) = 
    sum(c$(map_reg_prov_comm(r,pr,c)),
        w0_2021(c)
    );

*--  Nivel Región: suma provincias
w0_regional_2021(r) = 
    sum(pr,
        w0_provincia_2021(r,pr)
    );

*--  Nivel Nacional: suma regiones
w0_nacional_2021 = 
    sum(r,
        w0_regional_2021(r)
    );

display w0_provincia_2021, w0_regional_2021, w0_nacional_2021;


Parameter
   watuse_comm_2021(comm,act)  'agua usada por comuna y actividad en 2021'
;

watuse_comm_2021(c,a) =
   sum((r,pr,ag,s,t),
       fir_2021(r,pr,c,ag,a,'irr',t)
     * x0_2021(r,pr,c,ag,a,'irr',t,'tot')
   )
;


*   ---- production costs commune
*---- Costs in tho CLP only ehre area exist
vcos_2021(r,pr,c,ag,a,s,t)$(
    x0_2021(r,pr,c,ag,a,s,t,'tot') > 0
  ) = 1e-6
      * p_cropData_2021(r,pr,c,ag,a,s,t,'vcost')
  ;

*Standard Gross Margin (yield*price-cost)
sgm_2021(r,pr,c,ag,a,s,t)$(
    x0_2021(r,pr,c,ag,a,s,t,'tot') > 0
  ) = yld_2021(r,pr,c,ag,a,s,t)
      * ps0_2021(a)
    - vcos_2021(r,pr,c,ag,a,s,t)
  ;


display vcos_2021, sgm_2021;


Parameter
reg_x0_2021(reg,agg,act,sys,tech)       'área total por región–ag–a–s–t en 2021 (ha)'
reg_ps0_2021(reg,act)             'precio de consumo por región–actividad en 2021 (M CLP/t)'

;

*--- Agregado regional de área: sumar toda la comuna para cada región
reg_x0_2021(r,ag,a,s,t) =
   sum((pr,c)$(map_reg_prov_comm(r,pr,c)),
       x0_2021(r,pr,c,ag,a,s,t,'tot')
   )
  ;

*--- Precio por región (asumo precio uniforme nacional replicado)
reg_ps0_2021(r,a) = ps0_2021(a);


*--- Mostrar resultados  
display vcos_2021, sgm_2021, reg_x0_2021, reg_ps0_2021;

*display x0_2010, x0_2020, selas_2010, selas_2020, ps0_2010, ps0_2020, qs0_2010, qs0_2020, fir_2010, gir_2010, fir_2020, gir_2020, watuse_2010, watuse_2020, vcos_2010, vcos_2020, sgm_2010, sgm_2020;

$exit

