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

use "$dta/pn_hh_pnourish_secondwave.dta", clear 

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
			    
				
			}

	}
	else {
		
		//drop `v'
	}
}

	

// export table
export excel using "$out/03_hfc_hh_outlier.xlsx", sheet("01_demo") firstrow(varlabels) sheetreplace
 

