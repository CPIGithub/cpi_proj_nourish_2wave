/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: hh data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	** Child MUAC Module **
	****************************************************************************

	use "$dta/endline/child_muac_rep.dta", clear
	
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status

	* lab var 
	lab var child_muac_yn "Did you able to measure the child's MUAC for ${child_pos4}?"
	lab var child_muac "${child_pos4} MUAC"

	
	// drop obs not eligable for this module 
	drop if mi(child_muac_yn) 

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring child_id_muac, replace

	merge m:1 _parent_index using "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", ///
							keepusing(`maingeo' `mainresp')
	
	keep if _merge == 3
	drop _merge 
	
	order `maingeo' `mainresp'
	
	* Save as Child MUAC dataset * 
	save "$dta/endline/pnourish_child_muac_raw.dta", replace  
	

// END HERE 


