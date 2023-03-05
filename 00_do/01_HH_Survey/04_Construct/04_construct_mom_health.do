/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Mom Health data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Mom Health Module *
	****************************************************************************
	use "$dta/pnourish_mom_health_raw.dta", clear 
	
	// _parent_index women_id_pregpast
	
	rename women_id_pregpast roster_index
	

	** HH Roster **
	preserve 

	use "$dta/grp_hh.dta", clear
	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test calc_age_months, replace

	keep	_parent_index test hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months
	
	rename test roster_index

	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 

	
	****************************************************************************
	** Mom ANC **
	****************************************************************************
	// anc_adopt
	replace anc_adopt = .m if mi(anc_adopt)
	tab anc_adopt, m 
	
	// anc_yn 
	replace anc_yn = .m if anc_adopt != 0
	tab anc_yn, m 
	
	// anc_where 
	replace anc_where = .m if anc_yn != 1
	tab anc_where, m 
	

	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	replace deliv_place = .m if anc_adopt != 0
	tab deliv_place, m 
	
	// deliv_assist
	replace deliv_assist = .m if anc_adopt != 0
	tab deliv_assist, m 

	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// pnc_yn 
	replace pnc_yn = .m if anc_adopt != 0
	tab pnc_yn, m 
	
	// pnc_where 
	replace pnc_where = .m if pnc_yn != 1
	tab pnc_where, m 
	
	
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// nbc_yn 
	replace nbc_yn = .m if anc_adopt != 0
	tab nbc_yn, m 
	
	// nbc_where
	replace nbc_where = .m if nbc_yn != 1
	tab nbc_where, m 
	

	** SAVE for analysis dataset 
	save "$dta/pnourish_mom_health_final.dta", replace  


// END HERE 


