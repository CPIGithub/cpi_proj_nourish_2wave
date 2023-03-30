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
	
	
	** Women empowerment 
	// ref: https://www.dhsprogram.com/Data/Guide-to-DHS-Statistics/index.cfm
	
	destring cal_sum_feadult, replace 
	
	foreach v of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing  {
		
		replace `v' = .m if cal_sum_feadult == 0 
		tab `v', m 
	}
	
	// 1) Own health care.
	gen women_ownhealth = (wempo_mom_health == 1)
	replace women_ownhealth = .m if mi(wempo_mom_health)
	lab var women_ownhealth "Own health care"
	tab women_ownhealth, m 

	// 2) Large household purchases.
	gen women_hhpurchase = (wempo_major_purchase == 1)
	replace women_hhpurchase = .m if mi(wempo_major_purchase)
	lab var women_hhpurchase "Large household purchases"
	tab women_hhpurchase, m 
	
	// 3) Visits to family or relatives.
	gen women_visit = (wempo_visiting == 1)
	replace women_visit = .m if mi(wempo_visiting)
	lab var women_visit "Visits to family or relatives"
	tab women_visit, m 
	
	
	// wempo_group 
		foreach v of varlist wempo_group1 wempo_group2 wempo_group3 wempo_group4 wempo_group5 wempo_group888 wempo_group777 wempo_group999 {
		
		replace `v' = .m if cal_sum_feadult == 0 
		tab `v', m 
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
	save "$dta/pnourish_WOMEN_EMPOWER_final.dta", replace  


// END HERE 


