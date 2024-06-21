/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: duplciate check 			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* Village survey *
********************************************************************************

use "$dta/pnourish_village_svy_wide.dta", clear 

// duplicate by geo-person
duplicates tag	geo_town geo_vt geo_vill vill_data_yes ///
				rpl_geo_town rpl_geo_vt rpl_geo_vill rpl_vill_data_yes ///
				will_participate vill_data_yes, gen(dup_vill)
tab dup_vill, m 

order svy_date org_name township_name geo_eho_vt_name geo_eho_vill_name stratum vill_data_yes 

preserve 
keep if dup_vill != 0

if _N > 0 {
	
	export excel using "$out/02_hfc_vill_duplicate.xlsx", sheet("01_dup_vill") firstrow(varlabels) sheetreplace
	
}

restore 


// END HERE 



