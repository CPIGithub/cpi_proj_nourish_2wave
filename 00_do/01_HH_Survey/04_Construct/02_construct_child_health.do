/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: child health data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	use "$dta/pnourish_child_health_raw.dta", clear 
	
	// _parent_index child_id_health
	
	rename child_id_health roster_index
	

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

	
	** Children Mother ** 
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

	tempfile hh_child_mom_rep
	save `hh_child_mom_rep', replace 

	restore

	merge 1:1 _parent_index roster_index using `hh_child_mom_rep'
	
	keep if _merge == 3

	drop _merge 
	
	
	****************************************************************************
	** Child Age Calculation **
	****************************************************************************
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"

	****************************************************************************
	** Child Birth Weight **
	****************************************************************************

	// child_vita
	replace child_vita = .d if child_vita == 999
	replace child_vita = .n if mi(child_vita)
	lab var child_vita "Vit-A supplementation"
	tab child_vita, m 

	// child_deworm 
	replace child_deworm = .d if child_deworm == 999
	replace child_deworm = .n if mi(child_deworm)
	lab var child_deworm "Deworming"
	tab child_deworm, m 

	// child_vaccin
	tab child_vaccin, m 
	
	// child_vaccin_card
	replace child_vaccin_card = .m if child_vaccin == 0
	tab child_vaccin_card, m 
	
	// child_birthwt
	// Low birth weight has been defined by WHO as weight at birth of < 2500 grams (5.5 pounds).
	// 1 kg 2.2 lb, 16 oz 1 lb 
	tab child_birthwt, m 

	foreach var of varlist 	child_birthwt_kg child_birthwt_lb child_birthwt_oz {
    
	replace `var' = .m if child_birthwt == 0
	tab `var', m 
	
}	
	replace child_birthwt_oz =  round(child_birthwt_oz/ 16, 0.01)
	tab child_birthwt_oz, m 
	
	replace child_birthwt_kg = round(child_birthwt_kg * 2.2, 0.01)
	tab child_birthwt_kg, m 
	
	egen child_bwt_lb 		= rowtotal(child_birthwt_kg child_birthwt_lb child_birthwt_oz)
	replace child_bwt_lb 	= .m if child_birthwt == 0
	tab child_bwt_lb, m 
	
	gen child_low_bwt 		= (child_bwt_lb < 5.5)
	replace child_low_bwt 	= .m if mi(child_bwt_lb)
	lab var child_low_bwt "Low-birth weight"
	tab child_low_bwt, m 

	
	********************************************************************************
	** Childood illness: **
	********************************************************************************
	// child_ill 
	tab child_ill, m 
	
	foreach var of varlist child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 {
	    
		tab `var', m 
	}


	***** DIARRHEA *****
	// child_diarrh_treat
	replace child_diarrh_treat = .m if child_ill1 != 1
	tab child_diarrh_treat, m 
	
	// child_diarrh_where&&
	replace child_diarrh_where = .m if child_diarrh_treat != 1
	replace child_diarrh_where = .d if child_diarrh_where == 999
	tab child_diarrh_where, m 
	
	lab def ancwhere 	1"Home" 2"Government hospital" 3"Private Clinic" 4"SRHC-RHC" ///
						5"EHO Clinic" 6"EHO clinic mobile team (within village)" ///
						7"Routine ANC place within village" 999"Don't know/Don't remember" ///
						888"Other" 
	lab val child_diarrh_where ancwhere 
	tab child_diarrh_where, m 

	
	// child_diarrh_who
	replace child_diarrh_who = .m if child_diarrh_treat != 1
	tab child_diarrh_who, m 

	lab def ancwho 	1"Specialist" 2"Doctor" 3"Nurse" 4"Health assistant" ///
	5"Private doctor" 6"LHV" 7"Midwife" 8"AMW" 9"Ethnic health worker" ///
	10"Community Health Worker" 11"TBA" 888"Other"
	lab val child_diarrh_who ancwho
	
	tab child_diarrh_who, m 
	

	***** COUGH *****
	// child_cough_treat
	replace child_cough_treat = .m if child_ill2 != 1
	tab child_cough_treat, m 
	
	// child_cough_where
	replace child_cough_where = .m if child_cough_treat != 1
	replace child_cough_where = .d if child_cough_where == 999
	lab val child_cough_where ancwhere 
	tab child_cough_where, m 
	
	// child_cough_who
	replace child_cough_who = .m if child_cough_treat != 1
	lab val child_cough_who ancwho 
	tab child_cough_who, m 

	
	***** FEVER *****
	// child_fever_treat
	replace child_fever_treat = .m if child_ill3 != 1
	tab child_fever_treat, m 
	
	// child_fever_where
	replace child_fever_where = .m if child_fever_treat != 1
	replace child_fever_where = .d if child_fever_where == 999
	lab val child_fever_where ancwhere
	tab child_fever_where, m 
	
	// child_fever_who
	replace child_fever_who = .m if child_fever_treat != 1
	lab val child_fever_who ancwho 
	tab child_fever_who, m 

	
	***** ALL DISEASES *****

	// child_*_notreat
	local diseases 	diarrh cough fever
	local numbers 	1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 888 777 999

	foreach d in `diseases' {
		
		foreach x in `numbers' {
			
			replace child_`d'_notreat`x' = .m if mi(child_`d'_notreat)
			tab child_`d'_notreat`x', m 
		}
	}
	
	// child_*_pay
	foreach d in `diseases' {
			
		replace child_`d'_pay = .m if child_`d'_treat != 1
		replace child_`d'_pay = .d if child_`d'_pay == 999
		tab child_`d'_pay, m 

	}
	
	// child_*_cope
	local numbers 	1 2 3 4 5 6 7 8 9 10 11 12 13 14 888 666

	foreach d in `diseases' {
		
		foreach x in `numbers' {
			
			replace child_`d'_cope`x' = .m if mi(child_`d'_cope)
			tab child_`d'_cope`x', m 
		}
	}
	
	// Treated with trainned health personnel 
	// child_diarrh_who child_cough_who child_fever_who
	foreach d in `diseases' {
		
		gen child_`d'_trained 		= (child_`d'_who < 10 )
		replace child_`d'_trained 	= .m if mi(child_`d'_who)
		lab var child_`d'_trained "Treated with trained health personnel"
		tab child_`d'_trained, m 
	}
	
	
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_child_health_final.dta", replace  


// END HERE 


