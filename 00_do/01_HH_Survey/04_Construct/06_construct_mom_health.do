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
	
	* keep mom diet only 
	keep	geo_vill ///
			_parent_index roster_index ///
			women_pos1-cal_mnbc_end
			
	drop cal* // cla*


	** HH Roster **
	preserve 

	use "$dta/grp_hh_clean.dta", clear
	
	keep	_parent_index roster_index hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months hh_mem_u2num
	
	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 

	
	* Youngest Child Age and DOB info 
	preserve 

	use "$dta/grp_hh_clean.dta", clear
	
	// child age calculation 
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"
	
	keep if child_age_month < 24 
	
	
	gen est_dob = svy_date - (child_age_month * 30.04) // average day in month 
	format %td est_dob 
	
	// child birth month calculation 
	gen dob_m = month(hh_mem_dob)
	replace dob_m = month(est_dob) if mi(hh_mem_dob)
	gen dob_y = year(hh_mem_dob)
	replace dob_y = year(est_dob) if mi(hh_mem_dob)
	
	gen hh_mem_dob_str = ym(dob_y, dob_m)
	format hh_mem_dob_str %tm
	lab var hh_mem_dob_str "U2 Child DOB"
	
	
	// keep the youngest child 
	sort _parent_index women_pos1 child_age_month
	bysort _parent_index women_pos1: keep if _n == 1
	
	keep	_parent_index women_pos1 hh_mem_dob_str child_age_month
	
	rename women_pos1 roster_index 

	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'
	
	drop if _merge == 2 // Mom health session only ask for U2 mom - ummatched came from > 2 yrs old
	drop _merge 
	
	
	****************************************************************************
	** Mom ANC **
	****************************************************************************
	// anc_adopt
	replace anc_adopt = .m if mi(anc_adopt)
	tab anc_adopt, m 
	
	// anc_yn 
	replace anc_yn = .m if anc_adopt != 0
	replace anc_yn = .d if anc_yn == 999
	tab anc_yn, m 
	
	// anc_where 
	replace anc_where = .m if mi(anc_yn) // anc_yn != 1
	tab anc_where, m 
	
	lab def ancwhere 	1"Home" 2"Government hospital" 3"Private Clinic" 4"SRHC-RHC" ///
						5"EHO Clinic" 6"EHO clinic mobile team (within village)" ///
						7"Routine ANC place within village" 999"Don't know/Don't remember" ///
						888"Other" 
	lab val anc_where ancwhere 
	tab anc_where, m 
	
	
	local ancwhere 	`""Home" "Government hospital" "Private Clinic" "SRHC-RHC" "EHO Clinic" "EHO clinic mobile team (within village)" "Routine ANC place within village" "Other""'
						
	levelsof anc_where, local(places)
	
	local i = 1
	foreach x in `places' {
		
		local label : word `i' of `ancwhere'
		
		gen anc_where_`x' = (anc_where == `x')
		replace anc_where_`x' = .m if mi(anc_yn)
		
		lab var anc_where_`x' "`label'"
		
		tab anc_where_`x' , m 
		
		local i = `i' + 1
	}
	
	
	order anc_where_*, after(anc_where)
	
	// anc_*_who
	local phase anc pnc nbc 
	local places home hosp pc rhc ehoc ehom vill othp
	
	foreach p in `places'{
	    
		tab anc_`p'_who, m 
	}
	
	
	local numbers 1 2 3 4 5 6 7 8 9 10 11 888
	
   
	foreach n in `numbers' {
		
		egen anc_who_`n' = rowtotal(anc_home_who`n' anc_hosp_who`n' anc_pc_who`n' ///
									anc_rhc_who`n' anc_ehoc_who`n' anc_ehom_who`n' ///
									anc_vill_who`n' anc_othp_who`n')
									
		replace anc_who_`n' = 1 if anc_who_`n' > 1
		replace anc_who_`n' = .m if mi(anc_yn) // anc_yn != 1
		tab anc_who_`n' , m 
	}

	lab var anc_who_1 	"Specialist"
	lab var anc_who_2 	"Doctor"
	lab var anc_who_3 	"Nurse"
	lab var anc_who_4 	"Health assistant"
	lab var anc_who_5 	"Private doctor"
	lab var anc_who_6 	"LHV"
	lab var anc_who_7 	"Midwife" 
	lab var anc_who_8 	"AMW"
	lab var anc_who_9 	"Ethnic health worker"
	lab var anc_who_10 	"Community Health Worker "
	lab var anc_who_11 	"TBA"
	lab var anc_who_888 "Other"
 
	gen anc_who_trained 	= (	anc_who_1 == 1 | anc_who_2 == 1 | anc_who_3 == 1 | ///
								anc_who_4 == 1 | anc_who_5 == 1 | anc_who_6 == 1 | ///
								anc_who_7 == 1 | anc_who_8 == 1 | anc_who_9 == 1)
	replace anc_who_trained = .m if mi(anc_yn) // anc_yn != 1
	lab var anc_who_trained "ANC with trained health personnel"
	tab anc_who_trained, m 
	
	/*
	rename anc_pc_who anc_who_pc
	split anc_who_pc, p(" ")
	
	destring anc_who_pc*, replace 
	
	local numbers 1 2 3 4 5 6 7 8 9 10 11 888

	foreach x in `numbers' {
	    
		gen anc_who_pc_`x' = 0 
		replace anc_who_pc_`x' = .m if mi(anc_who_pc)
		
	}
	
	
	foreach x in `numbers' {
	   		
		replace anc_who_pc_`x' = 1 if anc_who_pc1 ==  `x'
		replace anc_who_pc_`x' = 1 if anc_who_pc2 ==  `x'
		replace anc_who_pc_`x' = 1 if anc_who_pc3 ==  `x'
		
		tab1 anc_pc_who`x' anc_who_pc_`x', m 
												
	}
	
	*/
	

	// anc_*_visit
	local places home hosp pc rhc ehoc ehom vill othp
	
	foreach p in `places' {
	    
		replace anc_`p'_visit = .m if anc_`p'_visit == 444
		tab anc_`p'_visit, m 
		
	}
	
	egen anc_who_tot = rowtotal(	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
									anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
									anc_who_11 anc_who_888)
	replace anc_who_tot = .m if mi(anc_yn) // anc_yn != 1
	tab anc_who_tot, m 
	
	egen anc_all_visit_tot = rowtotal(	anc_home_visit anc_hosp_visit anc_pc_visit ///
										anc_rhc_visit anc_ehoc_visit anc_ehom_visit ///
										anc_vill_visit anc_othp_visit)
	replace anc_all_visit_tot = round(anc_all_visit_tot / anc_who_tot, 1)
	replace anc_all_visit_tot = 0 if anc_yn == 0
	replace anc_all_visit_tot = .m if mi(anc_yn) // anc_yn != 1
	
	tab anc_all_visit_tot, m 
	
	
	local numbers 1 2 3 4 5 6 7 8 9 10 11 888
	
	
	foreach x in `numbers' {
	    
		gen anc_who_visit_`x' 		= .m 
		
	}
	
	    
	foreach n in `numbers' {
		
		replace anc_who_visit_`n' 	= anc_all_visit_tot if anc_who_`n' == 1
		replace anc_who_visit_`n' 	= 0 if anc_who_`n' == 0
		
		tab anc_who_visit_`n', m 
	}
		
	lab var anc_who_visit_1 	"Specialist"
	lab var anc_who_visit_2 	"Doctor"
	lab var anc_who_visit_3 	"Nurse"
	lab var anc_who_visit_4 	"Health assistant"
	lab var anc_who_visit_5 	"Private doctor"
	lab var anc_who_visit_6 	"LHV"
	lab var anc_who_visit_7 	"Midwife" 
	lab var anc_who_visit_8 	"AMW"
	lab var anc_who_visit_9 	"Ethnic health worker"
	lab var anc_who_visit_10 	"Community Health Worker "
	lab var anc_who_visit_11 	"TBA"
	lab var anc_who_visit_888 	"Other"
	
	egen anc_visit_trained =  rowtotal(	anc_who_visit_1 anc_who_visit_2 anc_who_visit_3 ///
										anc_who_visit_4 anc_who_visit_5 anc_who_visit_6 ///
										anc_who_visit_7 anc_who_visit_8 anc_who_visit_9)
	replace anc_visit_trained = .m if mi(anc_who_trained)
	tab anc_visit_trained, m 
	
	gen anc_visit_trained_4times = (anc_visit_trained >= 4 & !mi(anc_visit_trained))
	replace anc_visit_trained_4times = .m if mi(anc_visit_trained)
	tab anc_visit_trained_4times, m 
	
	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	replace deliv_place = .m if anc_adopt != 0
	tab deliv_place, m 
	
	lab def delivplace 	1"Home" 2"Government hospital" 3"Private Clinic" 4"SRHC-RHC" ///
						5"EHO Clinic" 6"EHO clinic mobile team (within village)" ///
						888"Other"
	lab val deliv_place delivplace 
	tab deliv_place, m 

	// Institutional Deliveries
	gen insti_birth 	= (deliv_place > 1 & deliv_place < 6)
	replace insti_birth = .m if mi(deliv_place)
	lab var insti_birth "Institutional Deliveries"
	tab insti_birth, m 
	
	
	// deliv_assist
	replace deliv_assist = .m if anc_adopt != 0
	tab deliv_assist, m 

	lab def delivwho 	1"Doctor" 2"Nurse" 3"Health assistant" 4"Private doctor" 5"LHV" ///
						6"Midwife" 7"AMW" 8"Ethnic health worker" 9"Community Health Worker" ///
						10"TBA" 11"On my own" 12"Relatives" 888"Other" 999"Don't Know"
	lab val deliv_assist delivwho  
	tab deliv_assist, m 
	
	// Births attended by skilled health personnel
	gen skilled_battend 		= (deliv_assist < 9 )
	replace skilled_battend 	= .m if mi(deliv_assist)
	lab var skilled_battend "Births attended by skilled health personnel"
	tab skilled_battend, m 


	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// pnc_yn 
	replace pnc_yn = .m if anc_adopt != 0
	tab pnc_yn, m 
	
	// pnc_where 
	replace pnc_where = .m if pnc_yn != 1
	lab val pnc_where ancwhere 
	tab pnc_where, m 
	
	local pncwhere 	`""Home" "Government hospital" "Private Clinic" "SRHC-RHC" "EHO Clinic" "EHO clinic mobile team (within village)" "Routine ANC place within village" "Don't know/Don't remember" "Other""'
						
	levelsof pnc_where, local(places)
	
	local i = 1
	foreach x in `places' {
		
		local label : word `i' of `pncwhere'
		
		gen pnc_where_`x' = (pnc_where == `x')
		replace pnc_where_`x' = .m if mi(pnc_yn)
		
		lab var pnc_where_`x' "`label'"
		
		tab pnc_where_`x' , m 
		
		local i = `i' + 1
	}
	
	order pnc_where_*, after(pnc_where)

	// pnc_*_who
	local numbers 1 2 3 4 5 6 7 8 9 10 11 888
	
	foreach n in `numbers' {
		
		egen pnc_who_`n' = rowtotal(pnc_home_who`n' pnc_hosp_who`n' pnc_pc_who`n' ///
									pnc_rhc_who`n' pnc_ehoc_who`n' pnc_ehom_who`n' ///
									pnc_vill_who`n' pnc_othp_who`n')
									
		replace pnc_who_`n' = 1 if pnc_who_`n' > 1
		replace pnc_who_`n' = .m if mi(pnc_yn) // pnc_yn != 1
		tab pnc_who_`n' , m 
	}
	
	lab var pnc_who_1 	"Specialist"
	lab var pnc_who_2 	"Doctor"
	lab var pnc_who_3 	"Nurse"
	lab var pnc_who_4 	"Health assistant"
	lab var pnc_who_5 	"Private doctor"
	lab var pnc_who_6 	"LHV"
	lab var pnc_who_7 	"Midwife" 
	lab var pnc_who_8 	"AMW"
	lab var pnc_who_9 	"Ethnic health worker"
	lab var pnc_who_10 	"Community Health Worker "
	lab var pnc_who_11 	"TBA"
	lab var pnc_who_888 "Other"
 
	gen pnc_who_trained 	= (	pnc_who_1 == 1 | pnc_who_2 == 1 | pnc_who_3 == 1 | ///
								pnc_who_4 == 1 | pnc_who_5 == 1 | pnc_who_6 == 1 | ///
								pnc_who_7 == 1 | pnc_who_8 == 1 | pnc_who_9 == 1)
	replace pnc_who_trained = .m if mi(pnc_yn) // pnc_yn != 1
	lab var pnc_who_trained "PNC with trained health personnel"
	tab pnc_who_trained, m 
	
	
	****************************************************************************
	** Mom NBC **
	****************************************************************************
	// nbc_yn 
	replace nbc_yn = .m if anc_adopt != 0
	replace nbc_yn = .d if nbc_yn == 999
	tab nbc_yn, m 
	
	// nbc_2days_yn
	replace nbc_2days_yn = .m if anc_adopt != 0
	replace nbc_2days_yn = .d if nbc_2days_yn == 999
	tab nbc_2days_yn, m 
	
	// nbc_where
	replace nbc_where = .m if nbc_yn != 1	
	lab val nbc_where ancwhere 
	tab nbc_where, m 
	
	
	local nbcwhere 	`""Home" "Government hospital" "Private Clinic" "SRHC-RHC" "EHO Clinic" "EHO clinic mobile team (within village)" "Routine ANC place within village" "Other""'
						
	levelsof nbc_where, local(places)
	
	local i = 1
	foreach x in `places' {
		
		local label : word `i' of `nbcwhere'
		
		gen nbc_where_`x' = (nbc_where == `x')
		replace nbc_where_`x' = .m if mi(nbc_yn)
		
		lab var nbc_where_`x' "`label'"
		
		tab nbc_where_`x' , m 
		
		local i = `i' + 1
	}
	
	order nbc_where_*, after(nbc_where)
	
	// nbc_*_who
	local numbers 1 2 3 4 5 6 7 8 9 10 11 888
	
	foreach n in `numbers' {
		
		egen nbc_who_`n' = rowtotal(nbc_home_who`n' nbc_hosp_who`n' nbc_pc_who`n' ///
									nbc_rhc_who`n' nbc_ehoc_who`n' nbc_ehom_who`n' ///
									nbc_vill_who`n' nbc_othp_who`n')
									
		replace nbc_who_`n' = 1 if nbc_who_`n' > 1
		replace nbc_who_`n' = .m if mi(nbc_yn) // nbc_yn != 1
		tab nbc_who_`n' , m 
	}

	
	lab var nbc_who_1 	"Specialist"
	lab var nbc_who_2 	"Doctor"
	lab var nbc_who_3 	"Nurse"
	lab var nbc_who_4 	"Health assistant"
	lab var nbc_who_5 	"Private doctor"
	lab var nbc_who_6 	"LHV"
	lab var nbc_who_7 	"Midwife" 
	lab var nbc_who_8 	"AMW"
	lab var nbc_who_9 	"Ethnic health worker"
	lab var nbc_who_10 	"Community Health Worker "
	lab var nbc_who_11 	"TBA"
	lab var nbc_who_888 "Other"
 
	gen nbc_who_trained 	= (	nbc_who_1 == 1 | nbc_who_2 == 1 | nbc_who_3 == 1 | ///
								nbc_who_4 == 1 | nbc_who_5 == 1 | nbc_who_6 == 1 | ///
								nbc_who_7 == 1 | nbc_who_8 == 1 | nbc_who_9 == 1)
	replace nbc_who_trained = .m if mi(nbc_yn) // nbc_yn != 1
	lab var nbc_who_trained "NBC with trained health personnel"
	tab nbc_who_trained, m 
	
	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_midterm_hh_weight_final.dta", /// // pnourish_hh_weight_final
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
					
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(	`mainresp' enu_name ///
										income_lastmonth wealth_quintile_ns wealth_quintile_modify ///
										NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
	keep if _merge == 3
	
	drop _merge 

	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_mom_health_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_mom_health_cleaning.xlsx" 


	** SAVE for analysis dataset 
	save "$dta/pnourish_mom_health_final.dta", replace  


// END HERE 


