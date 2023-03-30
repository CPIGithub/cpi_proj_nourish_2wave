/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh Income and Wealth Quantile cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

	** HH Survey Dataset **
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	
	** Food Insecurity Experience Scale (FIES) (30 days' recall)
	local fies gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat

	foreach v in `fies' {
		
		replace `v' = .d if `v' == 98 | `v' == 97
		tab `v', m 
	} 

	egen fies_rawscore = rowtotal(	gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml ///
									gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat)
	replace fies_rawscore = .m if 	mi(gfi1_notegh) | mi(gfi2_unhnut) | mi(gfi3_fewfd) | ///
									mi(gfi4_skp_ml) | mi(gfi5_less) | mi(gfi6_rout_fd) | ///
									mi(gfi7_hunger) | mi(gfi8_wout_eat)
	tab fies_rawscore, m  
	
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
	save "$dta/pnourish_FIES_final.dta", replace  


// END HERE 


