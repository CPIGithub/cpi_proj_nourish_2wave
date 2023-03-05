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

********************************************************************************
* household survey *
********************************************************************************

	** HH Survey Dataset **
	use "$dta/PN_HH_Survey_HH_Level.dta", clear 

	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	cal_respid respd_who respd_name respd_sex respd_age respd_status
	
	keep if org_name == "YSDA"
	

	* Save as hh level dataset * 
	save "$dta/PN_HH_Survey_HH_Level_raw.dta", replace  
	
	clear 
	


	****************************************************************************
	* Child IYCF Module *
	use "$dta/grp_q2_5_to_q2_7.dta", clear
	
	do "$hhimport/child_iycf_labeling.do"

	// drop obs not eligable for this module 
	drop if mi(child_bf)
	
	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring child_id_iycf, replace

	merge m:1 _parent_index using "$dta/PN_HH_Survey_HH_Level_raw.dta", keepusing(`maingeo' `mainresp')
	
	keep if _merge == 3
	drop _merge 
	
	order `maingeo' `mainresp'
	
	* Save as IYCF dataset * 
	save "$dta/pnourish_child_iycf_raw.dta", replace  
	
	clear 

	****************************************************************************

	** CHild Health Module **
	use "$dta/child_vc_rep.dta", clear
	
	do "$hhimport/child_health_labeling.do"
	
	// drop obs not eligable for this module 
	drop if mi(child_ill)

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring child_id_health, replace

	merge m:1 _parent_index using "$dta/PN_HH_Survey_HH_Level_raw.dta", keepusing(`maingeo' `mainresp')
	
	keep if _merge == 3
	drop _merge 
	
	order `maingeo' `mainresp'
	
	* Save as IYCF dataset * 
	save "$dta/pnourish_child_health_raw.dta", replace  
	
	clear 

	****************************************************************************

	** Mom Health Module **
	use "$dta/anc_rep.dta", clear
	
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
	
	* Save as IYCF dataset * 
	save "$dta/pnourish_mom_health_raw.dta", replace  
	
	clear 

	****************************************************************************

	** Child MUAC Module **
	use "$dta/child_muac_rep.dta", clear
	
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

	merge m:1 _parent_index using "$dta/PN_HH_Survey_HH_Level_raw.dta", keepusing(`maingeo' `mainresp')
	
	keep if _merge == 3
	drop _merge 
	
	order `maingeo' `mainresp'
	
	* Save as IYCF dataset * 
	save "$dta/pnourish_child_muac_raw.dta", replace  
	
	clear 
	

// END HERE 


