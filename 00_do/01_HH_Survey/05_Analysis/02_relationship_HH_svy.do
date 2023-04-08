/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	keep 	weight_final stratum_num geo_vill ///
			NationalQuintile hhitems_phone prgexpo_pn edu_exposure ///
			_parent_index roster_index ///
			mom_meal_freq mddw_score mddw_yes
	
	merge 1:1 _parent_index roster_index using "$dta/pnourish_PHQ9_final.dta", keepusing(phq9_cat)  

	keep if _merge == 3
	
	drop _merge 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	// mddw_yes
	svy: tab phq9_cat mddw_yes, row 
	tab phq9_cat mddw_yes
	
	// dietary_tot 
	svy: mean mddw_score, over(phq9_cat)

	svy: reg mddw_score i.phq9_cat
	mat list e(b)
	test 1b.phq9_cat = 2.phq9_cat = 3.phq9_cat = 4.phq9_cat = 5.phq9_cat
			

	clear 
	
	
	****************************************************************************
	* Child MUAC Module *
	****************************************************************************

	use "$dta/pnourish_child_muac_final.dta", clear   
	
	
	keep 	weight_final stratum_num geo_vill ///
			NationalQuintile hhitems_phone prgexpo_pn edu_exposure ///
			_parent_index roster_index hh_mem_mom ///
			child_gam
	
	drop roster_index 
	rename hh_mem_mom roster_index 
	
	merge m:1 _parent_index roster_index using "$dta/pnourish_PHQ9_final.dta", keepusing(phq9_cat)  

	keep if _merge == 3
	
	drop _merge 
	

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	svy: tab phq9_cat child_gam, row 
	tab phq9_cat child_gam



	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	keep 	weight_final stratum_num geo_vill ///
			NationalQuintile hhitems_phone prgexpo_pn edu_exposure ///
			_parent_index roster_index hh_mem_mom ///
			eibf ebf cbf mdd dietary_tot mmf mad

	drop roster_index 
	rename hh_mem_mom roster_index 
	
	merge m:1 _parent_index roster_index using "$dta/pnourish_PHQ9_final.dta", keepusing(phq9_cat)  

	keep if _merge == 3
	
	drop _merge 

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	tab phq9_cat, m 
	
	keep if phq9_cat < 4

	// eibf 
	svy: tab phq9_cat eibf, row 
	tab phq9_cat eibf
	
	// ebf 
	svy: tab phq9_cat ebf, row 
	tab phq9_cat ebf
	
	// cbf 
	svy: tab phq9_cat cbf, row 
	tab phq9_cat cbf
	
	// mdd 
	svy: tab phq9_cat mdd, row 
	tab phq9_cat mdd
	
	// mmf 
	svy: tab phq9_cat mmf, row 
	tab phq9_cat mmf
	
	// mad
	svy: tab phq9_cat mad, row 
	tab phq9_cat mad

	

	
// END HERE 


