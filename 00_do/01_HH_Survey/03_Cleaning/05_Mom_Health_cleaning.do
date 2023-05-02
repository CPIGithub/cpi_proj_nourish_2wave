/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	** Mom Health Module **
	****************************************************************************

	use "$dta/anc_rep.dta", clear
	
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status
	

	* lab var
	do "$hhimport/mom_health_labeling.do"	
	
	// drop obs not eligable for this module 
	drop if mi(mom_rice) & mi(anc_adopt)

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring women_id_pregpast, replace

	merge m:1 _parent_index using "$dta/PN_HH_Survey_HH_Level_raw.dta", keepusing(`maingeo' `mainresp')
	
	keep if _merge == 3
	drop _merge 
	
	order `maingeo' `mainresp'
	
	* Save Mom Health dataset * 
	save "$dta/pnourish_mom_health_raw.dta", replace  
	

// END HERE 


