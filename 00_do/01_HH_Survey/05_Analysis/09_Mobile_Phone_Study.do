/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Mobile Phone Study		
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* HH Income *
	****************************************************************************

	use "$dta/pnourish_INCOME_WEALTH_final.dta", clear   
	
	gen hhmem_illiterate = (hh_mem_highedu_all == 1)
	replace hhmem_illiterate = .m if mi(hh_mem_highedu_all)
	tab1 hh_mem_highedu_all hhmem_illiterate, m 

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	
	foreach var of varlist NationalQuintile wealth_quintile_ns_noph wealth_quintile_ns {
		
		di "`var'"
		
		tab `var'
		svy:tab `var'
		
		
	}
	
	
	foreach var of varlist NationalQuintile wealth_quintile_ns_noph wealth_quintile_ns {
		
		di "`var'"
		svy:tab `var' hhmem_illiterate, row 
		svy:tab `var' hhitems_phone, row 
		
		
	}
	
	
	****************************************************************************
	* HH Income *
	****************************************************************************

	use "$dta/pnourish_INCOME_WEALTH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	foreach var of varlist NationalQuintile wealth_quintile_ns_noph wealth_quintile_ns {
		
		di "`var'"
		svy: mean d3_inc_lmth, over(`var')
		
		mat list e(b)
		test _b[c.d3_inc_lmth@1bn.`var'] = _b[c.d3_inc_lmth@2bn.`var'] = _b[c.d3_inc_lmth@3bn.`var'] = _b[c.d3_inc_lmth@4bn.`var'] = _b[c.d3_inc_lmth@5bn.`var']
		
		
	}
	

// END HERE 


