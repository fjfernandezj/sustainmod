*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
$ontext
   Megasequia - CR2

   Name      :   02_pars_Chile_sustainmod.gms
   Purpose   :   Core model parameters
   Author    :   Francisco Fernandez
   Date      :   16.09.21
   Since     :   Sept 2021
   CalledBy  :   04_load_baseDataChile_megasequia

   Notes     :   Declaration of core model parameters

$offtext
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*                         PARAMETERS DECLARATION                               *
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

parameter
* farmland availability commune level
   iland_2021        "irrigable land (ha) commune 2021"
   tland_2021        "total agricultural land (ha) commune 2021"
   wland             "irrigated land in the reference period (ha) commune"

*   ---- base year data commune------
   yld_2021     "crop yield 2021 (tons/h)"
   
   x0_2021      "crop area (2021) in ha commune level"
   
   w0_2021     "water delivery (2021) in m3 commune level"
   
   ps0_2021      "producer price (CLP M$/t) - 2021"
   
   qs0_2021      "national Supply quantity (ton) - 2021"
   
   pd0          "consumer price (CLP M$/t)"
   qd0          "national demand (ton)"

   selas_2021   'supply elasticity 2021'

   delas        'demand elasticity'

*   DW_2010       'Gross Water Delivered 2010'
*   DW_2020       'Gross Water Delivered 2020'


*   ---- production costs by commune
   vcos_2021    "average variable costs (CLP M$/ha) (labor cost not included) - 2021"
  
   sgm_2021     "standard gross margin (CLP $M/ha) - 2021"
  
   gm           "gross margin (CLP/ha) (trev-vcos-lcos)"
   nm           "net margin (CLP/ha) (trev-vc)"
   gva          "gros value added (CLP M$/ha) (trev-vcos)"
   nva          "net value added (CLP M$/ha) (trev-vcos-kcos)"
   marg         "crop economic data"
   lab_2021     "labor demand per hectare 2021"

* model data for baseline
   p_cropData_2021(*,*,*,*,*,*,*,*) 'crop management data commune level 2021'
   p_supplyData_2021(*,*)           'supply data 2021'
   p_marketData(*,*)                'market data'


* crop water requirements and irrigation efficiency commune
   nir          "net irrigation requirements"
   fir_2021     "farm-gate (field) irrigation requirements 2021"
   gir_2021     "gros irrigation requirements 2021"
   Hd           "conveyance and distribution efficiency of the water network"
   Ha           "water application efficiency"

* water charges
   wtariff      "area based water tariff (canon + derrama)"

*   ---- cost function parameters commune 2021
   alpha_2021       "marginal cost intercept"
   beta_2021        "marginal cost slope (activity)"
   gamma_2021       "marginal cost slope (crop or crop group)"
   delta_2021       "marginal cost slope (irrigation technique)"
   sigma_2021       "subarea deviation from cost frontier"
   cpar_2021        "calibration parameters"


*~~~~~~~~~~~~~~~~~~~~~~~~ CALIBRATION PARAMETERS COMMUNE            ~~~~~~~~~~~~~~~~~~*
Parameter
   eps1       "epsilon (activity)"
   eps2       "epsilon (crop)"
   eps3       "epsilon (total crop area)"
   mu1        "dual values from calibration constraints (activity)"
   mu2        "dual values from calibration constraints (group)"
   mu3        "dual values from calibration constraints (total activity area)"
   cvpar      "cost function parameters"
   LambdaL    "land marginal value";

Parameter
  Margin      'marketing margin';


