/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: missing check 			
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

drop starttime-note_title id submission_time-index my_seed cal_* calc_* 

// outlier per variables 
    
foreach v of varlist _all {
	capture confirm numeric variable `v'
	
	if !_rc {
			sum `v', d
			
			if `r(N)' > 0 {
			    
				gen `v'_sd = 3 * `r(sd)'
				gen `v'_ts = (`r(mean)' + `v'_sd)
				
				gen `v'_ol = (`v' > `v'_ts)
				replace `v'_ol = .m if mi(`v')
				drop `v'_ts `v'_sd
				tab `v'_ol
				
				order `v'_ol, after(`v')
				gen var_`v' = `v'
				drop `v'
			}
	}
}

merge 1:1 uuid using "$dta/pnourish_hh_svy.dta", keepusing(svy_team enu_name)

drop _merge 

gen sir = _n

keep *_ol var_* sir uuid enu_name svy_team

rename *_ol ol_*

reshape long ol_ var_ , i(sir) j(var_name) string 

drop sir 

rename var_ values
rename ol_ outlier_yes

order svy_team enu_name uuid var_name values outlier_yes

keep if outlier_yes == 1

// export table
if _N > 0 {
	
	export excel using "$out/03_hfc_hh_outlier.xlsx", sheet("01_demo") firstrow(varlabels) sheetreplace
}

 

