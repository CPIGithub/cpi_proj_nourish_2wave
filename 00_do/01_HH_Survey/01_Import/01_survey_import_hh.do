/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	import HH raw data into dta format 				
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* import Sample Size Data *
********************************************************************************
// old pre-loaded file
import delimited using "$result/pn_2_samplelist_old.csv", clear 
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 

replace geo_eho_vt_name = geo_eho_vill_name if geo_eho_vill_name == "Wal Ta Ran" 
replace geo_eho_vt_name = geo_eho_vill_name if geo_eho_vill_name == "Lay Wal"

gen geo_vt_old 		= geo_vt 
gen geo_vill_old 	= geo_vill

local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
				vill_samplesize sample_check 

tempfile dfsamplesize
save `dfsamplesize', replace 
clear 

// new pre-loaded file
use "$dta/pn_2_samplelist.dta", clear  
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 

// replace geo_vt = 1071 if geo_eho_vill_name == "Ka Yit Kyauk Tan" | geo_eho_vill_name == "Mun Hlaing"
/*
local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
				vill_samplesize sample_check 
				
				
foreach var in `mainvar' {
    
	rename `var' `var'_n
	
} */

local mainvar_n 	township_name geo_eho_vt_name geo_eho_vill_name stratum ///
					num_cluster vill_samplesize sample_check 

tempfile dfsamplesize_new
save `dfsamplesize_new', replace 

merge m:1 township_name geo_town geo_eho_vt_name geo_eho_vill_name using `dfsamplesize'

replace geo_vt 		= geo_vt_old 	if _merge == 3 & organization == "YSDA"
replace geo_vill 	= geo_vill_old 	if _merge == 3 & organization == "YSDA"

clear 



********************************************************************************
* import household survey *
********************************************************************************

import excel using "$raw/pnourish_hh_svy.xlsx", describe

forvalue x = 1/`r(N_worksheet)' {
	
	local sheet_`x' `r(worksheet_`x')'
}

forvalue x = 1/`r(N_worksheet)' {
	
	import excel using "$raw/pnourish_hh_svy.xlsx", sheet("`sheet_`x''") firstrow clear 
	
	if `x' == 1 {
		
		* rename variable for proper data processing
		rename _* *
		rename enu_end_note  enu_svyend_note 
		lab var enu_svyend_note "enumerator survey end note"

		lookfor _start _end /*starttime endtime submission*/

		foreach var in `r(varlist)' {
			
			di "`var'"
			replace `var' = subinstr(`var', "T", " ", 1)
			split `var', p("+" ".")
			
			if "`var'" != "submission_time" {
				drop `var'2
			} 
			
			gen double `var'_c = clock(`var'1, "20YMDhms" )
			format `var'_c %tc 
			order `var'_c, after(`var')
			
			capture drop `var'1
			capture drop `var'2
			capture drop `var'3
		}

		gen svy_date = dofc(starttime)
		format svy_date %td
		order svy_date, before(starttime)


		* labeling  
		gen org_name = "KEHOC" if org_team == 1
		replace org_name = "YSDA" if org_team == 2
		replace org_name = "KDHW" if org_team == 3

		tostring superv_name, replace 
		replace superv_name = "Thiri Aung" 			if superv_name == "1"
		replace superv_name = "Saw Than Naing" 		if superv_name == "2"
		replace superv_name = "Man Win Htwe" 		if superv_name == "3"
		replace superv_name = "Nan Khin Hnin Thaw" 	if superv_name == "4"
		replace superv_name = "Ma Nilar Tun" 		if superv_name == "5"
		replace superv_name = "Saw Ku Mu Kay Htoo" 	if superv_name == "6"
		replace superv_name = "Saw Eh Poh" 			if superv_name == "7"
		replace superv_name = "Naw Say Wai Htoo" 	if superv_name == "8"
		replace superv_name = "Saw Hla Win Tun" 	if superv_name == "9"
		replace superv_name = "Saw Baw Mu Doh Soe" 	if superv_name == "10"
		replace superv_name = "Saw D' Poe" 			if superv_name == "11"				
				
		// keep only final data colletion data 
		keep if svy_date >= td(19dec2022) & !mi(svy_date)
		
		rename index _parent_index
		
		preserve 
		
			keep _parent_index
			
			tempfile _parent_index
			save `_parent_index', replace 
		
		restore 
		
	}
	else {
		
		
		merge m:1 _parent_index using `_parent_index'
		
		keep if _merge == 3
		
		drop _merge 
		
		
	}
	
	save "$dta/`sheet_`x''.dta", replace 
}


// Prepare one Wide format dataset 

	use "$dta/PN_HH_Survey_FINAL.dta", clear
	
	// check var 
	local master _N
	di `master'
	
	replace geo_vt 		= 1070 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Mun Hlaing"
	replace geo_vill 	= 2251 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Mun Hlaing"

	// YSDA data 
	preserve 
	
		keep if org_name == "YSDA"
	
		* add village name and sample size info
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize', keepusing(`mainvar' *_old /*cluster_cat cluster_cat_str*/)
		
		/*
			unmatched YSDA - one obs 
			geo_town	geo_vt	vt_cluster_cat	geo_vill	cal_town	cal_vt	cal_vill
			MMR003006	1071	1_1071	2251		Ka Yit Kyauk Tan	Mun Hlaing		
		*/
		
		keep if _merge == 3
		drop _merge 
		
		tempfile ysda
		save `ysda', replace 
		
	restore 
	
	// Non YSDA data 
	
		keep if org_name != "YSDA" | (org_name == "YSDA" & geo_vt == 1070 & geo_vill == 2251)
		
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize_new', keepusing(`mainvar' cluster_cat cluster_cat_str)

		/*
		unmatched from one YSDA 
		geo_vt	vt_cluster_cat	geo_vill
		1070		2251

		*/
		
		keep if _merge == 3 
		drop _merge 

		append using `ysda'
		
		tab org_name, m 
		
		// check var 
		local combined _N
		di `combined'
		
		assert `master' == `combined'

		tab1 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
				vill_samplesize sample_check, m 

		
