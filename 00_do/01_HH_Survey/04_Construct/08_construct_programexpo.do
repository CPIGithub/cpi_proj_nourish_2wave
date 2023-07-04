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
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			cal_pexp_start-cal_pexp_end
			
	drop cal* // cla*
	
	// prgexpo_pn 
	replace prgexpo_pn = 0 if prgexpo_pn == 999
	tab prgexpo_pn, m 
	
	
	// prgexpo_join 
	rename prgexpo_join888 prgexpo_join9
	
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join0 prgexpo_join9 {
	
		replace `var' = 0 if prgexpo_pn == 0 
		tab `var', m 
								
	}
	
	// prgexp_freq_
	forvalue x = 1/9 {
	    
		tab prgexp_freq_`x', m 
		replace prgexp_freq_`x' = 0 if prgexpo_join`x' == 0
		replace prgexp_freq_`x' = .m if prgexpo_pn == 0
		replace prgexp_freq_`x' = .r if prgexp_freq_`x' == 444
		tab prgexp_freq_`x', m 
		
	} 
	
	// prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0
	tab1 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0, m 
	
	forvalue x = 0/7 {
	    
		replace prgexp_iec`x' = .m if prgexpo_pn == 0 
		tab prgexp_iec`x', m 
	}
	
	
	** PROGRAM EXPOSURE BY ACTIVITY CATEGORY **
	* education exposure
	/*
	* exposure to education part // construct at the weight dataset - so command out this chunk 
	gen edu_exposure 		= (prgexpo_join5 == 1 | prgexpo_join6 == 1 | prgexp_iec0 == 0)
	replace edu_exposure 	= .m if mi(prgexpo_join5) & mi(prgexpo_join6) & mi(prgexp_iec0)
	lab var edu_exposure "Exposure with PN SBCC related activities"
	tab edu_exposure, m 
	*/
	
	* food busket and cash 
	// Adam note:: Define exposure to food basket/cash No/Yes = 0/1
	egen foodcash_exposure = rowtotal(prgexpo_join1 prgexpo_join3)
	replace foodcash_exposure = .m if mi(prgexpo_join1) & mi(prgexpo_join3)
	lab var foodcash_exposure "Number of Project Nourish Food and Cash intervention exposed"
	tab foodcash_exposure, m 
	
	gen foodcash_exposure_d = (foodcash_exposure > 0)
	replace foodcash_exposure_d = .m if mi(foodcash_exposure)
	lab var foodcash_exposure_d "Exposure to Project Nourish Food and Cash intervention"
	tab foodcash_exposure_d, m 
	
	* nutrition sensitive intervnetion 
	/*
	Adam note:
	Define exposure to all food insecurity-sensitive interventions = SBCC + mother support + home gardening = categorical var with range 0-2; 
	we may further simplify as none vs. any
	Please tabulate frequencies for 0,1,2
	We might also generate a variable that includes food basket (range 0-3)
	*/
	egen nutsensitive_exposure = rowtotal(prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 )
	replace nutsensitive_exposure = .m if mi(prgexpo_join5) & mi(prgexpo_join6) & mi(prgexpo_join7) & mi(prgexpo_join8)
	lab var nutsensitive_exposure "Number of Project Nourish Nutrition specific intervention exposed"
	tab nutsensitive_exposure, m 

	gen nutsensitive_exposure_d = (nutsensitive_exposure > 0)
	replace nutsensitive_exposure_d = .m if mi(nutsensitive_exposure)
	lab var nutsensitive_exposure_d "Exposure to Project Nourish Nutrition specific intervention"
	tab nutsensitive_exposure_d, m 
	
	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(income_lastmonth wealth_quintile_ns wealth_quintile_modify ///
							NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
	keep if _merge == 3
	
	drop _merge 
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	
	
	** Program Access **
	/*
	Adam note:
	We thought to define village-level exposure to PN interventions
	I think our primary exposure would list a village as `exposed' to PN interventions 
	if they were reported EITHER by the village head/respondent OR by ANY individual household in that village (cluster)
	Our nutrition-sensitive paper likely would use only the four nutrition-focused interventions above
	*/
	
	/*
	Made adjustment for HH variable 
	if at least one HH report they know PN or exposure with PN activities, 
	consider at village level exposure
	this is strong assumption - as we did not ask where those activites exposed by 
	HH - in the resident village or else 
	
	*/
	
	foreach var of varlist	prgexpo_pn prgexpo_join8 prgexpo_join6 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join7 prgexpo_join1 ///
							prgexpo_join2 prgexpo_join3 {
	
	bysort geo_town geo_vt geo_vill: egen `var'_v = total(`var')
	replace `var'_v = 1 if `var'_v > 0 &  !mi(`var'_v)
	tab1 `var' `var'_v
							
	}

	
	// pn_yes prgexpo_pn
	tab pn_yes prgexpo_pn
	gen pn_access = ((pn_yes == 1 | prgexpo_pn_v == 1) & prgexpo_pn == 1)
	replace pn_access = .m if pn_yes != 1 & prgexpo_pn_v != 1
	replace pn_access = .m if (mi(pn_yes) & mi(prgexpo_pn_v)) | mi(prgexpo_pn)
	lab var pn_access "Program present at village and HH aware about it"
	tab pn_access
	

	// pn_muac_yn prgexpo_join8
	gen pn_muac_access = ((pn_muac_yn == 1 | prgexpo_join8_v == 1) & prgexpo_join8 == 1)
	replace pn_muac_access = .m if pn_muac_yn != 1 & prgexpo_join8_v != 1
	replace pn_muac_access = .m if (mi(pn_muac_yn) & mi(prgexpo_join8_v)) | mi(prgexpo_join8)
	lab var pn_muac_access "MUAC present at village and HH participated in it"
	tab pn_muac_access
	
	// pn_msg_yn prgexpo_join6
	gen pn_msg_access = ((pn_msg_yn == 1 | prgexpo_join6_v == 1) & prgexpo_join6 == 1)
	replace pn_msg_access = .m if pn_msg_yn != 1 & prgexpo_join6_v != 1
	replace pn_msg_access = .m if (mi(pn_msg_yn) & mi(prgexpo_join6_v)) | mi(prgexpo_join6)
	lab var pn_msg_access "MSG present at village and HH participated in it"
	tab pn_msg_access
	
	// pn_wash_yn prgexpo_join4
	gen pn_wash_access = ((pn_wash_yn == 1 | prgexpo_join4_v == 1) & prgexpo_join4 == 1)
	replace pn_wash_access = .m if pn_wash_yn != 1 & prgexpo_join4_v != 1
	replace pn_wash_access = .m if (mi(pn_wash_yn) & mi(prgexpo_join4_v)) | mi(prgexpo_join4)
	lab var pn_wash_access "WASH infra present at village and HH participated in it"
	tab pn_wash_access
	
	// pn_sbcc_yn pn_wsbcc_yn prgexpo_join5
	gen pn_sbcc_access = ((pn_sbcc_yn == 1 | pn_wsbcc_yn == 1 | prgexpo_join5_v == 1) & ///
							prgexpo_join5 == 1)
	replace pn_sbcc_access = .m if pn_sbcc_yn != 1 & pn_wsbcc_yn != 1 & prgexpo_join5_v != 1
	replace pn_sbcc_access = .m if (mi(pn_sbcc_yn) & mi(pn_wsbcc_yn) & mi(prgexpo_join5_v)) | mi(prgexpo_join5)
	lab var pn_sbcc_access "SBCC present at village and HH participated in it"
	tab pn_sbcc_access

	// pn_hgdn_yn prgexpo_join7
	gen pn_hgdn_access = ((pn_hgdn_yn == 1 | prgexpo_join7_v == 1) & prgexpo_join7 == 1)
	replace pn_hgdn_access = .m if pn_hgdn_yn != 1 & prgexpo_join7_v != 1
	replace pn_hgdn_access = .m if (mi(pn_hgdn_yn) & mi(prgexpo_join7_v)) | mi(prgexpo_join7)
	lab var pn_hgdn_access "Home Gardening present at village and HH participated in it"
	tab pn_hgdn_access
	
	// pn_emgy_yn prgexpo_join1 prgexpo_join2 prgexpo_join3
	gen pn_emgy_access = 	((pn_emgy_yn == 1 | prgexpo_join1_v == 1 | prgexpo_join2_v == 1 | prgexpo_join3_v == 1) & ///
							(prgexpo_join1 == 1 | prgexpo_join2 == 1 | prgexpo_join3 == 1))
	replace pn_emgy_access = .m if pn_emgy_yn != 1 & prgexpo_join1_v != 1 & prgexpo_join2_v != 1 & prgexpo_join3_v != 1
	replace pn_emgy_access = .m if 	(mi(pn_emgy_yn) & mi(prgexpo_join1_v) & mi(prgexpo_join2_v) & mi(prgexpo_join3_v)) | ///
									(mi(prgexpo_join1) & mi(prgexpo_join2) & mi(prgexpo_join3))
	lab var pn_emgy_access "Emergency response activities present at village and HH participated in it"
	tab pn_emgy_access
	

	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_program_exposure_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_program_exposure_cleaning.xlsx" 


	** SAVE for analysis dataset 
	save "$dta/pnourish_program_exposure_final.dta", replace  


// END HERE 


