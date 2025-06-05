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
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status
	
	* keep consent yes 
	keep if will_participate == 1
	
	* respd_who 
	lab def respd_who 1"Mother (Herself)" 0"Miain Caregiver"
	lab val respd_who respd_who
	tab respd_who, m 
	
	
	** reconstruct the respondent ID 
	tostring cal_respid respd_id, replace 
	replace respd_id = cal_respid
	
	preserve 
	
	keep org_name stratum geo_town geo_vt geo_vill interv_name quest_num uuid respd_id
	
	destring quest_num, replace
	bysort org_name stratum geo_town geo_vt geo_vill interv_name: replace quest_num = _n
	
	tostring geo_town geo_vt geo_vill interv_name quest_num, replace 
	
	replace respd_id = geo_town + "_" + geo_vt + "_" + geo_vill + "_" + interv_name + "_" + quest_num
	
	distinct respd_id
	
	keep respd_id uuid
	
	tempfile respd_id
	save `respd_id', replace 
	
	restore 
	
	drop respd_id
	
	merge 1:1 uuid using `respd_id'
	
	order respd_id, after(cal_respid)
	drop cal_respid _merge 
	
	
	** HH Roster ** // Add HH roster info
	** (1): Respondent info - number 1 index in HH roster 
	
	preserve 

	use "$dta/grp_hh_clean.dta", clear
	
	keep	_parent_index roster_index hh_mem_head hh_mem_marital hh_mem_highedu hh_mem_occup hh_mem_highedu_all hh_mem_u5num hh_mem_u2num calc_0to5_child_count calc_u5child_count
	
	keep if roster_index == 1

	rename hh_mem_head 		resp_hhhead
	rename hh_mem_marital 	resp_marital
	rename hh_mem_highedu	resp_highedu 
	rename hh_mem_occup		resp_occup
	
	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index using `grp_hh'
	
	keep if _merge == 3
	&
	drop _merge 
	
	order resp_hhhead-resp_occup, after(respd_age)


	** (2): HH Head info - hh_mem_head in HH roster 
	preserve 

	use "$dta/grp_hh_clean.dta", clear
/*	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test calc_age_months, replace
*/
	keep	_parent_index roster_index hh_mem_head hh_mem_marital hh_mem_highedu hh_mem_occup
	
	//rename test roster_index
	
	keep if hh_mem_head == 1

	rename hh_mem_head 		hhhead_yes
	rename hh_mem_marital 	hhhead_marital
	rename hh_mem_highedu	hhhead_highedu 
	rename hh_mem_occup		hhhead_occup
	
	
	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index using `grp_hh'
	
	keep if _merge == 3
	
	drop _merge 
	
	order hhhead_yes-hhhead_occup, after(respd_phonnum)


	* Save as hh level dataset * 
	save "$dta/PN_HH_Survey_HH_Level_raw.dta", replace  
	
	 
	


// END HERE 