do "$hhimport/PN_HH_Survey_FINAL_labeling.do"


** Duplicate Check and Solved ** 

	* drop the forms used for trianing KECHO and KDHW
	drop if uuid == "2c77dc30-4f08-4184-a75c-dd9b904cfe07"
	drop if uuid == "43f54051-940f-417e-b9c5-7e0b45ae8cbd"
	drop if uuid == "b334432e-b9ad-4b94-b75a-320045118371"
	drop if uuid == "41a7e30a-2e90-43e7-8188-ae9b4fee2d4c"
	drop if uuid == "2c77dc30-4f08-4184-a75c-dd9b904cfe07"
	drop if uuid == "4962b817-424c-4d9b-851b-a91c3467e784"
	drop if uuid == "277e95b9-b0c4-4db0-8dd2-fafcae3453e1"
	drop if uuid == "8abef67b-ed74-460e-9da5-d4840ed9e42d"
	drop if uuid == "40ccdad4-e766-4d13-aebf-bfddfa87776b"
	drop if uuid == "6053426d-bf6e-4cef-8c12-e1b9fe463664"
	drop if uuid == "ddf3acef-2914-41d8-bc13-59e499119963"
	drop if uuid == "de03fa20-b630-4af4-a946-d7119d8d27cb"


	// duplicate by geo-person
	duplicates tag geo_town geo_vt geo_vill respd_name respd_age respd_status, gen(dup_resp)
	tab dup_resp, m 

	order org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

	// duplicate by personal info (exclude geo)
	duplicates tag respd_name respd_age respd_status respd_preg respd_child respd_1stpreg_age respd_chid_num, gen(dup_person)

	tab dup_person, m 
	
	drop dup_resp dup_person
		

		
	* save as long dataset hh level only 
	save "$dta/PN_HH_Survey_HH_Level.dta", replace 

** add hh roster 
preserve
	use "$dta/grp_hh.dta", clear
	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test, replace

	rename * *_
	rename test_ test

	reshape wide *_ , i(_parent_index) j(test)

	tempfile grp_hh
	save `grp_hh', replace 

restore

merge 1:1 _parent_index using `grp_hh'

drop if _merge == 2
drop _merge 


** add child mom info 
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

	rename * *_
	rename cal_hh_cname_id_ cal_hh_cname_id

	reshape wide *_ , i(_parent_index) j(cal_hh_cname_id)

	tempfile hh_child_mom_rep
	save `hh_child_mom_rep', replace 

restore

merge 1:1 _parent_index using `hh_child_mom_rep'

drop if _merge == 2

drop _merge 



** add child iycf info
preserve
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

	rename * *_
	rename child_id_iycf_ child_id_iycf

	reshape wide *_ , i(_parent_index) j(child_id_iycf)

	tempfile iycf
	save `iycf', replace 

restore

merge 1:1 _parent_index using `iycf'

drop if _merge == 2

drop _merge 



** add child health info
preserve
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

	rename * *_
	rename child_id_health_ child_id_health

	reshape wide *_ , i(_parent_index) j(child_id_health)

	tempfile child_vc_rep
	save `child_vc_rep', replace 

restore

merge 1:1 _parent_index using `child_vc_rep'

drop if _merge == 2

drop _merge 


** add mom health info
preserve
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

	rename * *_
	rename women_id_pregpast_ women_id_pregpast

	reshape wide *_ , i(_parent_index) j(women_id_pregpast)

	tempfile anc_rep
	save `anc_rep', replace 

restore

merge 1:1 _parent_index using `anc_rep'

drop if _merge == 2

drop _merge 


** add mom covid info
preserve
	use "$dta/mom_covid_rpt.dta", clear
	
	* lab var 
	lab var mom_covid_note "Covid-19 vaccine - dosage - ${cal_mom_covid} time"
	lab var mom_covid_know "Do you remember the ${cal_mom_covid} time vaccination date? "
	lab var mom_covid_year "If yes, when did you  (${respd_name}) get Covid-19 vaccination?"


	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring cal_mom_covid, replace

	rename * *_
	rename cal_mom_covid_ cal_mom_covid

	reshape wide *_ , i(_parent_index) j(cal_mom_covid)

	tempfile mom_covid_rpt
	save `mom_covid_rpt', replace 

restore

merge 1:1 _parent_index using `mom_covid_rpt'

drop if _merge == 2

drop _merge 


** add child muac info
preserve
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

	rename * *_
	rename child_id_muac_ child_id_muac

	reshape wide *_ , i(_parent_index) j(child_id_muac)

	tempfile child_muac_rep
	save `child_muac_rep', replace 

restore

merge 1:1 _parent_index using `child_muac_rep'

drop if _merge == 2

drop _merge 


save "$dta/pnourish_hh_svy_wide.dta", replace  

