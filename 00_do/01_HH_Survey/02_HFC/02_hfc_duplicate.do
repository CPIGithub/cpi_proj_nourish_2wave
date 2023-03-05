/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: duplciate check 			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pnourish_hh_svy_wide.dta", clear 

keep if will_participate == 1

// duplicate by geo-person
duplicates tag geo_town geo_vt geo_vill respd_name respd_age respd_status, gen(dup_resp)
tab dup_resp, m 

order svy_date org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

preserve 
keep if dup_resp != 0

if _N > 0 {
	
	export excel using "$out/02_hfc_hh_duplicate.xlsx", sheet("01_dup_resp") firstrow(varlabels) sheetreplace
	
}

restore 


// duplicate by personal info (exclude geo)
duplicates tag respd_name respd_age respd_status respd_preg respd_child respd_1stpreg_age respd_chid_num, gen(dup_person)

tab dup_person, m 


preserve 
keep if dup_person != 0

if _N > 0 {
	
	export excel using "$out/02_hfc_hh_duplicate.xlsx", sheet("02_dup_person") firstrow(varlabels) sheetreplace
	
}

restore 

// END HERE 



