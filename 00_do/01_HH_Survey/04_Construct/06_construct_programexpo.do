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
	replace prgexpo_pn = .d if prgexpo_pn == 999
	tab prgexpo_pn, m 
	
	
	// prgexpo_join 
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join0 prgexpo_join888 {
	
		replace `var' = .m if prgexpo_pn != 1
		tab `var', m 
								
	}
	
	
	* Add Weight variable *
	merge m:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(stratum_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", keepusing(NationalQuintile NationalScore)
	
	keep if _merge == 3
	
	drop _merge 
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_program_exposure_final.dta", replace  


// END HERE 


