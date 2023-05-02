/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh Income and Wealth Quantile cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

	** HH Survey Dataset **
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status

	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			will_participate-cal_hhroster_end
			
	drop cal* *flag* // cla_*
	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_respondent_info_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_respondent_info_cleaning.xlsx" 


	** SAVE for analysis dataset 
	save "$dta/pnourish_respondent_info_final.dta", replace  


	
// END HERE 


