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

import delimited using "$result/pn_2_samplelist_old.csv", clear 
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 

local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
				vill_samplesize sample_check 

tempfile dfsamplesize
save `dfsamplesize', replace 
clear 

import delimited using "$result/pn_2_samplelist.csv", clear 
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 

local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
				vill_samplesize sample_check 
				
				
foreach var in `mainvar' {
    
	rename `var' `var'_n
	
}

local mainvar_n 	township_name_n geo_eho_vt_name_n geo_eho_vill_name_n stratum_n ///
					num_cluster_n vill_samplesize_n sample_check_n 

tempfile dfsamplesize_new
save `dfsamplesize_new', replace 
clear 


********************************************************************************
* import village survey *
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

		lookfor /*cal_*/ starttime endtime submission cal*_start cal*_end 

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


		* add village name and sample size info
		destring geo_vt geo_vill, replace 
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize', keepusing(`mainvar' /*cluster_cat cluster_cat_str*/)
		
		drop if _merge == 2
		drop _merge 

		destring cluster_cat, replace 
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize_new', keepusing(`mainvar_n' cluster_cat cluster_cat_str)
		
		drop if _merge == 2

		foreach var in `mainvar' {
		    
			replace `var'= `var'_n if mi(`var') & !mi(`var'_n) & _merge == 3
			
		}
		
		drop _merge 
		
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

do "$villimport/PN_Village_Survey_FINAL_labeling.do"
		
** demo_migrate_rep - migration information 

count if demo_migrate == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_migrate_rep.dta", clear
		
		* lab var 
		lab var demo_migrate_why "Reasons (for migration)"
		lab var demo_migrate_area "Area of Migration"
		lab var demo_migrate_hh "Proportion of HH"
		lab var demo_migrate_season "Seasons"
		lab var demo_migrate_season1 "Summer"
		lab var demo_migrate_season2 "Raining"
		lab var demo_migrate_season3 "Winter"
		lab var demo_migrate_season0 "Not a seasonal"
		lab var demo_migrate_change "Did it change significantly after February 2021?"
		lab var demo_migrate_scale "If yes, was it increasing or decreasing compared to before February 2021?"


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

	// keep if _merge == 3

	drop _merge 

}




** demo_idp_rep - IDP information 

count if demo_idp == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_idp_rep.dta", clear
		
		* lab var 
		lab var demo_idp_why "Reasons (for displacement)"
		lab var demo_idp_area "From which area (mention township name)"
		lab var demo_idp_pop "Number of hosted displaced people"
		lab var demo_idp_when "From when?"
		lab var demo_idp_still "Are those displaced people still living in your village?"
		lab var demo_idp_period "When did the last month they leave your village?"


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

	// keep if _merge == 3

	drop _merge 

}


** demo_dspl_rpt - displaced population information not included yet 

count if demo_dspl == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/demo_dspl_rpt.dta", clear
		
		* lab var 

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

	// keep if _merge == 3

	drop _merge 

}

** lh_rpt - liveihood information 
count if demo_dspl == 1

if `r(N)' > 0  {
	
		preserve
		use "$dta/lh_rpt.dta", clear
		
		* lab var 
		lab var lh_name "Name of Main Livelihood"
		lab var lh_hh "Proportion of HH"
		lab var lh_season "By seasonal or the whole year?"
		lab var lh_season1 "Summer"
		lab var lh_season2 "Raining"
		lab var lh_season3 "Winter"
		lab var lh_season0 "Not a seasonal"
		lab var lh_hh_past "Did it change significantly after February 2021? "
		lab var lh_hh_coup "If yes, was it increasing or decreasing compared to before February 2021?"
		lab var lh_income "Monthly Average Income (estimation) (for one household)"
		lab var lh_income_past "Did it (income) change significantly compared to last year?"
		lab var lh_income_coup "Did it (income) change significantly compared to before early 2021?"


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

	// keep if _merge == 3

	drop _merge 

}



** pn_dev_rpt - development project info 
count if proj_num > 0

if `r(N)' > 0  {
	
		preserve
		use "$dta/pn_dev_rpt.dta", clear
		
		* lab var 
		lab var pn_dev_name "Name of Project"
		lab var pn_dev_type "Type of project "
		lab var pn_dev_type1 "Humanitarian"
		lab var pn_dev_type2 "Development"
		lab var pn_dev_act "Type of activities"
		lab var pn_dev_act1 "Food and Nutrition  "
		lab var pn_dev_act2 "WASH"
		lab var pn_dev_act3 "Health "
		lab var pn_dev_act4 "Shelter  "
		lab var pn_dev_act5 "Livelihood "
		lab var pn_dev_act888 "Other (specify)"
		lab var pn_dev_act_oth "Please specify the other."
		lab var pn_dev_benef "Targeted beneficiaries "
		lab var pn_dev_benef1 "Children  "
		lab var pn_dev_benef2 "Women (15-49 yrs)"
		lab var pn_dev_benef3 "Pregnant and Lactation mothers"
		lab var pn_dev_benef4 "Poor Household "
		lab var pn_dev_benef888 "Other (specify)"
		lab var pn_dev_benef_oth "Please specify the other."
		lab var pn_dev_start "Staring date (year)"
		lab var pn_dev_plan "Project Duration (in year)"
		lab var pn_dev_actual "Actual implementation months"


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

	// keep if _merge == 3

	drop _merge 

}

save "$dta/pnourish_village_svy_wide.dta", replace  

