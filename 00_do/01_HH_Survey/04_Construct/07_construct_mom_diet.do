/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Mom Health data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Mom Health Module *
	****************************************************************************
	use "$dta/pnourish_mom_health_raw.dta", clear 
	
	// _parent_index women_id_pregpast
	
	rename women_id_pregpast roster_index
	
	* keep mom diet only 
	keep	geo_vill ///
			_parent_index roster_index ///
			women_pos1-mom_meal_freq
			
	drop cal* // cla*
	
	** HH Roster **
	// take mother info from HH roster 
	preserve 

	use "$dta/grp_hh_clean.dta", clear
	
	keep	_parent_index roster_index hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months
	
	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 
	
	
	* Youngest Child Age and DOB info 
	preserve 

	use "$dta/grp_hh_clean.dta", clear
	
	// child age calculation 
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"
	
	keep if child_age_month < 24 
	
	
	gen est_dob = svy_date - (child_age_month * 30.04) // average day in month 
	format %td est_dob 
	
	// child birth month calculation 
	gen dob_m = month(hh_mem_dob)
	replace dob_m = month(est_dob) if mi(hh_mem_dob)
	gen dob_y = year(hh_mem_dob)
	replace dob_y = year(est_dob) if mi(hh_mem_dob)
	
	gen hh_mem_dob_str = ym(dob_y, dob_m)
	format hh_mem_dob_str %tm
	lab var hh_mem_dob_str "U2 Child DOB"
	
	
	// keep the youngest child 
	sort _parent_index women_pos1 child_age_month
	bysort _parent_index women_pos1: keep if _n == 1
	
	keep	_parent_index women_pos1 hh_mem_dob_str child_age_month
	
	rename women_pos1 roster_index 

	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'
	
	drop if _merge == 2 // Mom health session only ask for U2 mom - ummatched came from > 2 yrs old
	drop _merge 
	
	
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************
	
	// mom_meal_freq
	replace mom_meal_freq = .r if mom_meal_freq == 666
	replace mom_meal_freq = .d if mom_meal_freq == 999
	replace mom_meal_freq = .d if mom_meal_freq == 444	
	tab mom_meal_freq, m 
	
	// CALCULATION MINIMUM DIETARY DIVERSITY FOR WOMEN
	foreach var of varlist	mom_rice mom_potatoes mom_beans mom_nuts mom_yogurt ///
							mom_organ mom_beef mom_fish mom_eggs mom_leafyveg ///
							mom_pumpkin mom_mango mom_veg mom_fruit mom_fat ///
							mom_sweets mom_condiments {
		
		tab `var', m 	
		
	}
	
	// treat missing as 0 
	gen mddw_grain = (mom_rice == 1 | mom_potatoes == 1)
	replace mddw_grain = .m if mi(mom_rice == 1) & mi(mom_potatoes == 1)
	tab mddw_grain, m 

	gen mddw_pulses = mom_beans

	gen mddw_nut = mom_nuts

	gen mddw_milk = mom_yogurt

	gen mddw_meat = (mom_organ == 1 | mom_beef == 1 | mom_fish == 1)
	replace mddw_meat = .m if mi(mom_organ) & mi(mom_beef) & mi(mom_fish)
	tab mddw_meat, m 

	gen mddw_moom_egg = mom_eggs

	gen mddw_green_veg = mom_leafyveg  
			  
	gen mddw_vit_vegfruit = (mom_pumpkin == 1 | mom_mango == 1)		  
	replace mddw_vit_vegfruit = .m if mi(mom_pumpkin) | mi(mom_mango )
	tab mddw_vit_vegfruit, m
		  
	gen mddw_oth_veg = mom_veg  

	gen mddw_oth_fruit = mom_fruit  

	egen mddw_score = rowtotal(	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
								mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
								mddw_oth_veg mddw_oth_fruit), missing
	replace mddw_score = .m if 	mi(mddw_grain) & mi(mddw_pulses) & mi(mddw_nut) & ///
								mi(mddw_milk) & mi(mddw_meat) & mi(mddw_moom_egg) & ///
								mi(mddw_green_veg) & mi(mddw_vit_vegfruit) & ///
								mi(mddw_oth_veg) & mi(mddw_oth_fruit)
	tab mddw_score, m 

	gen mddw_yes = (mddw_score >= 5 & !mi(mddw_score))
	replace mddw_yes = .m if mi(mddw_score)
	tab mddw_yes, m 

	lab var mddw_grain "Grains, roots, and tubers"
	lab var mddw_pulses "Pulses"
	lab var mddw_nut "Nuts and seeds"
	lab var mddw_milk "Dairy"
	lab var mddw_meat "Meat, poultry, and fish"
	lab var mddw_moom_egg "Eggs"
	lab var mddw_green_veg "Dark leafy greens and vegetables"
	lab var mddw_vit_vegfruit "Other Vitamin A-rich fruits and vegetables"
	lab var mddw_oth_veg "Other vegetables"
	lab var mddw_oth_fruit "Other fruits"					
	lab var mddw_score "MDD-W Score"
	lab var mddw_yes "MDD-W yes"


	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
					
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(	`mainresp' enu_name ///
										income_lastmonth wealth_quintile_ns wealth_quintile_modify ///
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
	// iecodebook template using "$out/pnourish_mom_diet_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_mom_diet_cleaning.xlsx" 

	
	** SAVE for analysis dataset 
	save "$dta/pnourish_mom_diet_final.dta", replace  


// END HERE 


