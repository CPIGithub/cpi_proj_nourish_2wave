/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: enumerator performance			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

*Adding title table 1
clear
set obs 1
gen title = ""
replace title = "TABLE 1: % SURVEY LENGTH ISSUES" in 1
export excel title using "$out/06_hcf_enu_performance.xlsx", sheet("01_SUMMARY") sheetreplace cell(A1) 

*Adding title table 2
clear
set obs 1
gen title = ""
replace title = "TABLE 2:  % SURVEY LENGTH ISSUES BY ENUMERATOR" in 1
export excel title using "$out/06_hcf_enu_performance.xlsx", sheet("01_SUMMARY") sheetmodify cell(A6) 
		
		
use "$dta/pnourish_hh_svy_wide.dta", clear 

gen tot_obs = _N
bysort org_name svy_team enu_name: gen enu_tot_obs = _N 



** Survey Duration **
gen svy_dur = round((endtime - starttime) / (60000), 0.01) // milliseconds divide by 60000
replace svy_dur = .m if mi(endtime) | mi(starttime)

egen svy_dur_mean = mean(svy_dur)

sum svy_dur

gen svy_dur_long = (svy_dur > 60 /*(svy_dur_mean + (`r(sd)' * 2))*/)
replace svy_dur_long = .m if mi(svy_dur) //| mi(svy_dur_mean)

gen svy_dur_short = (svy_dur < 10 /*(svy_dur_mean - (`r(sd)' * 2))*/)
replace svy_dur_short = .m if mi(svy_dur) //| mi(svy_dur_mean)

** Module duration **
local timesvar	cal_consent	cal_hhroster	cal_iycf	cal_housing	cal_wemp	cal_phq	/*cal_iycfk*/	///
				cal_dksum	cal_dkrain	cal_dkwint	cal_wpot	cal_latrine	cal_hw	cal_hwct	///
				cal_hhinc	cal_fies	cal_pexp	cal_muac
			
/*

XLS programming - module starttime and endtime are identical with survey start and endtime
the programming did not work as planned
need to use audit csv file for module duration calculation


			
foreach v in `timesvar' {
	
	gen double `v'_dur = round((`v'_end_c - `v'_start_c) / (60000), 0.01)
	replace `v'_dur = .m if mi(`v'_end_c) | mi(`v'_start_c)
	
	egen `v'_dur_mean = mean(`v'_dur)
	order `v'_dur, after(`v'_end_c)

	sum `v'_dur
	gen `v'_dur_long = (`v'_dur > (`v'_dur_mean + (`r(sd)' * 2)))
	replace `v'_dur_long = .m if mi(`v'_dur) | mi(`v'_dur_mean)
	
	gen `v'_dur_short = (`v'_dur < (`v'_dur_mean - (`r(sd)' * 2)))
	replace `v'_dur_short = .m if mi(`v'_dur) | mi(`v'_dur_mean)
	
	// within one minute 
	gen `v'_onemin = (`v'_end_c == `v'_start_c)
	
}
*/

// export table

keep if svy_dur_long == 1 | svy_dur_short == 1


gen tot_flag 			= _N
gen tot_flag_shared 	= round(tot_flag/tot_obs, 0.001)

gen tot_long 			= _N if svy_dur_long == 1
gen tot_short 			= _N if svy_dur_short == 1
gen tot_long_shared 	= round(tot_long/tot_obs, 0.001)
gen tot_short_shared 	= round(tot_short/tot_obs, 0.001)



preserve

keep if _n == 1
keep tot_obs tot_flag tot_flag_shared tot_long tot_long_shared tot_short tot_short_shared
order tot_obs tot_flag tot_flag_shared tot_long tot_long_shared tot_short tot_short_shared

lab var tot_obs 			"Total obs"
lab var tot_flag 			"Total survey duration flag obs"
lab var tot_flag_shared		"Survey duration flag shared"
lab var tot_long			"Total long survey obs"
lab var tot_short			"Total short survey obs" 
lab var tot_long_shared		"Long survey shared"
lab var tot_short_shared	"Short survey shared"


export excel using "$out/06_hcf_enu_performance.xlsx", sheet("01_SUMMARY") firstrow(varlabels) cell(A2) keepcellfmt sheetmodify

restore 


// summary 
preserve 

bysort org_name svy_team enu_name: gen enu_flag_num = _N 
bysort org_name svy_team enu_name: keep if _n == 1

gen enu_flag_shared = round(enu_flag_num/enu_tot_obs, 0.001)


keep enu_flag_num enu_flag_shared enu_tot_obs enu_name svy_team org_name

rename enu_flag_* *_enu_flag
rename enu_tot_obs tot_obs_enu_flag

gen sir = _n 

reshape long num_ tot_obs_ shared_ , i(sir) j(var) string  

replace sir = _n 
drop var 

order org_name svy_team enu_name tot_obs_ num_ shared_ 

lab var org_name 	"Organization Name"
lab var svy_team 	"Survey Team Number"
lab var enu_name 	"Enumerator Name"
lab var tot_obs_ 	"Total survey by enumerator"
lab var num_ 		"Total survey duration flag obs by enumerator"
lab var shared_ 	"Shared of survey duration flag by enumerator"

export excel using "$out/06_hcf_enu_performance.xlsx", sheet("01_SUMMARY") firstrow(varlabels) cell(A7) keepcellfmt sheetmodify


restore 


// detailed cases
preserve
keep	township_name geo_eho_vt_name geo_eho_vill_name stratum ///
		enu_name svy_team org_name uuid svy_date ///
		respd_name respd_sex respd_age ///
		starttime endtime svy_dur svy_dur_mean svy_dur_long svy_dur_short 

