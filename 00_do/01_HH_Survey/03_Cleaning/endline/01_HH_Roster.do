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

********************************************************************************
* household survey *
********************************************************************************

	
	** HH Roster ** 

	use "$dta/endline/grp_hh.dta", clear
	
	merge m:1 _parent_index using "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", keepusing(svy_date) 
	
	drop if _merge == 2
	drop _merge 
	
	** Labeling 
	//do "$hhimport/grp_hh_labeling.do"

	* apply WB codebook command 
	iecodebook apply using "$raw/endline/codebook/codebook_grp_hh.xlsx"
	
	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order svy_date _parent_index 

	destring test calc_age_months, replace

	rename test roster_index
	
	// hh_mem_highedu
	* recode the informal education as formal grade 
	* replace other specify in the respective grade 
	tab hh_mem_highedu, m 
	replace hh_mem_highedu = .d if hh_mem_highedu ==  777 | hh_mem_highedu == 999
		
	replace hh_mem_highedu = 1 if 	hh_mem_highedu_oth == "0" | ///
									hh_mem_highedu_oth == "ကျောင်းမနေ" | ///
									hh_mem_highedu_oth == "ကျောင်းမနေရပါ"
									
	replace hh_mem_highedu = 2 if 	hh_mem_highedu_oth == "KG" | ///
									hh_mem_highedu_oth == "KG student" | ///
									hh_mem_highedu_oth == "မိုကြိုကျောင်းသား" | ///
									hh_mem_highedu_oth == "မူကြိုကျောင်း"
									
	replace hh_mem_highedu = 8 if 	hh_mem_highedu_oth == "ဘုန်းကြီးကျောင်းနေ" | ///
									hh_mem_highedu_oth == "ဘုန်းကြီးကျောင်း ဘာသာရေး" | ///
									hh_mem_highedu_oth == "ဘာသာရေး ဘုန်းကြီးကျောင်း" | ///
									hh_mem_highedu_oth == "ဘာသာရေးကျောင်း"
	
	replace hh_mem_highedu = 5 if 	hh_mem_highedu_oth == "ကျမ်းစာ​ကျောင်းတက်"
	
	replace hh_mem_highedu = 3 if 	hh_mem_highedu_oth == "ဆဌမတန်း"

	replace hh_mem_highedu = 2 if hh_mem_highedu == 9
	replace hh_mem_highedu = 3 if hh_mem_highedu == 10
	replace hh_mem_highedu = 4 if hh_mem_highedu == 11
	replace hh_mem_highedu = 6 if hh_mem_highedu == 12
	
	replace hh_mem_highedu_oth = "" if hh_mem_highedu != 888
	
	destring calc_age_years_final, replace 
	replace hh_mem_highedu = .m if calc_age_years_final <= 4 
	
	tab1 hh_mem_highedu hh_mem_highedu_oth, m 

	//gen hh_mem_highedu_all = hh_mem_highedu 

	gen hh_mem_highedu_n = hh_mem_highedu
	replace hh_mem_highedu_n = .o if hh_mem_highedu == 888 | hh_mem_highedu == 8
	
	bysort _parent_index: egen hh_mem_highedu_all = max(hh_mem_highedu_n)
	lab var hh_mem_highedu_all "Highest Education Among All HH Members"
	lab val hh_mem_highedu_all education 
	lab val hh_mem_highedu edu

	tab hh_mem_highedu_all, m 
	
	drop hh_mem_highedu_n 
	

	** Add Children Mother ** 
	preserve 
	use "$dta/endline/hh_child_mom_rep.dta", clear
	
	** Labeling 
	* apply WB codebook command 
	iecodebook apply using "$raw/endline/codebook/codebook_hh_child_mom_rep.xlsx"
		
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
	save "$dta/endline/grp_hh_clean.dta", replace  
	
	
	****************************************************************************
	****************************************************************************
	
	* Update HH roster info to Cleaned Dataset * 
	use "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", clear 
	
	** HH Roster ** // Add HH roster info
	** (1): Respondent info - number 1 index in HH roster 
	
	preserve 

	use "$dta/endline/grp_hh_clean.dta", clear
	
	keep	_parent_index roster_index hh_mem_head hh_mem_marital hh_mem_highedu hh_mem_occup hh_mem_highedu_all
	
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
	
	drop _merge 
	
	order resp_hhhead-resp_occup, after(respd_age)


	** (2): HH Head info - hh_mem_head in HH roster 
	preserve 

	use "$dta/endline/grp_hh_clean.dta", clear
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
	
	* save as updated cleaned data 
	save "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", replace 
	

// END HERE 



