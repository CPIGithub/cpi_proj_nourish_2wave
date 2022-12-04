/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: missing check 			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pn_hh_pnourish_secondwave.dta", clear 

// missing per variables 
foreach var of varlist _all {
    
	gen `var'_m = mi(`var')
	
	egen `var'_m_t = total(`var'_m)
	
	bysort svy_team enu_name: egen `var'_em = total(`var'_m)
	
	tab `var'_m_t

}

gen sir = _n 


// all variables 
preserve
keep if _n == 1

keep sir *_m_t

drop cla_* calc_* cal_*

rename _* *

rename *_m_t m_t_*

drop *note*

reshape long m_t_, i(sir) j(var) string 

rename m_t_ missing_num 

// lab var 
lab var missing_num	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("01_per_var") firstrow(varlabels) sheetreplace
restore 

// variables per enumerator 
bysort svy_team enu_name: keep if _n == 1

keep sir *_em svy_team enu_name

drop cla_* calc_* cal_* svy_team_* enu_name_*

rename _* *

rename *_em em_*

drop *note*

reshape long em_, i(sir) j(var) string 

rename em_ missing_num 

// lab var 
lab var missing_num	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("02_per_var_enu") firstrow(varlabels) sheetreplace


// overall total  
bysort svy_team enu_name: egen tot_missing = total(missing_num)
bysort svy_team enu_name: keep if _n == 1

keep svy_team enu_name tot_missing

// lab var 
lab var tot_missing	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("03_per_enu_tot") firstrow(varlabels) sheetreplace

* END here 


 

