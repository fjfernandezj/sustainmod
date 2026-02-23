*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   PMP Calibration Modelo sustainmod

   Name      :   06_pmpCalibration.gms
   Purpose   :   model Chile megasequia (PMP)
   Author    :   Francisco Fernandez
   Date      :   July 2025
   Since     :   July 2025
   CalledBy  :

   Notes     :

$offtext
$onmulti;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                         INCLUDE SETS AND BASE DATA                           *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$include 'C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\data\03_load_base_data_sustainmod.gms'


;
Parameter test_2021;
test_2021 = sum(c, tland_2021(c));

*~~~~~~~~~~~~~~~~~~~~~~~~ BASEYEAR DATA    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*   ---- definición de actividades “vigentes” en cada comuna–actividad–sistema
*        a partir del área base x0_2021(r,pr,c,ag,a,s,t,'tot') > 0

* map_cas_2021 ya está declarado como set(c,a,s):
map_cas_2021(c,a,s) = yes$
    ( sum((r,pr,ag,t),
          x0_2021(r,pr,c,ag,a,s,t,'tot')
      ) > 0
    );

* Ahora map_cas_2021 contiene todas las combinaciones (c,a,s) donde hay área en 2021

display test_2021, map_cas_2021;


*~~~~~~~~~~~~~~~~~~~~~~~~ CALIBRATION PARAMETERS            ~~~~~~~~~~~~~~~~~~*
Parameter
   eps1       "epsilon (activity)"
   eps2       "epsilon (crop)"
   eps3       "epsilon (total crop area)"
   mu1_2021   "dual values from calibration constraints (activity) - 2021"
   mu1pr
   mu2        "dual values from calibration constraints (group)"
   mu3        "dual values from calibration constraints (total activity area)"
   cvpar      "cost function parameters"
   LambdaL    "land marginal value"


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*            PMP CALIBRATION                                                  *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*~~~~~~~~~~~~~~~~~ SOLVE LP MODEL WITH CALIBRATION CONSTRAINTS ~~~~~~~~~~~~~~~*
$include 'C:\Users\franj\OneDrive\Documentos\GitHub\sustainmod\GAMS\data\04_coreModel_sustainMod.gms'
;

* consider only potential activities (Fijar a cero las actividades no potenciales)
X_2021.fx(r,pr,c,ag,a,s,t)$(not map_cas_2021(c,a,s)) = 0;

* bounds on variables (no exceder tierra total)
X_2021.up(r,pr,c,ag,a,s,t)$map_cas_2021(c,a,s) = tland_2021(c);

*--- Cota superior para uso de agua
FW_2021.up(c) = w0_2021(c) * Hd(c);

*##########--Farm model calibration--###########
* exogenous producer prices
PS_2021.fx(a) = ps0_2021(a);

*---2021
model baseLP_2021 modelo lineal base /
   coreLP_2021
   e_cost_LP_2021
/;



solve baseLP_2021 using NLP maximizing Z_2021;


$exit



$ontext
*----2020
model baseLP_2020 modelo lineal base /
   coreLP_2020
   e_cost_LP_2020
/;

solve baseLP_2020 using NLP maximizing Z_2020;

$offtext

*   ---- calibration parameters
*   ---- eps1 > eps2 - ep2 < eps3
eps1=0.000001;
eps2=0.0000001;
eps3=0.000001;

*   ---- calibration constraints
equation
   calib1_2021    calibration constraints (activity)
;

CALIB1_2021(c,a,s)..  X_2021(c,a,s)$map_cas_2021(c,a,s) =l= x0_2021(c,a,s)*(1+eps1);


*CALIB2(i,c)..  sum((t)$act(i,c,t),X(i,c,t)) =l= sum((t)$act(i,c,t),x0(i,c,t))*(1+eps2);

*CALIB3(c,t)..  sum(i$act(i,c,t),X(i,c,t)) =l= sum(i$act(i,c,t),x0(i,c,t))*(1+eps3);

* only 1 calib constraint in this version

*############----Farm Model Calibration Parameters----#####
Model calib_2021 calibration model sustainmod 2021 /
   coreLP_2021
   e_cost_LP_2021
   calib1_2021
