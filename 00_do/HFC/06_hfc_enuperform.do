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

do "00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pnourish_hh_svy.dta", clear 


** Survey Duration **
gen svy_dur = round((endtime_c - starttime_c) / (60000), 0.01) // milliseconds divide by 60000
replace svy_dur = .m if mi(endtime_c) | mi(starttime_c)

egen svy_dur_mean = mean(svy_dur)

sum svy_dur

gen svy_dur_flag = (svy_dur > (svy_dur_mean + (`r(sd)' * 2)) | svy_dur < (svy_dur_mean - (`r(sd)' * 2)))
replace svy_dur_flag = .m if mi(svy_dur) | mi(svy_dur_mean)


** Module duration **
local timesvar	cal_consent	cal_hhroster	cal_iycf	cal_housing	cal_wemp	cal_phq	/*cal_iycfk*/	///
				cal_dksum	cal_dkrain	cal_dkwint	cal_wpot	cal_latrine	cal_hw	cal_hwct	///
				cal_hhinc	cal_fies	cal_pexp	cal_muac
			
			
			
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




// export table
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


* END here 


 

