/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Program exposure data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* HH Level Dataset *
	****************************************************************************
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	// prgexpo_pn 
	replace prgexpo_pn = 0 if prgexpo_pn == 999
	tab prgexpo_pn, m 
	
	
	// prgexpo_join 
	rename prgexpo_join888 prgexpo_join9
	
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join0 prgexpo_join9 {
	
		replace `var' = .m if prgexpo_pn != 1
		tab `var', m 
								
	}
	
	// prgexp_freq_
	forvalue x = 1/9 {
	    
		tab prgexp_freq_`x', m 
		replace prgexp_freq_`x' = 0 if prgexpo_join`x' == 0
		replace prgexp_freq_`x' = .m if prgexpo_pn == 0
		tab prgexp_freq_`x', m 
		
	} 
	
	// prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0
	tab1 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0, m 
	
	forvalue x = 0/7 {
	    
		replace prgexp_iec`x' = .m if prgexpo_pn == 0 
		tab prgexp_iec`x', m 
	}
	
	
	* Add Weight variable *
	merge m:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(stratum_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(NationalQuintile NationalScore hhitems_phone prgexpo_pn)
	
	keep if _merge == 3
	
	drop _merge 
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_program_exposure_final.dta", replace  


// END HERE 


