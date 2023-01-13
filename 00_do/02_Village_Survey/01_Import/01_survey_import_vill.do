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
* import villages survey *
********************************************************************************
/*
import delimited using "$raw/pnourish_village_svy.csv", clear

* rename variable for proper data processing
rename _* *
//rename enu_end_note  enu_svyend_note 

* date/time formatting
lookfor _start _end starttime endtime submission

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

gen svy_date = dofc(starttime_c)
format svy_date %td
order svy_date, before(starttime_c)

* labeling  
gen org_name = "KEHOC" if org_team == 1
replace org_name = "YSDA" if org_team == 2

tostring superv_name, replace 
replace superv_name = "Thiri Aung" 			if superv_name == "1"
replace superv_name = "Saw Than Naing" 		if superv_name == "2"
replace superv_name = "Man Win Htwe" 		if superv_name == "3"
replace superv_name = "Nan Khin Hnin Thaw" 	if superv_name == "4"
replace superv_name = "Ma Nilar Tun" 		if superv_name == "5"
replace superv_name = "Saw Ku Mu Kay Htoo" 	if superv_name == "6"

// keep only final data colletion data 
keep if svy_date >= td(19dec2022) & !mi(svy_date)

save "$dta/pnourish_village_svy.dta", replace 
*/


********************************************************************************
* import household survey *
********************************************************************************

import excel using "$raw/pnourish_village_svy.xlsx", describe

forvalue x = 1/`r(N_worksheet)' {
	
	local sheet_`x' `r(worksheet_`x')'
}

forvalue x = 1/`r(N_worksheet)' {
	
	import excel using "$raw/pnourish_village_svy.xlsx", sheet("`sheet_`x''") firstrow clear 
	
	if `x' == 1 {
		
		* rename variable for proper data processing
		rename _* *

		lookfor cal_ starttime endtime submission //cal*_start cal*_end 

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

		gen svy_date = dofc(starttime_c)
		format svy_date %td
		order svy_date, before(starttime_c)


		* labeling  
		gen org_name = "KEHOC" if org_team == "1"
		replace org_name = "YSDA" if org_team == "2"

		tostring superv_name, replace 
		replace superv_name = "Thiri Aung" 			if superv_name == "1"
		replace superv_name = "Saw Than Naing" 		if superv_name == "2"
		replace superv_name = "Man Win Htwe" 		if superv_name == "3"
		replace superv_name = "Nan Khin Hnin Thaw" 	if superv_name == "4"
		replace superv_name = "Ma Nilar Tun" 		if superv_name == "5"
		replace superv_name = "Saw Ku Mu Kay Htoo" 	if superv_name == "6"

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
	
	destring _all, replace 
	
	save "$dta/`sheet_`x''.dta", replace 
}


// Prepare one Wide format dataset 

use "$dta/PN_Village_Survey_FINAL.dta", clear

** demo_migrate_rep - migration information 

count if demo_migrate == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_migrate_rep.dta", clear

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_migrate, replace

		rename * *_
		rename cal_migrate_ cal_migrate

		reshape wide *_ , i(_parent_index) j(cal_migrate)

		tempfile demo_migrate_rep
		save `demo_migrate_rep', replace 

	restore

	merge 1:1 _parent_index using `demo_migrate_rep'

	keep if _merge == 3

	drop _merge 

}




** demo_idp_rep - IDP information 

count if demo_idp == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_idp_rep.dta", clear

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_idp, replace

		rename * *_
		rename cal_idp_ cal_idp

		reshape wide *_ , i(_parent_index) j(cal_idp)

		tempfile demo_idp_rep
		save `demo_idp_rep', replace 

	restore

	merge 1:1 _parent_index using `demo_idp_rep'

	keep if _merge == 3

	drop _merge 

}


** demo_dspl_rpt - displaced population information not included yet 

count if demo_dspl == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_dspl_rpt.dta", clear

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_dspl, replace

		rename * *_
		rename cal_dspl_ cal_dspl

		reshape wide *_ , i(_parent_index) j(cal_dspl)

		tempfile demo_dspl_rpt
		save `demo_dspl_rpt', replace 

	restore

	merge 1:1 _parent_index using `demo_dspl_rpt'

	keep if _merge == 3

	drop _merge 

}

** lh_rpt - liveihood information 
count if demo_dspl == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/lh_rpt.dta", clear

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_livelihood, replace

		rename * *_
		rename cal_livelihood_ cal_livelihood

		reshape wide *_ , i(_parent_index) j(cal_livelihood)

		tempfile lh_rpt
		save `lh_rpt', replace 

	restore

	merge 1:1 _parent_index using `lh_rpt'

	keep if _merge == 3

	drop _merge 

}



** pn_dev_rpt - development project info 
count if proj_num > 0

if `r(N)' > 0  {
	
		preserve
		use "$dta/pn_dev_rpt.dta", clear

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_dev, replace

		rename * *_
		rename cal_dev_ cal_dev

		reshape wide *_ , i(_parent_index) j(cal_dev)

		tempfile pn_dev_rpt
		save `pn_dev_rpt', replace 

	restore

	merge 1:1 _parent_index using `pn_dev_rpt'

	keep if _merge == 3

	drop _merge 

}

save "$dta/pnourish_village_svy.dta", replace  

