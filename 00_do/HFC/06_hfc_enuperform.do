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

gen svy_dur_flag = (svy_dur > (svy_dur_mean + `r(sd)') | svy_dur < (svy_dur_mean - `r(sd)'))
replace svy_dur_flag = .m if mi(svy_dur) | mi(svy_dur_mean)


** Module duration **
local timesvar	cal_consent	cal_hhroster	cal_iycf	cal_housing	cal_wemp	cal_phq	cal_iycfk	///
				cal_dksum	cal_dkrain	cal_dkwint	cal_wpot	cal_latrine	cal_hw	cal_hwct	///
				cal_hhinc	cal_fies	cal_pexp	cal_muac
			
			
			
foreach v in `timesvar' {
	
	gen double `v'_dur = round((`v'_end_c - `v'_start_c) / (60000), 0.01)
	replace `v'_dur = .m if mi(`v'_end_c) | mi(`v'_start_c)
	
	egen `v'_dur_mean = mean(`v'_dur)
	order `v'_dur, after(`v'_end_c)

	sum `v'_dur
	gen `v'_dur_flag = (`v'_dur > (`v'_dur_mean + `r(sd)') | `v'_dur < (`v'_dur_mean - `r(sd)'))
	replace `v'_dur_flag = .m if mi(`v'_dur) | mi(`v'_dur_mean)
	
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

export excel using "$out/06_hcf_enu_performance.xlsx", sheet("01_svy_duration") firstrow(varlabels) sheetreplace

restore 


* duration flag * 
rename *_dur dur_*
rename *_dur_mean mean_dur_*
rename *_dur_flag flag_dur_*

rename *_start start_*
rename *_end end_*

gen sir = _n

keep mean_dur_* flag_dur_* start_* end_* dur_* sir uuid enu_name svy_team

reshape long start_ end_ dur_ mean_dur_ flag_dur_  , i(sir) j(var_name) string 

drop sir 

rename dur_ 		duration 
rename mean_dur_ 	mean_duration 
rename flag_dur_ 	flag_duration
rename start_ 		start 
rename end_ 		end 

order svy_team enu_name uuid var_name start end duration mean_duration flag_duration 

preserve
keep if flag_duration ==  1

if _N > 0 {

	export excel using "$out/06_hcf_enu_performance.xlsx", sheet("02_duration_flag") firstrow(varlabels) sheetreplace
	
}

restore 


* END here 


 

