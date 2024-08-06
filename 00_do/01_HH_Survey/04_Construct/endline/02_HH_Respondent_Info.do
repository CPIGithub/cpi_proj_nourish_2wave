/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: respondent info			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
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
	use "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", clear 
	
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			will_participate-cal_hhroster_end
			
	drop cal* *flag* // cla_*
	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/endline/pnourish_endline_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	merge m:1 _parent_index using "$dta/endline/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(income_lastmonth wealth_quintile_modify ///
							wealth_quintile_ns NationalQuintile NationalScore ///
							hhitems_phone prgexpo_pn edu_exposure)
	
	keep if _merge == 3
	
	drop _merge 
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/endline/PN_Village_Survey_Endline_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	
	
	
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_respondent_info_final.xlsx" // export template
	lab drop vill_accessibility_midterm_cat // problem with var lab 
	iecodebook apply using "$raw/pnourish_respondent_info_cleaning.xlsx" 


	** SAVE for analysis dataset 
	save "$dta/endline/pnourish_respondent_info_final.dta", replace  


	
// END HERE 


