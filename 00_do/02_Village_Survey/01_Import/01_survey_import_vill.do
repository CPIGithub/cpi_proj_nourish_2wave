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


/*
br if geo_eho_vt_name == "Ka Nyin Ka Taik" & geo_eho_vill_name == "Pet Ka Ra Lay"
br if geo_eho_vt_name == "Daw Hpyar" & geo_eho_vill_name == "Taung Sun"
br if geo_eho_vt_name == "Kyon Baing" & geo_eho_vill_name == "Naung Li/ No Le"
br if geo_eho_vt_name == "Ka Yit Kyauk Tan" & geo_eho_vill_name == "Kha Yit Kyauk Tan"
br if geo_eho_vt_name == "Daw Hpyar" & geo_eho_vill_name == "Kawt Ka Mar/ Ka Ma Naing"
*/


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
		destring org_team, replace 
		gen org_name 		= "KEHOC" 	if org_team == 1
		replace org_name 	= "YSDA" 	if org_team == 2
		replace org_name	 = "KDHW" 	if org_team == 3

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
	
	destring _all, replace 
	
	save "$dta/`sheet_`x''.dta", replace 
}


// Prepare one Wide format dataset 

	use "$dta/PN_Village_Survey_FINAL.dta", clear
	
** Duplicate Check and Solved ** 

	* drop the forms used for form testing
	drop if uuid == "6854686c-6ed8-4a7d-ac62-b9299ae73bdc"
	drop if uuid == "ab8fffa6-a552-4c5d-9803-9c3d5ef4163f"
	drop if uuid == "7a4b64f5-7f17-4ffd-b72c-bb765bf4f8d2"
	drop if uuid == "0ba81d89-16a3-4b15-9205-486044231251"
	drop if uuid == "e1077b53-a7e3-472b-83ff-0b484d65def4"
	drop if uuid == "34e522c7-67e5-485a-9490-383d6a8e41a0"
	drop if uuid == "45e703b1-6af7-4b1a-b6d6-e397e3c3b27e"
	drop if uuid == "f32a2718-93b8-4cd6-ad1b-a568b33bf015"
	drop if uuid == "e330fcf8-6476-4471-a973-8e2c8f11f1f7"
	drop if uuid == "1e5ec9bc-0987-4768-b7d5-85051855309f"
	drop if uuid == "7b14fa18-e88c-4236-85b6-e26081126985"
	drop if uuid == "7af36f85-27f4-46f5-a5c9-6ba2d0954d78"
	drop if uuid == "b862e5ec-9626-4796-99f4-823b0ae820d6"
	drop if uuid == "efcbe608-e31a-40bb-8c11-44427e5cf65e"
	drop if uuid == "970413f0-e318-4482-8e11-2f40f6f0ab90"
	drop if uuid == "c2665789-39b0-4492-a4f8-6308e8478784"
	drop if uuid == "b779bb0c-7388-40dd-9ebb-7274a4555921"

	* training testing KEHOC and KDHW triaing 
	drop if uuid == "1686f792-69be-4de1-a4a3-ed36561f581f"
	drop if uuid == "5aa096e8-9256-4bb2-b8d2-ab1915fc1bec"
	drop if uuid == "acd5d96d-2fc2-4bfd-ac7e-b983d0210adf"
	drop if uuid == "da460c5b-cca5-4fd3-9826-4c062b163d00"
	drop if uuid == "7217eba0-2c2e-4727-b607-3060e16a5666"
	drop if uuid == "e9d51e62-7468-4f3f-8151-b3251bde648d"
	drop if uuid == "e957b1b2-2fd5-459f-80b8-81ae0b07bdc3"
	
	* correct geo info
	replace geo_vt 		= 1027 				if uuid == "817ae4bd-9a88-4e20-aa0d-ea1dca3db794"
	replace geo_vill 	= 2120 				if uuid == "817ae4bd-9a88-4e20-aa0d-ea1dca3db794"
	replace cal_vt 		= "Bo Khar Lay Kho" if uuid == "817ae4bd-9a88-4e20-aa0d-ea1dca3db794"
	replace cal_vill 	= "Maw Tu Doe" 		if uuid == "817ae4bd-9a88-4e20-aa0d-ea1dca3db794"
	
	replace geo_vt 		= 1074 							if uuid == "4f20fcc9-bac0-45a3-aca2-81c94dc623bd"
	replace geo_vill 	= 2267 							if uuid == "4f20fcc9-bac0-45a3-aca2-81c94dc623bd"
	replace cal_vt 		= "Kha Nein Hpaw" 				if uuid == "4f20fcc9-bac0-45a3-aca2-81c94dc623bd"
	replace cal_vill 	= "Kawt Kyaik (Kha Nein Hpaw)" 	if uuid == "4f20fcc9-bac0-45a3-aca2-81c94dc623bd"


	
	// check var 
	local master _N
	di `master'

	replace geo_vt 		= 1070 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Mun Hlaing"
	replace geo_vill 	= 2255 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Mun Hlaing"

	replace geo_vt = 1062 if cal_vt == "Daw Hpyar" 			& cal_vill == "Daw Hpyar/ Daw Plat"
	replace geo_vt = 1062 if cal_vt == "Daw Hpyar" 			& cal_vill == "Kawt Kha Mi"
	replace geo_vt = 1069 if cal_vt == "Ka Nyin Ka Taik" 	& cal_vill == "Pet Ka Rar"
	replace geo_vt = 1070 if cal_vt == "Ka Yit Kyauk Tan" 	& cal_vill == "Kyauk Yae Twin"
	replace geo_vt = 1075 if cal_vt == "Kyon Baing" 		& cal_vill == "Kawt War Bo/ Ko War Kalu"

	replace geo_vill = 2219 if cal_vt == "Daw Hpyar" 		& cal_vill == "Daw Hpyar/ Daw Plat"
	replace geo_vill = 2222 if cal_vt == "Daw Hpyar" 		& cal_vill == "Kawt Kha Mi"
	replace geo_vill = 2249 if cal_vt == "Ka Nyin Ka Taik" 	& cal_vill == "Pet Ka Rar"
	replace geo_vill = 2254 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Kyauk Yae Twin"
	replace geo_vill = 2273 if cal_vt == "Kyon Baing" 		& cal_vill == "Kawt War Bo/ Ko War Kalu"

	replace geo_vt = 1069 if cal_vt == "Ka Nyin Ka Taik" 	& cal_vill == "Pet Ka Ra Lay"
	replace geo_vt = 1062 if cal_vt == "Daw Hpyar" 			& cal_vill == "Taung Sun"
	replace geo_vt = 1075 if cal_vt == "Kyon Baing" 		& cal_vill == "Naung Li/ No Le"
	replace geo_vt = 1070 if cal_vt == "Ka Yit Kyauk Tan"	& cal_vill == "Kha Yit Kyauk Tan"
	replace geo_vt = 1062 if cal_vt == "Daw Hpyar" 			& cal_vill == "Kawt Ka Mar/ Ka Ma Naing"

	replace geo_vill = 2248 if cal_vt == "Ka Nyin Ka Taik" 	& cal_vill == "Pet Ka Ra Lay"
	replace geo_vill = 2220 if cal_vt == "Daw Hpyar" 		& cal_vill == "Taung Sun"
	replace geo_vill = 2269 if cal_vt == "Kyon Baing" 		& cal_vill == "Naung Li/ No Le"
	replace geo_vill = 2250 if cal_vt == "Ka Yit Kyauk Tan" & cal_vill == "Kha Yit Kyauk Tan"
	replace geo_vill = 2218 if cal_vt == "Daw Hpyar" 		& cal_vill == "Kawt Ka Mar/ Ka Ma Naing"



	// YSDA data 
	preserve 
	tab org_name, m 
	
		keep if org_name == "YSDA"
	
		* add village name and sample size info
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize', keepusing(`mainvar' *_old /*cluster_cat cluster_cat_str*/)
		
		/*
			some YSDA obs using the new form, that why unmatched resulted	
		*/
		
		tab org_name _merge, m 
		
		keep if _merge == 3
		drop _merge 
		
		tempfile ysda
		save `ysda', replace 
		
	restore 
	
	// Non YSDA data 
	
		keep if org_name != "YSDA" | 	(	org_name == "YSDA" & ///
										(	geo_vill == 2002 | /// 
											geo_vill == 2120 | ///
											geo_vill == 2129 | /// 
											geo_vill == 2131 | /// 
											geo_vill == 2132 | /// 
											geo_vill == 2133 | /// 
											geo_vill == 2139 | /// 
											geo_vill == 2140 | /// 
											geo_vill == 2141 | /// 
											geo_vill == 2142 | /// 
											geo_vill == 2145 | /// 
											geo_vill == 2148 | /// 
											geo_vill == 2149 | /// 
											geo_vill == 2152 | /// 
											geo_vill == 2164 | /// 
											geo_vill == 2165 | /// 
											geo_vill == 2167 | /// 
											geo_vill == 2218 | /// 
											geo_vill == 2220 | /// 
											geo_vill == 2248 | /// 
											geo_vill == 2250 | /// 
											geo_vill == 2255 | /// 
											geo_vill == 2258 | /// 
											geo_vill == 2261 | /// 
											geo_vill == 2269 | /// 
											geo_vill == 2313 | /// 
											geo_vill == 2327 | /// 
											geo_vill == 2328 | /// 
											geo_vill == 2329 | /// 
											geo_vill == 2330 | /// 
											geo_vill == 2425 | /// 
											geo_vill == 2427 ))
		
		merge m:1 geo_town geo_vt geo_vill using `dfsamplesize_new', keepusing(`mainvar' cluster_cat cluster_cat_str)
		
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



do "$villimport/PN_Village_Survey_FINAL_labeling.do"



// duplicate by geo-person
duplicates tag	geo_town geo_vt geo_vill vill_data_yes ///
				rpl_geo_town rpl_geo_vt rpl_geo_vill rpl_vill_data_yes ///
				will_participate vill_data_yes, gen(dup_vill)
tab dup_vill, m 
		
drop dup_vill 

save "$dta/PN_Village_Survey_FINAL.dta", replace 

		
		
		
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

	drop if _merge == 2

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

	drop if _merge == 2

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

	drop if _merge == 2

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

	drop if _merge == 2

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

	drop if _merge == 2

	drop _merge 

}

save "$dta/pnourish_village_svy_wide.dta", replace  

