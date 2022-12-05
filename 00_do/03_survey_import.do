/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	import raw data into dta format 				
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* import Sample Size Data *
********************************************************************************

import delimited using "$result/pn_2_samplelist.csv", clear 
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 

local mainvar township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster vill_samplesize sample_check

tempfile dfsamplesize
save `dfsamplesize', replace 
clear 



********************************************************************************
* import villages survey *
********************************************************************************
/*
import delimited using "$raw/pnourish_village_svy.csv", clear

* rename variable for proper data processing
rename _* *
//rename enu_end_note  enu_svyend_note 

lookfor _start _end starttime endtime submission

foreach var in `r(varlist)' {
    
	di "`var'"
	split `var', p(".")
	
	if "`var'" != "submission_time" {
	    drop `var'2
	} 
	
	gen `var'_c = clock(`var'1, "20YMDhms" )
	format `var'_c %tc 
	order `var'_c, after(`var')
	
	drop `var'1 
}

save "$dta/pnourish_village_svy.dta", replace 
*/


********************************************************************************
* import household survey *
********************************************************************************

import delimited using "$raw/pnourish_hh_svy.csv", clear

* rename variable for proper data processing
rename _* *
rename enu_end_note  enu_svyend_note 

lookfor _start _end starttime endtime submission

foreach var in `r(varlist)' {
    
	di "`var'"
	replace `var' = subinstr(`var', "T", " ", 1)
	split `var', p(".")
	
	if "`var'" != "submission_time" {
	    drop `var'2
	} 
	
	gen double `var'_c = clock(`var'1, "20YMDhms" )
	format `var'_c %tc 
	order `var'_c, after(`var')
	
	drop `var'1 
}

* add village name and sample size info
merge m:1 geo_town geo_vt geo_vill using `dfsamplesize', keepusing(`mainvar')

drop if _merge == 2
drop _merge 


save "$dta/pnourish_hh_svy.dta", replace 



