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
			cal_fies_start-cal_fies_end
			
	drop cal* // cla*
	
	** Food Insecurity Experience Scale (FIES) (30 days' recall)
	local fies gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat

	foreach v in `fies' {
		
		replace `v' = .d if `v' == 98 | `v' == 97
		replace `v' = 0 if `v' == 2
		tab `v', m 
	} 

	egen fies_rawscore = rowtotal(	gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml ///
									gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat)
	replace fies_rawscore = .m if 	mi(gfi1_notegh) | mi(gfi2_unhnut) | mi(gfi3_fewfd) | ///
									mi(gfi4_skp_ml) | mi(gfi5_less) | mi(gfi6_rout_fd) | ///
									mi(gfi7_hunger) | mi(gfi8_wout_eat)
	tab fies_rawscore, m  
	
	
	* FIES - category - naive * 
	* cutoffs for the raw score of 4+ = mod/severe and 7-8 = severe
	gen fies_category = (fies_rawscore >= 4) 
	replace fies_category = 2 if fies_rawscore >= 7 & !mi(fies_rawscore)
	replace fies_category = .m if mi(fies_rawscore)
	lab def fies_category 0"Food secure (0-3)" 1"Moderate food insecurity (4-6)" 2"Severe food insecurity (7-8)"
	lab var fies_category "Food Security Status by FIES ( discrete assignment appraoch)"
	lab val fies_category fies_category
	tab fies_category, m 
	
	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_midterm_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	// drop prgexpo_pn
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
	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_FIES_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_FIES_cleaning.xlsx" 
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_FIES_final.dta", replace  
	
	
	** For Rasch Model analysis in R **
	keep 	stratum_num weight_final ///
			respd_id respd_sex respd_age resp_highedu ///
			gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat ///
			
	foreach var of varlist gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat {
		
		replace `var' = 0 if `var' == 2
		 
	}
	
	lab drop fies
	 

	order 	stratum_num weight_final ///
			respd_id respd_sex respd_age resp_highedu ///
			gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less gfi6_rout_fd gfi7_hunger gfi8_wout_eat ///
	
	rename gfi1_notegh		WORRIED
	rename gfi2_unhnut		HEALTHY
	rename gfi3_fewfd		FEWFOOD
	rename gfi4_skp_ml		SKIPPED
	rename gfi5_less		ATELESS
	rename gfi6_rout_fd		RUNOUT
	rename gfi7_hunger		HUNGRY
	rename gfi8_wout_eat	WHLDAY
 
	** SAVE for Rasch Model analysis dataset 
	save "$dta/pnourish_FIES_Rasch_Model_final.dta", replace  


// END HERE 


