*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   SustainMod Chilean model

   Name      :   05_coreModel_sustainmod.gms
   Purpose   :   Core model definition
   Author    :   Francisco Fernandez
   Date      :   23.07.25
   Since     :   July 2025
   CalledBy  :   06_pmpCalibration

   Notes     :   This file includes
                 + definition of main model equations
                 + definition of core model
$offtext
$onmulti ;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                         CORE MODEL 2021 DEFINITION                                *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                   CORE MODEL 2021 – DEFINICIÓN MULTIDIMENSIONAL             *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

* Variables de objetivo
variable
   Z_2021                        'total net income (CLP M$)';

variable Zc_2021(reg,prov,comm)         'net income per commune';

* Variables de decisión y auxiliares
positive variable
   X_2021(reg,prov,comm,agg,act,sys,tech)       'activity level (ha) por r–pr–c–ag–a–s–t'
   FW_2021(comm)                                'water used (th m3) por comuna'
   DW_2021(comm)                                'water delivery requirement por comuna'
   IL_2021(comm)                                'irrigated land (ha) por comuna'
   TC_2021                                      'total variable cost'
   AC_2021                                      'average variable cost'
   PS_2021                                      'producer price 2010'
   LabDem_2021(reg,prov,comm,agg,act,sys,tech)  'labor demand (días) por r–pr–c–ag–a–s–t'
;


* Ecuaciones
equations
   e_totIncome_2021                                 'objetivo: sumar ingreso neto de todas las comunas'
   e_income_2021(reg,prov,comm)                     'balance ingreso–costo por comuna'
   e_cost_LP_2021(reg,prov,comm,agg,act,sys,tech)   'cost accounting LP 2021'
   e_cost_NLP_2021(reg,prov,comm,agg,act,sys,tech)  'cost accounting NLP 2021'
   e_tLND_2021(reg,prov,comm)                       'restricción de tierra total por comuna'
   e_iLAND_2021(reg,prov,comm)                      'restricción de tierra irrigada por comuna'
   e_waterUse_2021(reg,prov,comm)                   'contabilidad de uso de agua por comuna'
   e_water_2021(comm)                               'relación entre uso y delivery requirement'
   e_lab_2021(reg,prov,comm,agg,act,sys,tech)       'demanda de trabajo por dimensión'
;

*--- Objetivo: suma de Zc sobre todos r,pr,c
e_totIncome_2021..
   sum((r,pr,c), Zc_2021(r,pr,c)) =e= Z_2021
;

*--- Ingreso neto por comuna: yield*price – avg cost
e_income_2021(r,pr,c)..
   sum((ag,a,s,t)$(map_cas_2021(c,a,s)),
       yld_2021(r,pr,c,ag,a,s,t)
     * ps0_2021(a)
     * X_2021(r,pr,c,ag,a,s,t)
     - AC_2021(r,pr,c,ag,a,s,t)  * X_2021(r,pr,c,ag,a,s,t)
   ) =e= Zc_2021(r,pr,c)
;

*--- cost accounting LP 2021: cost = average cost
e_cost_LP_2021(r,pr,c,ag,a,s,t)$(map_cas_2021(c,a,s))..
    vcos_2021(r,pr,c,ag,a,s,t)
   =e= AC_2021 (r,pr,c,ag,a,s,t)
;

*--- cost accounting NLP 2021: nonlinear calibration term
e_cost_NLP_2021(r,pr,c,ag,a,s,t)$(map_cas_2021(c,a,s))..
    alpha_2021(r,pr,c,ag,a,s,t)
   * X_2021(r,pr,c,ag,a,s,t) ** beta_2021 (r,pr,c,ag,a,s,t)
   =e= AC_2021 (r,pr,c,ag,a,s,t)
;

*--- Tierra total disponible (ha) por comuna
e_tLND_2021(r,pr,c)..
   sum((ag,a,s,t)$(map_cas_2021(c,a,s)),
       X_2021(r,pr,c,ag,a,s,t)
   ) =l= tland_2021(c)
;

*--- Tierra irrigada (ha) por comuna
e_iLAND_2021(r,pr,c)..
   sum((ag,a,t)$(map_cas_2021(c,a,'irr')),
       X_2021(r,pr,c,ag,a,'irr',t)
   ) =l= iland_2021(c)
;

*--- Uso de agua (m3) por comuna: gross irrigation req × área
e_waterUse_2021(r,pr,c)..
    sum((ag,a,t)$(map_cas_2021(c,a,'irr')), 
        fir_2021(r,pr,c,ag,a,'irr',t)
      * X_2021(r,pr,c,ag,a,'irr',t)
    ) =L= FW_2021(c)
;
    

*--- Relación entre uso y delivery requirement
e_water_2021(c)..
   FW_2021(c) =e= DW_2021(c) * Hd(c)
;

*--- Demanda de trabajo
e_lab_2021(r,pr,c,ag,a,s,t)$(map_cas_2021(c,a,s))..
   LabDem_2021(r,pr,c,ag,a,s,t) =e=
     lab_2021(r,pr,c,ag,a,s,t) * X_2021(r,pr,c,ag,a,s,t)
;

*--- Bounds a delivery y tierra irrigada (up)
DW_2021.up(c) = 2 * w0_2021(c);
IL_2021.up(c) = 1.58 * iland_2021(c);

*-----Commune------
model coreLP_2021 core equations /
   e_totIncome_2021
   e_income_2021
   e_tLND_2021
   e_iLAND_2021
   e_waterUse_2021
   e_water_2021
   e_lab_2021
*   e_TCost_2021
*   e_QS_2021
/;