order 	svy_date township_name geo_eho_vt_name geo_eho_vill_name stratum ///
		org_name svy_team enu_name ///
		respd_name respd_sex respd_age ///
		starttime endtime svy_dur svy_dur_mean svy_dur_long svy_dur_short uuid


lab var org_name 		"Organization name"
lab var svy_team 		"Survey team number"
lab var enu_name 		"Enumerator"
lab var starttime	 	"Survey start time"
lab var endtime 		"Survey end time"
lab var svy_dur 		"Survey duration (minute)"
lab var svy_dur_mean 	"Average survey duration"
lab var svy_dur_long 	"Long survey"
lab var svy_dur_short 	"Short survey"
lab var uuid			"Survey key id - uuid"

if _N {
    
	export excel using "$out/06_hcf_enu_performance.xlsx", sheet("02_DETAILED_OBS") firstrow(varlabels) keepcellfmt sheetreplace

}

restore 






/*
* mean suration *
preserve
keep if _n == 1

rename *_dur_mean mean_*_dur 

gen sir = _n

keep mean_*_dur  sir // enu_name svy_team

reshape long mean_ , i(sir) j(var_name) string 

drop sir 

order var_name mean 

replace var_name = "Consent administration" 					if var_name == "cal_consent_dur"
replace var_name = "Drinking water - raining" 					if var_name == "cal_dkrain_dur"
replace var_name = "Drinking water - summer" 					if var_name == "cal_dksum_dur"
replace var_name = "Drinking water - winter" 					if var_name == "cal_dkwint_dur"
replace var_name = "Food Insecurity Experience Scale (FIES)" 	if var_name == "cal_fies_dur"
replace var_name = "Household Income" 							if var_name == "cal_hhinc_dur"
replace var_name = "Household roster" 							if var_name == "cal_hhroster_dur"
replace var_name = "Household characteristics" 					if var_name == "cal_housing_dur"
replace var_name = "Handwashing overall module" 				if var_name == "cal_hw_dur"
replace var_name = "Handwashing critical time questions" 		if var_name == "cal_hwct_dur"
replace var_name = "Infant and young child feeding" 			if var_name == "cal_iycf_dur"
replace var_name = "Latrine module" 							if var_name == "cal_latrine_dur"
replace var_name = "MUAC module" 								if var_name == "cal_muac_dur"
replace var_name = "Program Exposure" 							if var_name == "cal_pexp_dur"
replace var_name = "PHQ module" 								if var_name == "cal_phq_dur"
replace var_name = "Women Empowerment" 							if var_name == "cal_wemp_dur"
replace var_name = "Water pot observation" 						if var_name == "cal_wpot_dur"
replace var_name = "Survey length" 								if var_name == "svy_dur"

export excel using "$out/06_hcf_enu_performance.xlsx", sheet("01_svy_duration") firstrow(varlabels) sheetreplace

restore 

*/
/*

* duration flag * 
rename *_dur 		dur_*
rename *_dur_mean 	mean_dur_*
rename *_dur_long 	long_dur_*
rename *_dur_short 	short_dur_*
rename *_onemin 	onemin_*

rename *_start_c start_c_*
rename *_end_c end_c_*

gen sir = _n

keep mean_dur_* long_dur_* short_dur_* start_c_* end_c_* dur_* onemin_* sir uuid enu_name svy_team

reshape long start_c_ end_c_ dur_ mean_dur_ long_dur_ short_dur_ onemin_ , i(sir) j(var_name) string 

drop sir 

rename dur_ 		duration 
rename mean_dur_ 	mean_duration 
rename long_dur_ 	long_duration
rename short_dur_ 	short_duration
rename start_c 		start 
rename end_c 		end 
rename onemin		one_minute

order svy_team enu_name uuid var_name start end duration one_minute mean_duration long_duration short_duration 

replace var_name = "Consent administration" 					if var_name == "cal_consent"
replace var_name = "Drinking water - raining" 					if var_name == "cal_dkrain"
replace var_name = "Drinking water - summer" 					if var_name == "cal_dksum"
replace var_name = "Drinking water - winter" 					if var_name == "cal_dkwint"
replace var_name = "Food Insecurity Experience Scale (FIES)" 	if var_name == "cal_fies"
replace var_name = "Household Income" 							if var_name == "cal_hhinc"
replace var_name = "Household roster" 							if var_name == "cal_hhroster"
replace var_name = "Household characteristics" 					if var_name == "cal_housing"
replace var_name = "Handwashing overall module" 				if var_name == "cal_hw"
replace var_name = "Handwashing critical time questions" 		if var_name == "cal_hwct"
replace var_name = "Infant and young child feeding" 			if var_name == "cal_iycf"
replace var_name = "Latrine module" 							if var_name == "cal_latrine"
replace var_name = "MUAC module" 								if var_name == "cal_muac"
replace var_name = "Program Exposure" 							if var_name == "cal_pexp"
replace var_name = "PHQ module" 								if var_name == "cal_phq"
replace var_name = "Women Empowerment" 							if var_name == "cal_wemp"
replace var_name = "Water pot observation" 						if var_name == "cal_wpot"
replace var_name = "Survey length" 								if var_name == "svy"


preserve
keep if long_duration ==  1 | short_duration == 1 | one_minute == 1


if _N > 0 {

	export excel using "$out/06_hcf_enu_performance.xlsx", sheet("02_duration_flag") firstrow(varlabels) sheetreplace
	
}

restore 
*/

* END here 


 

