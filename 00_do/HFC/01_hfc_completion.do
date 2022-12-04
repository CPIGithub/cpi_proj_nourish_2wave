/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: completion check 			
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

// survey per geo
bysort geo_town geo_vt geo_vill: gen tot_attempt_per_vill = _N
bysort geo_town geo_vt geo_vill: egen tot_svy_per_vill = total(will_participate)

// survey per team
bysort svy_team: gen tot_attemtp_per_team = _N
bysort svy_team: egen tot_svy_per_team = total(will_participate)

bysort svy_team interv_name: gen tot_attempt_per_enu = _N
bysort svy_team interv_name: egen tot_svy_per_enu = total(will_participate)


// lab var 
lab var tot_attempt_per_vill	"Number of interview per village"
lab var tot_svy_per_vill 		"Number of consent survey per village"
lab var tot_attemtp_per_team 	"Number of interview per team"
lab var tot_svy_per_team 		"Number of consent survey per team"
lab var tot_attempt_per_enu 	"Number of interview per enumerator"
lab var tot_svy_per_enu			"Number of consent survey per enumerator"

// export table
preserve 
bysort geo_town geo_vt geo_vill: keep if _n == 1 
keep geo_town geo_vt geo_vill tot_attempt_per_vill tot_svy_per_vill

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("01_geo") firstrow(varlabels) sheetreplace
restore 



preserve 
bysort svy_team: keep if _n == 1 
keep svy_team tot_attemtp_per_team tot_svy_per_team

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("02_team") firstrow(varlabels) sheetreplace
restore 


preserve 
bysort svy_team: keep if _n == 1
keep svy_team superv_name interv_name tot_attempt_per_enu tot_svy_per_enu

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("03_enu") firstrow(varlabels) sheetreplace
restore 

// END HERE 


