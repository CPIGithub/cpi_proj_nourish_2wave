/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: child MUAC data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Child MUAC Module *
	****************************************************************************
	use "$dta/endline/pnourish_child_muac_raw.dta", clear 
	
	// _parent_index child_id_muac
	
	rename child_id_muac roster_index
	
	* keep child health iycf only 
	keep	geo_vill ///
			_parent_index roster_index ///
			cal_cmuac_start-cal_cmuac_end
			
	drop cal* // cla*
	
	** HH Roster **
	preserve 

	use "$dta/endline/grp_hh_clean.dta", clear
	
	keep	_parent_index roster_index hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months women_pos1
	
	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 
	
	****************************************************************************
	** Child Age Calculation **
	****************************************************************************
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"

	****************************************************************************
	** MUAC Indicators **
	****************************************************************************
	
	* child_muac_yn 
	tab child_muac_yn, m 
	
	
	* child_muac
	replace child_muac = .d if child_muac == 44
	tab child_muac, m 
	
	rename child_muac u5_muac
	
	// child malnutrition 
	gen child_gam = (u5_muac < 12.5)
	replace child_gam = .m if mi(u5_muac) 
	replace child_gam = .m if child_age_month < 6 & child_age_month >= 60
	lab var child_gam "Acute Malnutrition (MUAC < 12.5)"
	tab child_gam, m 

	gen child_mam = (u5_muac >= 11.5 & u5_muac < 12.5)
	replace child_mam = .m if mi(u5_muac)
	replace child_mam = .m if child_age_month < 6 & child_age_month >= 60
	lab var child_mam "Moderate Acute Malnutrition (11.5 >= MUAC <= 12.5)"
	tab child_mam, m 

	gen child_sam = (u5_muac < 11.5)
	replace child_sam = .m if mi(u5_muac) 
	replace child_sam = .m if child_age_month < 6 & child_age_month >= 60
	lab var child_sam "Moderate Acute Malnutrition (MUAC < 11.5)"
	tab child_sam, m 

	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/endline/pnourish_endline_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
					
	merge m:1 _parent_index using "$dta/endline/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(	`mainresp' ///
										prgexpo_join8 ///
										income_lastmonth wealth_quintile_ns wealth_quintile_modify ///
										NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
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
	// iecodebook template using "$out/pnourish_child_muac_final.xlsx" // export template
	lab drop vill_accessibility_midterm_cat // problem with var lab
	iecodebook apply using "$raw/pnourish_child_muac_cleaning.xlsx" 

	
	** SAVE for analysis dataset 
	save "$dta/endline/pnourish_child_muac_final.dta", replace  


// END HERE 


