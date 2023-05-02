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

	
	** HH Roster ** 

	use "$dta/grp_hh.dta", clear
	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test calc_age_months, replace

	rename test roster_index
	
	// hh_mem_highedu
	* recode the informal education as formal grade 
	* replace other specify in the respective grade 
	tab hh_mem_highedu, m 
	replace hh_mem_highedu = .d if hh_mem_highedu ==  777 | hh_mem_highedu == 999
		
	replace hh_mem_highedu = 2 if hh_mem_highedu_oth == "ပထမတန်း"
	replace hh_mem_highedu = 2 if hh_mem_highedu_oth == "KG"
	replace hh_mem_highedu = 1 if hh_mem_highedu_oth == "ကျောင်းမနေ"
	replace hh_mem_highedu = 1 if hh_mem_highedu_oth == "ကျောင်းမနေရသေးပါ"
	replace hh_mem_highedu = 4 if hh_mem_highedu_oth == "၁၀တန်း"
	replace hh_mem_highedu = 4 if hh_mem_highedu_oth == "ဆယ်တန်း"
	replace hh_mem_highedu = 6 if hh_mem_highedu_oth == "ဘွဲ့ရ"
	replace hh_mem_highedu = 4 if hh_mem_highedu_oth == "10 "
	replace hh_mem_highedu = 4 if hh_mem_highedu_oth == "Thai university"
	replace hh_mem_highedu = 1 if hh_mem_highedu_oth == "ကျေင်းမနေရ လယ်"
	replace hh_mem_highedu = 1 if hh_mem_highedu_oth == "ကျောင်းနေအရွယ်မရောက်သေးပါ"
	replace hh_mem_highedu = 1 if hh_mem_highedu_oth == "​ကျောင်းမ​နေရသေးပါ"

	replace hh_mem_highedu = 2 if hh_mem_highedu == 9
	replace hh_mem_highedu = 3 if hh_mem_highedu == 10
	replace hh_mem_highedu = 4 if hh_mem_highedu == 11
	replace hh_mem_highedu = 6 if hh_mem_highedu == 12
	
	replace hh_mem_highedu_oth = "" if hh_mem_highedu != 888
	
	tab hh_mem_highedu, m 

	//gen hh_mem_highedu_all = hh_mem_highedu 

	gen hh_mem_highedu_n = hh_mem_highedu
	replace hh_mem_highedu_n = .o if hh_mem_highedu == 888
	
	bysort _parent_index: egen hh_mem_highedu_all = max(hh_mem_highedu_n)
	lab var hh_mem_highedu_all "Highest Education Among All HH Members"
	lab def edu 1"Illiterate" ///
				2"Primary education (Under 5th standard)" ///
				3"Secondary education (under 9th standard)" ///
				4"Higher education (till pass matriculation exam)" ///
				5"Vocational education" ///
				6"Graduate level (University/ College)" ///
				7"Post graduate level (University)" ///
				8"Monastery Education (No specific standard)" 
	lab val hh_mem_highedu_all edu 
	lab val hh_mem_highedu edu

	tab hh_mem_highedu_all, m 
	
	drop hh_mem_highedu_n 
	

	** Add Children Mother ** 
	preserve 
	use "$dta/hh_child_mom_rep.dta", clear
	
	* lab var 
	lab var hh_mem_mom "Who is the mother of this child?"
	
	// drop obs not eligable for this module 
	drop if mi(hh_mem_mom)

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring cal_hh_cname_id, replace
	
	keep _parent_index cal_hh_cname_id hh_mem_mom

	rename cal_hh_cname_id roster_index
	rename hh_mem_mom women_pos1 

	tempfile hh_child_mom_rep
	save `hh_child_mom_rep', replace 

	restore
	

	merge 1:1 _parent_index roster_index using `hh_child_mom_rep'
	
	drop _merge 
		
	* Save as hh level dataset * 
	save "$dta/grp_hh_clean.dta", replace  
	

// END HERE 