/;

solve calib_2021 using NLP maximizing Z_2021;

parameter chPMP_2020, cpar_2020, tstland_2020, regland_2020, regchPMP_2020;
chPMP_2020(c,a,s,'sgm') = sgm_2020(c,a,s);
chPMP_2020(c,a,s,'X0')  = x0_2020(c,a,s);
chPMP_2020(c,a,s,'calib') = X_2020.L(c,a,s);
chPMP_2020(c,a,s,'diff') = chPMP_2020(c,a,s,'X0')- chPMP_2020(c,a,s,'calib');
tstland_2020(c)= sum((a,s),x0_2020(c,a,s))- sum((a,s),x_2020.l(c,a,s));
regland_2020(r,a,s,'Sup_2020')= sum(c$map_reg_comm(r,c),X_2020.l(c,a,s));
regchPMP_2020(r,a,s,'sgm') = sum(c$map_reg_comm(r,c), sgm_2020(c,a,s));
regchPMP_2020(r,a,s,'X0')  = sum(c$map_reg_comm(r,c), x0_2020(c,a,s));
regchPMP_2020(r,a,s,'calib') = sum(c$map_reg_comm(r,c), X_2020.L(c,a,s));
regchPMP_2020(r,a,s,'diff') = regchPMP_2020(r,a,s,'X0')- regchPMP_2020(r,a,s,'calib');

*~~~~~~~~~~~~~~~~~~~~~~~~  COST FUNCTION PARAMETERS            ~~~~~~~~~~~~~~~~*
* mu1_2020
mu1_2020(c,a,s)$map_cas_2020(c,a,s)  = CALIB1_2020.M(c,a,s);

*   ---- constant elasticity supply function: Q = a p**b
*        haciendo selas=beta=1/b => p = a**(-beta) Q**beta
*        TC = (a**(-beta)/(beta+1))  Q**(beta+1)
*        en funcion de X => TC = (a**(-beta)/(beta+1)) yld**(beta+1) X**(beta+1)
*        haciendo alfa=(a**(-beta)/(beta+1)) yld**(beta+1) => TC = alfa X**(beta+1)
*        AV = alfa X**beta

*        alfa se estima a traves de las condiciones de optimalidad MC=c+mu
*        MC = alfa (beta+1) X**beta = c + mu
*        alfa = (c+mu)/(beta+1) x0**(-beta)

BETA_2020(c,a,s)$map_cas_2020(c,a,s) = 1/selas_2020(a);
ALPHA_2020(c,a,s)$map_cas_2020(c,a,s)= (1/(1+beta_2020(c,a,s)))*(vcos_2020(c,a,s)+mu1_2020(c,a,s))*x0_2020(c,a,s)**(-beta_2020(c,a,s));

*   ---- checking pmp parameters
cpar_2020(c,a,s,'alpha_2020')$map_cas_2020(c,a,s)  = alpha_2020(c,a,s);
cpar_2020(c,a,s,'beta_2020')$map_cas_2020(c,a,s)   = beta_2020(c,a,s);

*   ---- create gdx file with model data
display chPMP_2020, cpar_2020, x_2020.l, z_2020.l, zc_2020.l, tstland_2020, regland_2020, regchPMP_2020;

execute_unload '..\sequia_chile_V03\gams\model\basedata\cparChile_ms_2020.gdx' cpar_2020 ;
execute_unload '..\sequia_chile_V03\gams\results\landtst_ms_2020.gdx'  chPMP_2020 x0_2020 ;
execute_unload '..\sequia_chile_V03\gams\results\calib_ms_2020.gdx' ;

execute 'gdxxrw.exe ..\sequia_chile_V03\gams\results\landtst_ms_2020.gdx o=..\sequia_chile_V03\gams\results\landtst_ms_2020.xlsx par=chPMP_2020 rng=chPMP_2020!A1' ;
execute 'gdxxrw.exe ..\sequia_chile_V03\gams\results\landtst_ms_2020.gdx o=..\sequia_chile_V03\gams\results\landtst_ms_2020.xlsx par=x0_2020 rng=x0_2020!A1' ;
