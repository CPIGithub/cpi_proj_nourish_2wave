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
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			cal_phq_start-cal_phq_end
			
	drop cal* // cla*
	
	** PHQ-9 
	local phq9 phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9

	foreach v in `phq9' {
		replace `v' = `v' - 1 
		tab `v', m 
	} 

	egen phq9_score = rowtotal(	phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9)
	replace phq9_score = .m if 	mi(phq9_1) | mi(phq9_2) | mi(phq9_3) | mi(phq9_4) | ///
								mi(phq9_5) | mi(phq9_6) | mi(phq9_7) | mi(phq9_8) | ///
								mi(phq9_9)
	tab phq9_score, m  
	

	gen phq9_cat = .m 
	replace phq9_cat =  1 if phq9_score <= 4
	replace phq9_cat =  2 if phq9_score > 4 & phq9_score <= 9
	replace phq9_cat =  3 if phq9_score > 9 & phq9_score <= 14
	replace phq9_cat =  4 if phq9_score > 14 & phq9_score <= 19
	replace phq9_cat =  5 if phq9_score > 19 & phq9_score <= 27
		lab def phq9_cat 1"None-minimal" 2"Mild" 3"Moderate" 4"Moderately Severe" 5"Severe"
	lab val phq9_cat phq9_cat
	tab phq9_cat, m 

	
	* Add Weight variable *
	merge m:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(stratum_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	// drop prgexpo_pn
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(income_lastmonth NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
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
	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_PHQ9_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_PHQ9_cleaning.xlsx" 
	


	** SAVE for analysis dataset 
	save "$dta/pnourish_PHQ9_final.dta", replace  


// END HERE 


